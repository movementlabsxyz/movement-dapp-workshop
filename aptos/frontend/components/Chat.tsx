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

// instantiate the client
const client = createSurfClient(new Aptos(new AptosConfig({ fullnode: "https://aptos.devnet.m1.movementlabs.xyz" })));

const abi = { "address": "0x9a193de087aa158925b341c204d71b897d121f183a9ceddae7a8c2bb1c052a46", "name": "Chat", "friends": [], "exposed_functions": [{ "name": "create_chat_room", "visibility": "public", "is_entry": true, "is_view": false, "generic_type_params": [], "params": ["&signer"], "return": [] }, { "name": "get_messages", "visibility": "public", "is_entry": false, "is_view": true, "generic_type_params": [], "params": ["address"], "return": ["vector<0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e::Chat::Message>"] }, { "name": "post", "visibility": "public", "is_entry": true, "is_view": false, "generic_type_params": [], "params": ["&signer", "vector<u8>", "vector<u8>", "address"], "return": [] }, { "name": "post_with_ref", "visibility": "public", "is_entry": true, "is_view": false, "generic_type_params": [], "params": ["&signer", "vector<u8>", "address", "vector<u8>", "address"], "return": [] }], "structs": [{ "name": "ChatRoom", "is_native": false, "abilities": ["store", "key"], "generic_type_params": [], "fields": [{ "name": "messages", "type": "vector<0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e::Chat::Message>" }, { "name": "message_count", "type": "u64" }] }, { "name": "Message", "is_native": false, "abilities": ["copy", "store", "key"], "generic_type_params": [], "fields": [{ "name": "sender", "type": "address" }, { "name": "text", "type": "vector<u8>" }, { "name": "timestamp", "type": "u64" }, { "name": "ref_id", "type": "0x1::option::Option<address>" }, { "name": "metadata", "type": "vector<u8>" }] }] } as const;
export default function Chat() {
    const [history, setHistory] = useState([] as Message[]);
    const [message, setMessage] = useState("hello");
    const { account } = useWallet();

    const {
        isIdle,
        reset,
        isLoading: submitIsLoading,
        error: submitError,
        submitTransaction,
        data: submitResult,
    } = useSubmitTransaction();

    const getMessages = async () => {
        const [messages] = await client.useABI(abi).view.get_messages({
            functionArguments: [abi.address],
            typeArguments: [],
        })
        console.log(messages);
        console.log(account?.address)
        await reset();
        setHistory(messages as Message[]);
    }

    useEffect(() => {
        getMessages();
        const intervalId = setInterval(getMessages, 5000);

        return () => clearInterval(intervalId);
    }, [account?.address, submitResult, submitError, submitIsLoading])


    const postMessage = async () => {
        try {
            const payload = createEntryPayload(abi, {
                function: 'post',
                typeArguments: [],
                functionArguments: [message, [], abi.address],

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
        <div className="grid grid-flow-col-1 group rounded-lg border border-transparent px-5 py-4 transition-colors border-gray-300 dark:border-neutral-700 dark:bg-neutral-800/30">
            <h1 className="text-lg">History</h1>
            <div className="overflow-y-scroll h-72">

                {history.map((message, index) => (

                    <div key={index} className={message.sender == account?.address ? "text-right border-b-[1px] border-stone-700 p-2" : "border-b-[1px] border-stone-700 p-2"}>
                        <p className={message.sender == account?.address ? "text-stone-400" : ""}>{message.sender == account?.address ? "You: " : formatAddress(message.sender as string) + ": "}{hex2a(message.text.slice(2))}</p>

                        <p className="text-xs">{formatDate(new Date(message.timestamp * 1000))}</p>
                    </div>
                ))}
            </div>
            <form className="" onSubmit={(e) => { e.preventDefault(); postMessage(); }}>
                <label className="p-2">Message
                    <input type="text" className="z-2000 text-white bg-black p-2 m-2 border-[1px]ot " defaultValue={"hello"} onChange={updateMessage} />
                </label>
            </form>
            <button className="bg-black border-gray-300 rounded-lg border-[1px] text-white" onClick={postMessage}>Send</button>
        </div>
    )
}