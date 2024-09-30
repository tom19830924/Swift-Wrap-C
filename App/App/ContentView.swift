import SwiftUI
import SwiftOpenssl

struct ContentView: View {
    let publicKey = "public_pkcs8_key.pem"
    let privateKey = "private_pkcs8_key.pem"
    
    @State var encryptedDataBase64String: String?
    @State var plain = "Rome wasn't built in a day"
    @State var message: String?
    
    var randomPlain = [
        "The quick brown fox jumps over the lazy dog",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
        "1234567890",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    ]
    
    var body: some View {
        VStack {
            HStack {
                TextField("123", text: $plain, prompt: nil)
                Button("Random one") {
                    plain = randomPlain.randomElement()!
                }
            }
            .padding()
            
            Text(encryptedDataBase64String ?? "")
                .padding()
            
            Text(message ?? "")
                .padding()
            
            HStack {
                VStack {
                    Button("encrypt_swift_Security") {
                        let publicKey = loadSecurityPublicKey(file: publicKey)!
                        encryptedDataBase64String = encrypt(message: plain, with: publicKey)
                    }
                    
                    Button("decrypt_swift_Security") {
                        if
                            let privateKey = loadSecurityPrivateKey(file: privateKey),
                            let encryptedDataBase64String,
                            let decryptedData = decrypt(message: encryptedDataBase64String, with: privateKey),
                            let decryptedMessage = String(data: decryptedData, encoding: .utf8) {
                            message = decryptedMessage
                        }
                    }
                }
                VStack {
                    Button("encrypt_c_openssl") {
                        let p = loadPublicKey(fileName: publicKey)!
                        encryptedDataBase64String = encryptMessage(message: plain, publicKey: p)
                    }
                    
                    Button("decrypt_c_openssl") {
                        let p = loadPrivateKey(fileName: privateKey)!
                        if
                            let encryptedDataBase64String,
                            let decryptedData = decryptMessage(encryptedMessage: encryptedDataBase64String, privateKey: p),
                            let decryptedMessage = String(data: decryptedData, encoding: .utf8) {
                            message = decryptedMessage
                        }
                    }
                }
            }
        }
        
    }
}

import Security

extension ContentView {
    func loadSecurityPublicKey(file: String) -> SecKey? {
        guard
            let filePath = Bundle.main.path(forResource: file, ofType: nil),
            let keyData = readPEMFile(filePath)
        else {
            return nil
        }
        
        let options: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048,
        ]
        
        var error: Unmanaged<CFError>?
        let secKey = SecKeyCreateWithData(keyData as CFData, options as CFDictionary, &error)
        if let error {
            print(error.takeRetainedValue())
        }
        return secKey
    }

    func loadSecurityPrivateKey(file: String) -> SecKey? {
        guard
            let filePath = Bundle.main.path(forResource: file, ofType: nil),
            let keyData = readPEMFile(filePath)
        else {
            return nil
        }
        
        let options: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 2048,
        ]
        
        var error: Unmanaged<CFError>?
        let secKey = SecKeyCreateWithData(
            keyData as CFData,
            options as CFDictionary,
            &error
        )
        if let error {
            print(error.takeRetainedValue())
        }
        return secKey
    }

    func readPEMFile(_ filePath: String) -> Data? {
        do {
            let pemString = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = pemString.components(separatedBy: "\n")
            let base64String = lines.filter { !$0.hasPrefix("-----") }.joined()
            return Data(base64Encoded: base64String)
        }
        catch {
            print("Error reading PEM file: \(error)")
            return nil
        }
    }

    func encrypt(message: String, with publicKey: SecKey) -> String? {
        let data = message.data(using: .utf8)!
        
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionOAEPSHA256, data as CFData, &error) else {
            print("Encryption error: \(error!.takeRetainedValue() as Error)")
            return nil
        }
        return (encryptedData as Data).base64EncodedString()
    }

    func decrypt(message: String, with privateKey: SecKey) -> Data? {
        let data = Data(base64Encoded: message)!
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA256, data as CFData, &error) else {
            print("Decryption error: \(error!.takeRetainedValue() as Error)")
            return nil
        }
        return decryptedData as Data
    }
}

#Preview {
    ContentView()
}
