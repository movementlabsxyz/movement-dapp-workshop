"use client";
import { useEffect, useState } from "react";
import { createSurfClient, createEntryPayload } from "@thalalabs/surf";
import { Aptos, AptosConfig, Network } from '@aptos-labs/ts-sdk';
import { useSubmitTransaction } from "@thalalabs/surf/hooks";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { NextResponse } from "next/server";
import { hex2a, formatDate, formatAddress } from "@/util/functions";

interface Message {
    sender: string;
    text: string,
    timestamp: number;
    ref_id: string;
    metadata: string;
}
const chatAddress = "0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e";

// instantiate the client
// const client = createSurfClient(new Aptos(new AptosConfig({ fullnode: "https://aptos.devnet.m1.movementlabs.xyz" })));
const client = createSurfClient(new Aptos(new AptosConfig({ network: Network.DEVNET })));
const abi = { "address": "0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e", "name": "Chat", "friends": [], "exposed_functions": [{ "name": "create_chat_room", "visibility": "public", "is_entry": true, "is_view": false, "generic_type_params": [], "params": ["&signer"], "return": [] }, { "name": "get_messages", "visibility": "public", "is_entry": false, "is_view": true, "generic_type_params": [], "params": ["address"], "return": ["vector<0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e::Chat::Message>"] }, { "name": "post", "visibility": "public", "is_entry": true, "is_view": false, "generic_type_params": [], "params": ["&signer", "vector<u8>", "vector<u8>", "address"], "return": [] }, { "name": "post_with_ref", "visibility": "public", "is_entry": true, "is_view": false, "generic_type_params": [], "params": ["&signer", "vector<u8>", "address", "vector<u8>", "address"], "return": [] }], "structs": [{ "name": "ChatRoom", "is_native": false, "abilities": ["store", "key"], "generic_type_params": [], "fields": [{ "name": "messages", "type": "vector<0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e::Chat::Message>" }, { "name": "message_count", "type": "u64" }] }, { "name": "Message", "is_native": false, "abilities": ["copy", "store", "key"], "generic_type_params": [], "fields": [{ "name": "sender", "type": "address" }, { "name": "text", "type": "vector<u8>" }, { "name": "timestamp", "type": "u64" }, { "name": "ref_id", "type": "0x1::option::Option<address>" }, { "name": "metadata", "type": "vector<u8>" }] }] } as const;
export default function Chat() {
    const [history, setHistory] = useState([] as Message[]);
    const [message, setMessage] = useState("");

    const {
        connect,
        account,
        network,
        connected,
        disconnect,
        wallet,
        wallets,
        signAndSubmitTransaction,
        signTransaction,
        signMessage,
    } = useWallet();


    const {
        isIdle,
        reset,
        isLoading: submitIsLoading,
        error: submitError,
        submitTransaction,
        data: submitResult,
    } = useSubmitTransaction();



    useEffect(() => {
        const getMessages = async () => {
            const [messages] = await client.useABI(abi).view.get_messages({
                functionArguments: [chatAddress],
                typeArguments: [],
            })
            await reset();
            console.log(messages);
            console.log(account?.address)
            setHistory(messages as Message[]);
        }
        getMessages()
    }, [account?.address, submitIsLoading])


    const postMessage = async () => {
        try {
            const payload = createEntryPayload(abi, {
                function: 'post',
                typeArguments: [],
                functionArguments: [message, [], chatAddress],

            });
            const tx = await submitTransaction(payload);
            return NextResponse.json({ tx });
        } catch (e) {
            console.error('error', e);
        }
    };

    const updateMessage = (e: any) => {
        setMessage(e.target.value);
    };

    return (
        <div className="grid grid-flow-col-1">
            <h1 className="text-lg">History</h1>
            {history.map((message, index) => (

                <div key={index}>
                    <p className={message.sender == account?.address ? "text-stone-400" : ""}>{message.sender == account?.address ? "You: " : formatAddress(account?.address as string) + ": "}{hex2a(message.text.slice(2))}</p>

                    <p className="text-xs">{formatDate(new Date(message.timestamp * 1000))}</p>
                </div>
            ))}
            <form onSubmit={(e) => { e.preventDefault(); postMessage(); }}>
                <label className="p-2">Message
                    <input type="text" className="z-2000 text-black p-2 m-2" defaultValue={"hello"} onChange={updateMessage} />
                </label>
            </form>
            <button onClick={postMessage}>Send</button>
        </div>
    )
}