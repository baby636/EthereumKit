//
//  Crypto.swift
//  EthereumKit
//
//  Created by yuzushioh on 2018/02/06.
//  Copyright © 2018 yuzushioh.
//

import EthereumKit.Private
import secp256k1

final class Crypto {
    static func HMACSHA512(key: Data, data: Data) -> Data {
        return CryptoHash.hmacsha512(data, key: key)
    }
    
    static func PBKDF2SHA512(_ password: Data, salt: Data) -> Data {
        return PKCS5.pbkdf2(password, salt: salt, iterations: 2048, keyLength: 64)
    }
    
    static func hash160(_ data: Data) -> Data {
        return CryptoHash.ripemd160(CryptoHash.sha256(data))
    }
    
    static func generatePublicKey(data: Data, compressed: Bool) -> Data {
        return Secp256k1.generatePublicKey(withPrivateKey: data, compression: compressed)
    }
    
    static func sign(_ data: Data, privateKey: Data) -> Data {
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!
        defer { secp256k1_context_destroy(context) }
        
        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate(capacity: 1) }
        
        let status = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            privateKey.withUnsafeBytes { secp256k1_ecdsa_sign(context, signature, ptr, $0, nil, nil) }
        }
        
        guard status == 1 else {
            fatalError()
        }
        
        var output = Data(count: 65)
        guard output.withUnsafeMutableBytes({ secp256k1_ecdsa_signature_serialize_compact(context, $0, signature) })  == 1 else {
            fatalError()
        }
        return output
    }
}
