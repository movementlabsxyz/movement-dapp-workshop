module Chat {
    use std::string::{String, utf8};
    use std::option::{Option, none, some};
    use std::vector::Vector;
    use aptos_std::table::{Self, Table};
    use aptos_framework::timestamp::Timestamp;

    const E_SENDER_MISMATCH: u64 = 2;
    const MAX_TEXT_LENGTH: u64 = 512;
    const E_TEXT_OVERFLOW: u64 = 0;

    struct MessageRoom {
        table: storage::Table<u64, Message>,
        message_count: u64,
    }

    struct Message has key, store, drop {
        sender: address,
        // Post's text.
        text: String,
        // Post's timestamp.
        timestamp: Timestamp,
        // Set if referencing an another object (i.e., due to a Like, Retweet, Reply etc).
        // We allow referencing any object type, not only Message NFTs.
        ref_id: Option<address>,
        // app-specific metadata. We do not enforce a metadata format and delegate this to app layer.
        metadata: vector<u8>,
    }

    fun init_module(sender: &signer) {
        let room = MessageRoom {
            table: table::new(),
            message_count: 0,
        };
        move_to<MessageRoom>(sender, room);
    }

    /// Simple Message object getter.
    #[view]
    public fun get_messages() : Vec<Message> {
        let room = borrow_global<MessageRoom>(&account::Self.address);
        let messages = vector::empty<Message>();
        for (i in 0..room.message_count) {
            let message = table::get(&room.table, i);
            vector::push_back<Message>(&mut messages, message);
        }
        messages
    }

    /// Post a Message object.
    fun post_internal(
        text: vector<u8>,
        ref_id: Option<address>,
        metadata: vector<u8>,
        signer: &signer,
    ) {
        assert!(utf8::length(&text) <= MAX_TEXT_LENGTH, E_TEXT_OVERFLOW);

        let message = Message {
            sender: signer.address,
            text: String::utf8(text),
            timestamp: Timestamp::now(),
            ref_id,
            metadata,
        };

        let room = borrow_global_mut<MessageRoom>(&account::Self.address);
        room.message_count += 1;
        let message_count = room.message_count;
        table::upsert(&mut room.table, message_count, message);
    }
    
    /// Post a Message object without referencing another object.
    public entry fun post(
        text: vector<u8>,
        metadata: vector<u8>,
        signer: &signer,
    ) {
        post_internal(app_identifier, text, none(), metadata, signer);
    }


    public entry fun post_with_ref(
        app_identifier: address,
        text: vector<u8>,
        ref_identifier: address,
        metadata: vector<u8>,
        signer: &signer,
    ) {
        post_internal(app_identifier, text, some(ref_identifier), metadata, signer);
    }

    /// Burn a Message object.
    public entry fun burn(message: Message, signer: &signer) {
        assert!(message.sender == signer.address, E_SENDER_MISMATCH);
        let Message { sender: _, text: _, timestamp: _, ref_id: _, metadata: _ } = message;
    }
}