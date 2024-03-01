# Movement dApp Workshop

This repository contains two iterations of a simple dApp that allows users to post messages to a chat room. The chat room can be accessed by anyone and anyone can create their own chat room. The dApp is built using the Aptos Move language and Sui Move language.

## Requirements

Movement CLI

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/movemntdev/M1/main/scripts/install.sh) --latest
```

clone this repository

## Aptos Iteration

The first iteration of the dApp is built using the Aptos Move language. The dApp is located in the `aptos` directory. Once inside the repository, navigate to the `aptos` directory and run the following command to deploy the dApp to the Move VM.

```bash
cd aptos
```

### Publish Module

Aptos language requires you to initialize the move environment:

```bash
movement aptos move init
```

Then you can publish the module:

```bash
movement aptos move publish --named-addresses chat_addr=default
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

The first iteration of the dApp is built using the Aptos Move language. The dApp is located in the `sui` directory. Once inside the repository, navigate to the `sui` directory and run the following command to deploy the dApp to the Move VM.

```bash
cd sui
```

### Publish Module

Aptos language requires you to initialize the move environment:

```bash
movement sui move init
```

Then you can publish the module:

```bash
movement aptos move publish --named-addresses chat_addr=default
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