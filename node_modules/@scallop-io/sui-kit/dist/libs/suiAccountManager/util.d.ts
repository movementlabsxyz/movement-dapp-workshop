/**
 * @description This regular expression matches any string that contains only hexadecimal digits (0-9, A-F, a-f).
 * @param str
 */
export declare const isHex: (str: string) => boolean;
/**
 * @description This regular expression matches any string that contains only base64 digits (0-9, A-Z, a-z, +, /, =).
 * Note that the "=" signs at the end are optional padding characters that may be present in some base64 encoded strings.
 * @param str
 */
export declare const isBase64: (str: string) => boolean;
/**
 * Convert a hex string to Uint8Array
 * @param hexStr
 */
export declare const fromHEX: (hexStr: string) => Uint8Array;
/**
 * @description Convert a hex or base64 string to Uint8Array
 */
export declare const hexOrBase64ToUint8Array: (str: string) => Uint8Array;
/**
 * normalize a private key
 * A private key is a 32-byte array.
 * But there are two different formats for private keys:
 * 1. A 32-byte array
 * 2. A 64-byte array with the first 32 bytes being the private key and the last 32 bytes being the public key
 * 3. A 33-byte array with the first byte being 0x00 (sui.keystore key is a Base64 string with scheme flag 0x00 at the beginning)
 */
export declare const normalizePrivateKey: (key: Uint8Array) => Uint8Array;
