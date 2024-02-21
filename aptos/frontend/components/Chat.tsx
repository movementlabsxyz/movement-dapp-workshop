"use client";
import { useEffect, useState } from "react";
import { createSurfClient, createEntryPayload } from "@thalalabs/surf";
import { Aptos, Network, AptosConfig } from '@aptos-labs/ts-sdk';
import { useSubmitTransaction } from "@thalalabs/surf/hooks";

interface Message {
    content: string;
    date: string;
    address: string;
}
// instantiate the client
const client = createSurfClient(new Aptos(new AptosConfig({ fullnode: "https://devnet.m1.movementlabs.xyz" })));
const abi = {} as const;
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
        const [messages] = await client.useABI(abi).view.getMessages({
            functionArguments: [],
            typeArguments: [],
        })
        setHistory(messages);
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
              typeArguments: ['string'],
              functionArguments: [message],
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
                <div className={message.address == userAddress ? "hover:right-0" : ""} key={index}>
                    <p>{message.content}</p>
                    <p className="text-sm">{message.date}</p>
                </div>
            ))}
            <textarea onChange={(e) => { updateMessage(e) }}></textarea>
            <button className="b-10" onClick={() => {
                postMessage()
            }}>Post</button>
        </div>
    )
}