/*:
 [Previous](@previous)

 # Symmetric Encryption
 - Important:
 對稱式加密（Symmetric Encryption）是一種加密技術，其中加密和解密使用相同的密鑰
 
 - 區塊加密(AES)
 - 串流加密(ChaChaPoly)
 
 ### 加密模式, 填充模式
*/

/*:
 - [AES](https://zh.wikipedia.org/zh-tw/%E9%AB%98%E7%BA%A7%E5%8A%A0%E5%AF%86%E6%A0%87%E5%87%86)

--- 明文 ---
 */
import Foundation
import CryptoKit
let plain = "Rome wasn't built in a day"
let plainData = plain.data(using: .utf8)!
//: --- Key ---
// 自訂key (128bits/16bytes, 可用128/192/256 bits, 16/24/32 bytes)
let keyString = "secrekeysecrekey"
let keyData = keyString.data(using: .utf8)!
// 隨機keyData
//let keyData = Data((0..<16).map { _ in UInt8.random(in: 0...255) })
//: --- 將Key生成同步金鑰 ---
let symmetricKey = SymmetricKey(data: keyData)
//let symmetricKey = SymmetricKey(size: .bits128)
//symmetricKey.withUnsafeBytes {  Data(Array($0)) }.hexString
//: --- 隨機數(IV) ---
// Nonce, 也可以說是IV, 用Nonce的建構式至少要12bytes
let nonce = try AES.GCM.Nonce(data: "abcdefghijkl".data(using: .utf8)!)
//let nonce = AES.GCM.Nonce() // 12bytes, Apple預設
//nonce.withUnsafeBytes { Data($0) }.base64EncodedString()

//: --- 加密 ---
let sealedBox = try AES.GCM.seal(plainData, using: symmetricKey, nonce: nonce)
let tag = sealedBox.tag
let ciphertext = sealedBox.ciphertext
let combinedData = nonce + ciphertext + tag
//let combinedData = sealedBox.combined!
let base64EncodedString = combinedData.base64EncodedString()
//: --- 解密 ---
var data = Data(base64Encoded: base64EncodedString)!
let _nonce = try AES.GCM.Nonce(data: data.prefix(12))
data = data.dropFirst(12)
let _tag = data.suffix(16)
data = data.dropLast(16)
let _cipherText = data
let sealedBoxToOpen = try! AES.GCM.SealedBox(nonce: _nonce, ciphertext: _cipherText, tag: _tag)
let decryptedData = try! AES.GCM.open(sealedBoxToOpen, using: symmetricKey)
let decryptedString = String(data: decryptedData, encoding: .utf8)!
//: - [ChaChaPoly](https://zh.wikipedia.org/zh-tw/ChaCha20-Poly1305)
let chaKey = SymmetricKey(size: .bits256)
let chaNonce = try ChaChaPoly.Nonce(data: "abcdefghijkl".data(using: .utf8)!)
let chaSealBox = try! ChaChaPoly.seal(plainData, using: chaKey, nonce: chaNonce)
let chaCombineData = chaSealBox.combined
let chaBase64EncodedString = chaCombineData.base64EncodedString()

// 解密
let chaSealedBoxToOpen = try! ChaChaPoly.SealedBox(combined: chaCombineData)
let chaDecryptedData = try! ChaChaPoly.open(chaSealedBoxToOpen, using: chaKey)
let decryptedMessage = String(data: chaDecryptedData, encoding: .utf8)!


extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined(separator: " ")
    }
}
//: [Next](@next)
