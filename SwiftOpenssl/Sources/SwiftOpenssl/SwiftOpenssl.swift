// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Copenssl

public func loadPublicKey(fileName: String) -> OpaquePointer? {
    let filePath = Bundle.main.path(forResource: fileName, ofType: nil)!
    let file = fopen(filePath, "r")
    let pkey = PEM_read_PUBKEY(file, nil, nil, nil)
    fclose(file)
    return pkey
}

public func loadPrivateKey(fileName: String) -> OpaquePointer? {
    let filePath = Bundle.main.path(forResource: fileName, ofType: nil)!
    let pemString = try! String(contentsOfFile: filePath, encoding: .utf8)
    
    let bio = BIO_new(BIO_s_mem())
    BIO_puts(bio, pemString)
    let rsa = PEM_read_bio_PrivateKey(bio, nil, nil, nil)
    BIO_free(bio)
    return rsa
}

public func encryptMessage(message: String, publicKey: OpaquePointer) -> String? {
    let data = message.data(using: .utf8)!
    
    let ctx = EVP_PKEY_CTX_new(publicKey, nil)
    defer { EVP_PKEY_CTX_free(ctx) }
    
    EVP_PKEY_encrypt_init(ctx)
    EVP_PKEY_CTX_set_rsa_padding(ctx, RSA_PKCS1_OAEP_PADDING)
    EVP_PKEY_CTX_set_rsa_oaep_md(ctx, EVP_sha256())
    
    var outlen: size_t = 0
    EVP_PKEY_encrypt(
        ctx,
        nil,
        &outlen,
        [UInt8](data),
        data.count
    )
    
    var out = Data(count: outlen)
    EVP_PKEY_encrypt(
        ctx,
        out.withUnsafeMutableBytes(\.baseAddress)?.assumingMemoryBound(to: UInt8.self),
        &outlen,
        [UInt8](data),
        data.count
    )
    
    return out.base64EncodedString()
}

public func decryptMessage(encryptedMessage: String, privateKey: OpaquePointer) -> Data? {
    let data = Data(base64Encoded: encryptedMessage)!

    let ctx = EVP_PKEY_CTX_new(privateKey, nil)
    defer { EVP_PKEY_CTX_free(ctx) }

    EVP_PKEY_decrypt_init(ctx)
    EVP_PKEY_CTX_set_rsa_padding(ctx, RSA_PKCS1_OAEP_PADDING)
    EVP_PKEY_CTX_set_rsa_oaep_md(ctx, EVP_sha256())
    
    var outlen: size_t = 0
    EVP_PKEY_decrypt(
        ctx,
        nil,
        &outlen,
        [UInt8](data),
        data.count
    )
    
    var out = Data(count: outlen)
    EVP_PKEY_decrypt(
        ctx,
        out.withUnsafeMutableBytes(\.baseAddress)?.assumingMemoryBound(to: UInt8.self),
        &outlen,
        [UInt8](data),
        data.count
    )

    return out
}
