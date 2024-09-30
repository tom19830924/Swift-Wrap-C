

# 如何在Swift Package中加入一個external library

## 1. package中加入要使用的library
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Copenssl",
    products: [
        .library(name: "Copenssl", targets: ["Copenssl"]),
    ],
    targets: [
        .systemLibrary(
            name: "Copenssl", 
            pkgConfig: "openssl", 
            providers: [.apt(["openssl"]), .brew(["openssl"])
        ]),
    ]
)

```
這邊我要們用的exteranl lib叫做openssl
name: 此library target名稱  
pkcConfig: 可以視為一個依賴管理工具, 告知compiler以及linker要怎樣找到你依賴的lib(openssl), *.pc  
providers: 提示使用此lib(Copenssl)的人, 你需要先用brew/apt安裝openssl

## 2. 在Sources資料夾底下, 建立一個同 library target name的資料夾, 並在其內新增 modulemap / header  
### module.modulemap
```Cpp
module Copenssl [system] {
    umbrella header "shim.h"
    link "openssl"
    export *
}
```
### shim.h
```C
#include <openssl/rsa.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
```
modulemap的目的是為了定義一個module, 並將讓C/C++等程式碼暴露給swift使用  

https://clang.llvm.org/docs/Modules.html


### pkg-config可用指令
```
// 列出所有 pkg-config
pkg-config --list-all  
// 列出所指定的庫頭文件位置
pkg-config openssl --cflags
// 列出所指定的庫Lib位置
pkg-config openssl --libs 
```

# Ref: 

[how-to-use-c-libraries-in-swift](https://theswiftdev.com/how-to-use-c-libraries-in-swift)  
[how-to-wrap-a-c-library-in-swift](https://www.hackingwithswift.com/articles/87/how-to-wrap-a-c-library-in-swift)  
[making-a-c-library-available-in-swift-using-the-swift-package](https://rderik.com/blog/making-a-c-library-available-in-swift-using-the-swift-package)  
[importing-c-library-into-swift](https://oleb.net/blog/2017/12/importing-c-library-into-swift)  
[Modules.html#introduction](https://clang.llvm.org/docs/Modules.html#introduction)

[openssl.pc](/opt/homebrew/Cellar/openssl@3/3.3.2/lib/pkgconfig/openssl.pc)  



umbrella header: An umberlla header is the main header file for a framework or library.  
bridging header: A bridging header allows us to use two languages in the same application.  
shim header: The shim header works around the limitation that module maps must contain absolute or local paths.  