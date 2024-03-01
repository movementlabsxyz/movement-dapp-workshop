module chat::chat {
    use std::option::{Self, Option, some};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use sui::clock::{Self, Clock};

    /// Max text length.
    const MAX_TEXT_LENGTH: u64 = 512;

    /// Text size overflow.
    const ETextOverflow: u64 = 0;

    struct Message has key, store {
        id: UID,
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

    struct ChatRoom has key, store {
        id: UID,
        messages: vector<Message>,
        message_count: u64,
    }

    fun init(ctx: &mut TxContext) {
        let room = ChatRoom {
            id: object::new(ctx),
            messages: vector::empty(),
            message_count: 0,
        };
        transfer::share_object(room);
    }

    /// Create a new chat room.
    public entry fun create_chat_room(ctx: &mut TxContext) {

        let id = object::new(ctx);

        let room = ChatRoom {
            id: id,
            messages: vector::empty(),
            message_count: 0,
        };
        transfer::public_transfer(room, tx_context::sender(ctx));
    }
    
    public fun get_messages(room: &ChatRoom) : &vector<Message> {
        &room.messages
    }

    #[allow(lint(self_transfer))]
    /// Mint (post) a Chat object.
    fun post_internal(
        text: vector<u8>,
        ref_id: Option<address>,
        metadata: vector<u8>,
        chat_room: &mut ChatRoom,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        assert!(vector::length(&text) <= MAX_TEXT_LENGTH, ETextOverflow);
        let message = Message {
            id: object::new(ctx),
            sender: tx_context::sender(ctx),
            text: text,
            timestamp: clock::timestamp_ms(clock),
            ref_id,
            metadata,
        };
        let messages = &mut chat_room.messages;
        chat_room.message_count = chat_room.message_count + 1;
        vector::push_back(messages, message);
    }

    /// Mint (post) a Chat object without referencing another object.
    public entry fun post(
        text: vector<u8>,
        metadata: vector<u8>,
        chat_room: &mut ChatRoom,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        post_internal(text, option::none(), metadata, chat_room, clock, ctx);
    }

    public entry fun post_with_ref(
        text: vector<u8>,
        ref_identifier: address,
        metadata: vector<u8>,
        chat_room: &mut ChatRoom,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        post_internal(text, some(ref_identifier), metadata, chat_room, clock, ctx);
    }

}