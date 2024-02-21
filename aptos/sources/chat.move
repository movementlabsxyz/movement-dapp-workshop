module Chat {
    use std::string::{String, utf8};
    use std::option::{Option, none, some};
    use std::vector::Vector;
    use aptos_framework::guid::GUID;
    use aptos_framework::coin::transfer;
    use aptos_framework::account::create_signer;

    const MAX_TEXT_LENGTH: u64 = 512;
    const E_TEXT_OVERFLOW: u64 = 0;

    struct ChatRoom {
        table: storage::HashMap<u64, Vector<Chat>>,
        message_count: u64,
    }

    struct Chat has key, store, drop {
        id: GUID,
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

    /// Simple Chat.text getter.
    public fun text(chat: &Chat): String {
        chat.text
    }

    /// Mint (post) a Chat object.
    fun post_internal(
        app_id: address,
        text: vector<u8>,
        ref_id: Option<address>,
        metadata: vector<u8>,
        signer: &signer,
    ) {
        assert!(utf8::length(&text) <= MAX_TEXT_LENGTH, E_TEXT_OVERFLOW);

        let chat = Chat {
            id: GUID::create(signer),
            app_id,
            text: String::utf8(text),
            ref_id,
            metadata,
        };

        // Storing the Chat object in the creator's account
        storage::save_resource<Chat>(signer, chat);
    }
    
    /// Mint (post) a Chat object without referencing another object.
    public entry fun post(
        app_identifier: address,
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

    /// Burn a Chat object.
    public entry fun burn(chat: Chat, signer: &signer) {
        let Chat { id, app_id: _, text: _, ref_id: _, metadata: _ } = chat;
        GUID::destroy(id, signer);
    }
}