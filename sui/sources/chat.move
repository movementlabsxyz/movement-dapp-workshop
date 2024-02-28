module nfts::chat {
    use std::ascii::{Self, String};
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

    struct ChatRoom has key, store {
        messages: vector<Message>,
        message_count: u64,
    }

    /// Sui Chat NFT (i.e., a post, retweet, like, chat message etc).
    struct Chat has key, store {
        id: UID,
        // The ID of the chat app.
        app_id: address,
        // Post's text.
        text: String,
        // Set if referencing an another object (i.e., due to a Like, Retweet, Reply etc).
        // We allow referencing any object type, not only Chat NFTs.
        ref_id: Option<address>,
        // app-specific metadata. We do not enforce a metadata format and delegate this to app layer.
        metadata: vector<u8>,
    }

    fun init(ctx: &mut TxContext) {
        let room = ChatRoom {
            messages: vector::empty(),
            message_count: 0,
        };
        transfer::public_transfer(room, tx_context::sender(ctx));
    }

    /// Create a new chat room.
    public entry fun create_chat_room(ctx: &mut TxContext) {
        let addr = ctx;
        assert!(!exists<ChatRoom>(addr), E_CHAT_ROOM_EXISTS);
        let room = ChatRoom {
            messages: vector::empty(),
            message_count: 0,
        };
        transfer::public_transfer(room, tx_context::sender(ctx));
    }

    /// Simple Message object getter.
    #[view]
    public fun get_messages(addr: address) : vector<Message> acquires ChatRoom {
        let room = borrow_global<ChatRoom>(addr);
        room.messages
    }

    #[allow(lint(self_transfer))]
    /// Mint (post) a Chat object.
    fun post_internal(
        text: vector<u8>,
        ref_id: Option<address>,
        metadata: vector<u8>,
        chat_room: id,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        assert!(length(&text) <= MAX_TEXT_LENGTH, ETextOverflow);
        let chat = Chat {
            sender: tx_context::sender(ctx),
            text: text,
            timestamp: clock::timestamp_ms(clock),
            ref_id,
            metadata,
        };

        let room = borrow_global_mut<ChatRoom>(chat_room);
        room.message_count = room.message_count + 1;
        vector::push_back(room.messages, chat);
        transfer::public_transfer(chat, tx_context::sender(ctx));
    }

    /// Mint (post) a Chat object without referencing another object.
    public entry fun post(
        text: vector<u8>,
        metadata: vector<u8>,
        chat_room: address,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        post_internal(text, option::none(), metadata, chat_room, clock, ctx);
    }

    public entry fun post_with_ref(
        app_identifier: address,
        text: vector<u8>,
        ref_identifier: address,
        metadata: vector<u8>,
        chat_room: ChatRoom,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        post_internal(text, some(ref_identifier), metadata, chat_room, clock, ctx);
    }
    
}