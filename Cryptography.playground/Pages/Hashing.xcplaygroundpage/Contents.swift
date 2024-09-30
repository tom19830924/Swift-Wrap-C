/*:
 [Previous](@previous)
 # Hashing
 - Important:
 雜湊函式是一種將`任意長度`的輸入數據轉換為`固定長度`的輸出數據的過程；這個輸出數據稱為雜湊值(digest)。
 
 雜湊函式的設計目標是快速計算並對輸入的微小變化產生顯著不同的輸出。
 
 雜湊廣泛應用於數據結構(雜湊表,Dictionary)、數據完整性檢查(數位簽名)和密碼學中。
 
 ### 碰撞, 彩虹表, 線上加解密工具, 計算成本
 */
//: ## 常用雜湊函數
import CryptoKit
import Foundation
let salt = "salt"
let plain = "password"
//: - [MD5](https://zh.wikipedia.org/zh-tw/MD5)
Insecure.MD5.hash(data: plain.data(using: .utf8)!)
//: - [SHA-1](https://zh.wikipedia.org/zh-tw/SHA-1)
Insecure.SHA1.hash(data: plain.data(using: .utf8)!)
//: - [SHA-2](https://zh.wikipedia.org/wiki/SHA-2)(SHA256)
SHA256.hash(data: Data((salt+plain).utf8))
//: - [BCrypt](https://zh.wikipedia.org/zh-tw/Bcrypt)

//: [Next](@next)
