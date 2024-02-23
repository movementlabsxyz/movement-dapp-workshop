module chat_addr::Chat {
    use std::string::String;
    use std::string::utf8;
    use std::option::{Option, none, some};
    use std::vector;
    use std::signer;
    use std::account;
    use std::timestamp;

    const E_SENDER_MISMATCH: u64 = 2;
    const E_CHAT_ROOM_EXISTS: u64 = 3;
    const MAX_TEXT_LENGTH: u64 = 512;
    const E_TEXT_OVERFLOW: u64 = 0;

    struct MessageRoom has key, store {
        messages: vector<Message>,
        message_count: u64,
    }

    struct Message has key, store, drop {
        sender: address,
        // Post's text.
        text: vector<u8>,
        // Post's timestamp.
        timestamp: u64,
        // Set if referencing an another object (i.e., due to a Like, Retweet, Reply etc).
        // We allow referencing any object type, not only Message NFTs.
        ref_id: Option<address>,
        // app-specific metadata. We do not enforce a metadata format and delegate this to app layer.
        metadata: vector<u8>,
    }

    fun init_module(account: &signer) {
        let room = MessageRoom {
            messages: vector::empty(),
            message_count: 0,
        };
        move_to<MessageRoom>(account, room);
    }

    /// Create a new chat room.
    public entry fun create_chat_room(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<MessageRoom>(addr), E_CHAT_ROOM_EXISTS);
        let room = MessageRoom {
            messages: vector::empty(),
            message_count: 0,
        };
        move_to(account, room);
    }

    /// Simple Message object getter.
    #[view]
    public fun get_messages(addr: address) : vector<Message> acquires MessageRoom {
        let room = borrow_global<MessageRoom>(addr);
        room.messages
    }

    /// Post a Message object.
    fun post_internal(
        account: &signer,
        text: vector<u8>,
        ref_id: Option<address>,
        metadata: vector<u8>,
        chat_room: address
    ) acquires MessageRoom {
        assert!(vector::length(&text) <= MAX_TEXT_LENGTH, E_TEXT_OVERFLOW);
        let addr = signer::address_of(account);
        let message = Message {
            sender: addr,
            text: text,
            timestamp: timestamp::now_seconds(),
            ref_id,
            metadata,
        };

        let room = borrow_global_mut<MessageRoom>(chat_room);
        room.message_count = room.message_count + 1;
        vector::push_back(&mut room.messages, message);
    }
    
    /// Post a Message object without referencing another object.
    public entry fun post(
        account: &signer,
        text: vector<u8>,
        metadata: vector<u8>,
        chat_room: address
    ) acquires MessageRoom {
        post_internal(account, text, none(), metadata, chat_room);
    }

    public entry fun post_with_ref(
        account: &signer,
        text: vector<u8>,
        ref_identifier: address,
        metadata: vector<u8>,
        chat_room: address
    ) acquires MessageRoom {
        post_internal(account, text, some(ref_identifier), metadata, chat_room);
    }
}