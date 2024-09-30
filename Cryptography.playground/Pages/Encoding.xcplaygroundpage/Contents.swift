/*:
 [Previous](@previous)
 # Encoding / Decoding
 - Important:
 編碼是資訊從一種形式或格式轉換為另一種形式的過程；解碼則是編碼的反向過程
 
 嚴格來說編碼不算是密碼學的一部分, 但是很多人都會搞混
 */
//: ## Character encoding
//:    - [ASCII](https://zh.wikipedia.org/wiki/ASCII)
//:    - [Unicode](https://zh.wikipedia.org/wiki/Unicode)
import Foundation

extension String {
    func unicodeScalarCodePoint() -> String {
        var result: [String] = []
        for scalar in unicodeScalars {
            let unicodeValue = String(format: "U+%04X", scalar.value)
            result.append(unicodeValue)
        }
        return result.joined(separator: ",")
    }
    
    func encoded(using encoding: String.Encoding) -> String {
        var result: [String] = []
        for c in self {
            let data = String(c).data(using: encoding)!
            result.append(data.map { String(format: "%02X", $0) }.joined(separator: ""))
        }
        return result.joined(separator: ",")
    }
}
"上善若水".unicodeScalarCodePoint()
"人淡如菊".encoded(using: .utf8)

"你".unicodeScalarCodePoint()
"你".encoded(using: .utf8)
String(UnicodeScalar(0x4F60)!)
String(data: Data([0xE4, 0xBD, 0xA0]), encoding: .utf8)

// U+4F60                       , unicode
// 0100 1111 0110 0000          , unicode轉為二進制
// 1110xxxx 10xxxxxx 10xxxxxx   , 轉換關係表
// 0100 111101 100000
// 1110 0100 1011 1101 1010 0000
// E    4    B    D    A    0
/*:
 - [Base64](https://zh.wikipedia.org/zh-tw/Base64) 將二進制資料轉為字元, 所以常用於資料交換(例如之後會講到的密鑰)
 - [Percent-encoding](https://zh.wikipedia.org/zh-tw/%E7%99%BE%E5%88%86%E5%8F%B7%E7%BC%96%E7%A0%81)(URL encoding)
 
 [Next](@next)
 */
