module chat_addr::Chat {
    use std::string::{String, utf8};
    use std::option::{Option, none, some};
    use std::vector;
    use std::signer;
    use std::account;
    use aptos_framework::timestamp::Timestamp;

    const E_SENDER_MISMATCH: u64 = 2;
    const MAX_TEXT_LENGTH: u64 = 512;
    const E_TEXT_OVERFLOW: u64 = 0;

    struct MessageRoom {
        messages: vector<Message>,
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
            messages: vector::empty(),
            message_count: 0,
        };
        move_to<MessageRoom>(sender, room);
    }

    /// Simple Message object getter.
    #[view]
    public fun get_messages() : vector<Message> {
        let room = borrow_global<MessageRoom>(chat_addr);
        room.messages
    }

    /// Post a Message object.
    fun post_internal(
        signer: &signer,
        text: vector<u8>,
        ref_id: Option<address>,
        metadata: vector<u8>,
    ) {
        assert!(utf8::length(&text) <= MAX_TEXT_LENGTH, E_TEXT_OVERFLOW);
        let addr = signer::address_of(signer);
        let message = Message {
            sender: addr,
            text: String::utf8(text),
            timestamp: Timestamp::now(),
            ref_id,
            metadata,
        };

        let room = borrow_global_mut<MessageRoom>(chat_addr);
        room.message_count = room.message_count + 1;
        vector::push_back(&mut room.messages, message);
    }
    
    /// Post a Message object without referencing another object.
    public entry fun post(
        signer: &signer,
        text: vector<u8>,
        metadata: vector<u8>,
    ) {
        post_internal(signer, text, none(), metadata);
    }


    public entry fun post_with_ref(
        signer: &signer,
        app_identifier: address,
        text: vector<u8>,
        ref_identifier: address,
        metadata: vector<u8>,
    ) {
        post_internal(signer, text, some(ref_identifier), metadata);
    }

    /// Burn a Message object.
    public entry fun burn(signer: &signer, message: Message) {
        let addr = signer::address_of(signer);
        assert!(message.sender == addr, E_SENDER_MISMATCH);
        let Message { sender: _, text: _, timestamp: _, ref_id: _, metadata: _ } = message;
    }
}