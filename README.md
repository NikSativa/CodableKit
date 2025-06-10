# CodableKit

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FCodableKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/NikSativa/CodableKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FCodableKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/NikSativa/CodableKit)
[![NikSativa CI](https://github.com/NikSativa/CodableKit/actions/workflows/swift_macos.yml/badge.svg)](https://github.com/NikSativa/CodableKit/actions/workflows/swift_macos.yml)
[![License](https://img.shields.io/github/license/Iterable/swift-sdk)](https://opensource.org/licenses/MIT)

CodableKit is a Swift library that extends the capabilities of the standard `Codable` protocol.

It provides a suite of property wrappers designed to safely decode or encode values when dealing with uncertain, inconsistent, or partially malformed data—particularly useful when working with external APIs.

## LossyValue

A property wrapper that safely decodes an individual value even when the data is invalid or contains unexpected values.

If decoding fails for this field, the property will be set to `nil` instead of throwing an error or failing the entire decoding process.

```swift
enum Payment: String, Codable, Equatable {
    case newCard = "NewCard"
    case applePay = "ApplePay"
}

private struct WrappedUser: Codable, Equatable {
    let name: String

    @LossyValue
    var payment: Payment? <<-------------- LossyValue behavior
}

private struct SDKUser: Codable, Equatable {
    let name: String
    let payment: Payment? <<-------------- SDK behavior
}

func test_when_decoding_data_is_valid() {
    let json = [
        "name": "bob",
        "payment": "NewCard"
    ]
    let wrappedUser: WrappedUser? = subjectAction(json)
    let expectedUser = WrappedUser(name: "bob", payment: .newCard)
    XCTAssertEqual(wrappedUser, expectedUser)

    let sdkUser: SDKUser? = subjectAction(json)
    let expectedSdkUser = SDKUser(name: "bob", payment: .newCard)
    XCTAssertEqual(sdkUser, expectedSdkUser)
}

func test_when_decoding_data_is_invalid() {
    let json = [
        "name": "bob",
        "payment": "GooglePay"
    ]
    let wrappedUser: WrappedUser? = subjectAction(json)
    let expectedUser = WrappedUser(name: "bob", payment: nil) <<-------------- LossyValue behavior
    XCTAssertEqual(wrappedUser, expectedUser)

    let sdkUser: SDKUser? = subjectAction(json) <<-------------- SDK behavior
    XCTAssertNil(sdkUser)
}

func test_when_decoding_data_is_lack() {
    let json = [
        "name": "bob",
        // payment field is required
        "other name of field": "NewCard"
    ]
    let wrappedUser: WrappedUser? = subjectAction(json) <<-------------- LossyValue behavior
    XCTAssertNil(wrappedUser)

    let sdkUser: SDKUser? = subjectAction(json)
    let expectedSdkUser = SDKUser(name: "bob", payment: nil) <<-------------- SDK behavior
    XCTAssertEqual(sdkUser, expectedSdkUser)
}
```

## LossyArray / LossyDictionary / LossySet

Property wrappers that allow partial decoding of collections.

Invalid or unrecognized elements are silently dropped, while valid elements are preserved. This ensures maximum resilience when dealing with arrays, dictionaries, or sets containing potentially invalid data.

```swift
private struct User: Decodable, Equatable {
    enum Payment: String, Decodable, Equatable {
        case newCard = "NewCard"
        case applePay = "ApplePay"
    }

    let name: String

    @LossyArray
    var payments: [Payment]
}

let subject: User? = subjectAction([
    "name": "bob",
    "payments": [
        "NewCard", "GooglePay"
    ]
])
let expectedUser = User(name: "bob", payments: [.newCard]) <<-------------- unknown "GooglePay" is omitted
XCTAssertEqual(subject, expectedUser)
```

## Nullable

A property wrapper that explicitly encodes a `nil` value as `null` in the resulting JSON output.

Use this when the receiving server requires the presence of a field—even when its value is `nil`. By contrast, standard `Optional` encoding omits the key entirely when the value is `nil`.

```swift
private struct User: Encodable, Equatable {
    enum Payment: String, Encodable, Equatable {
        case newCard = "NewCard"
        case applePay = "ApplePay"
    }

    let name: String

    @Nullable
    var payments: Payment?

    /// absent in JSON when value is `nil`
    var payments2: Payment?
}

func test_common() throws {
    let subject: User = .init(name: "bob",
                              payments: .applePay,
                              payments2: nil)
    let data = try Data.make(from: subject)
    let str = String(data: data, encoding: .utf8)
    let expected =
        """
        {
          "name" : "bob",
          "payments" : "ApplePay"
        }
        """
    XCTAssertEqual(str, expected, str ?? "")
}

func test_null() throws {
    let subject: User = .init(name: "bob",
                              payments: nil,
                              payments2: nil)
    let data = try Data.make(from: subject)
    let str = String(data: data, encoding: .utf8)
    let expected =
        """
        {
          "name" : "bob",
          "payments" : null  <<-------------- `null` instead of absent
        }
        """
    XCTAssertEqual(str, expected, str ?? "")
}    
```
