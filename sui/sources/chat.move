module nfts::chat {
    use std::ascii::{Self, String};
    use std::option::{Self, Option, some};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::vector::length;

    /// Max text length.
    const MAX_TEXT_LENGTH: u64 = 512;

    /// Text size overflow.
    const ETextOverflow: u64 = 0;

    struct ChatRoom has key, store {
        messages: vector<Message>,
        message_count: u64,
    }

    /// Sui Chat NFT (i.e., a post, retweet, like, chat message etc).
    struct Chat has key, store, copy {
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

    fun init(ctx: &mut TxContext) {
        let room = ChatRoom {
            messages: vector::empty(),
            message_count: 0,
        };
        move_to<ChatRoom>(account, room);
    }

    /// Create a new chat room.
    public entry fun create_chat_room(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<ChatRoom>(addr), E_CHAT_ROOM_EXISTS);
        let room = ChatRoom {
            messages: vector::empty(),
            message_count: 0,
        };
        move_to(account, room);
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
        app_id: address,
        text: vector<u8>,
        ref_id: Option<address>,
        metadata: vector<u8>,
        ctx: &mut TxContext,
    ) {
        assert!(length(&text) <= MAX_TEXT_LENGTH, ETextOverflow);
        let chat = Chat {
            id: object::new(ctx),
            app_id,
            text: ascii::string(text),
            ref_id,
            metadata,
        };
        transfer::public_transfer(chat, tx_context::sender(ctx));
    }

    /// Mint (post) a Chat object without referencing another object.
    public entry fun post(
        app_identifier: address,
        text: vector<u8>,
        metadata: vector<u8>,
        ctx: &mut TxContext,
    ) {
        post_internal(app_identifier, text, option::none(), metadata, ctx);
    }

    public entry fun post_with_ref(
        app_identifier: address,
        text: vector<u8>,
        ref_identifier: address,
        metadata: vector<u8>,
        ctx: &mut TxContext,
    ) {
        post_internal(app_identifier, text, some(ref_identifier), metadata, ctx);
    }
}