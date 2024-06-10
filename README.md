# Movement dApp Workshop

This repository contains two iterations of a simple dApp that allows users to post messages to a chat room. The chat room can be accessed by anyone and anyone can create their own chat room. The dApp is built using the Aptos Move language and Sui Move language.

Aptos: `https://main.d2761w90g9sxb3.amplifyapp.com/`
Sui: `https://main.d2qxq8n60k8d0a.amplifyapp.com/`

## Requirements

Movement CLI

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/movemntdev/M1/main/scripts/install.sh) --latest
```

clone this repository

## Aptos Iteration

The first iteration of the dApp is built using the Aptos Move language. The dApp is located in the `aptos` directory. Once inside the repository, navigate to the `aptos` directory and run the following commands to deploy the dApp to the Move VM.

```bash
cd aptos
```

### Publish Module

Aptos language requires you to initialize the Move environment:

```bash
movement aptos move init
```
or if using Aptos CLI:

```bash
aptos move init
```

Then you can publish the module:

```bash
movement aptos move publish --named-addresses chat_addr=default
```

or
```bash
aptos move publish --named-addresses chat_addr=default
```

### Test Front End

To test the front end, navigate to the `frontend` directory and run the following command to start the front end server.

```bash
npm i && npm run dev
```

You will be able to see your frontend at `http://localhost:3000`.

Take a look at `aptos/frontend/components/Chat.tsx`. This file contains the logic for the chat room. The `Chat` component is responsible for fetching the chat messages, displaying them and posting new messages to the chat room.

```tsx
const abi = { "address": "0xYOUR_ADDRESS", (...)}"
```

Replace `0xYOUR_ADDRESS` with the address of the `chat_addr` you just published. Make sure the address starts with `0x` else add it. That should be available in `.aptos/config.yaml` file as the `account` field.

Now you can try running your transactions on the frontend and see the chat messages being posted.

## Sui Iteration

The next iteration of the dApp is built using the Sui Move language. Once inside the repository, navigate to the `sui` directory:

```bash
cd sui
```
Then publish the module.

### Publish Module

Sui language requires you to add configure your environment for Movement:

```bash
movement sui client new-env --alias movement --rpc https://sui.devnet.m2.movementlabs.xyz
```

or if using Sui CLI:

```bash
sui client new-env --alias movement --rpc https://sui.devnet.m2.movementlabs.xyz
```

Then switch to `movement`:

```bash
movement sui client switch movement
```

or

```bash
sui client switch movement
```

Then you can publish the module:

```bash
movement sui client publish --gas-budget 5000000 --skip-dependency-verification
```

or

```bash
sui client publish --gas-budget 5000000 --skip-dependency-verification
```

Look at the transaction data output. Under "Transaction Effects" you'll see Created Objects:

One object will have `Owner: Shared` under its ID. That's your `ChatRoom` object. You'll need that ID in the next step.

Under "Published Objects" you'll see a `PackageID`. That's the ID of your `chat` package. You'll need that as well.

### Test Front End

To test the front end, navigate to the Sui `frontend` directory and run the following command to start the front end server.

```bash
npm i && npm run dev
```

You will be able to see your frontend at `http://localhost:3000`.

Take a look at `sui/frontend/components/Chat.tsx`. This file contains the logic for the chat room. The `Chat` component is responsible for fetching the chat messages, displaying them and posting new messages to the chat room.

Replace `chatRoomId` with the ID of the `ChatRoom` you just published. Make sure the address starts with `0x` else add it.

Replace `CHAT_PACKAGE_ID` with the ID of your `chat` package.

Now you can try running your transactions on the frontend and see the chat messages being posted.
