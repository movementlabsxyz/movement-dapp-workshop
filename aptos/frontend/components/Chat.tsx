"use client";
import { useEffect, useState } from "react";
import { createSurfClient, createEntryPayload } from "@thalalabs/surf";
import { Aptos, Network, AptosConfig } from '@aptos-labs/ts-sdk';
import { useSubmitTransaction } from "@thalalabs/surf/hooks";

interface Message {
    sender: string;
    text: string,
    timestamp: number;
    ref_id: string;
    metadata: string;
}
// instantiate the client
const chatAddress = "0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e";
const client = createSurfClient(new Aptos(new AptosConfig({ fullnode: "https://devnet.m1.movementlabs.xyz" })));
const abi = {"address":"0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e","name":"Chat","friends":[],"exposed_functions":[{"name":"create_chat_room","visibility":"public","is_entry":true,"is_view":false,"generic_type_params":[],"params":["&signer"],"return":[]},{"name":"get_messages","visibility":"public","is_entry":false,"is_view":true,"generic_type_params":[],"params":["address"],"return":["vector<0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e::Chat::Message>"]},{"name":"post","visibility":"public","is_entry":true,"is_view":false,"generic_type_params":[],"params":["&signer","vector<u8>","vector<u8>","address"],"return":[]},{"name":"post_with_ref","visibility":"public","is_entry":true,"is_view":false,"generic_type_params":[],"params":["&signer","vector<u8>","address","vector<u8>","address"],"return":[]}],"structs":[{"name":"ChatRoom","is_native":false,"abilities":["store","key"],"generic_type_params":[],"fields":[{"name":"messages","type":"vector<0x5548665475c1807d19e3fc20bfb45cae242a14fce51ae1abb891ad06639c805e::Chat::Message>"},{"name":"message_count","type":"u64"}]},{"name":"Message","is_native":false,"abilities":["copy","store","key"],"generic_type_params":[],"fields":[{"name":"sender","type":"address"},{"name":"text","type":"vector<u8>"},{"name":"timestamp","type":"u64"},{"name":"ref_id","type":"0x1::option::Option<address>"},{"name":"metadata","type":"vector<u8>"}]}]} as const;
export default function Chat() {
    const [history, setHistory] = useState([] as Message[]);
    const [userAddress, setUserAddress] = useState("");
    const [message, setMessage] = useState("");

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
            functionArguments: [chatAddress],
            typeArguments: [],
        })
        setHistory(messages as Message[]);
    }

    useEffect(() => {
        getMessages()
    })


    const updateMessage = (e: any) => {
        setMessage(e.target.value);
    };

    const postMessage = async () => {
        try {
            const payload = createEntryPayload(abi, {
              function: 'post',
              typeArguments: [],
              functionArguments: [message, [], chatAddress],

            });
            await submitTransaction(payload);
          } catch (e) {
            console.error('error', e);
          }
    };

    return (
        <div className="grid grid-flow-col-1">
            <h1 className="text-lg">History</h1>
            {history.map((message, index) => (
                <div className={message.sender == userAddress ? "hover:right-0" : ""} key={index}>
                    <p>{message.text}</p>
                    <p className="text-sm">{message.timestamp}</p>
                </div>
            ))}
            <textarea onChange={(e) => { updateMessage(e) }}></textarea>
            <button className="b-10" onClick={() => {
                postMessage()
            }}>Post</button>
        </div>
    )
}