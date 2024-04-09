# CodableKit

Swift library that provides additional features for Codable. CodableKit is useful when you need to decode data from the server, but you are not sure that the data will be correct.

## OptionalCodable
Allows you to decode fields with a partially incorrect format or incorrect value. If the field is incorrect, the value will be nil. 

```swift
enum Payment: String, Codable, Equatable {
    case newCard = "NewCard"
    case applePay = "ApplePay"
}

private struct WrappedUser: Codable, Equatable {
    let name: String

    @OptionalCodable
    var payment: Payment? <<-------------- OptionalCodable behavior
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
    let expectedUser = WrappedUser(name: "bob", payment: nil) <<-------------- OptionalCodable behavior
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
    let wrappedUser: WrappedUser? = subjectAction(json) <<-------------- OptionalCodable behavior
    XCTAssertNil(wrappedUser)

    let sdkUser: SDKUser? = subjectAction(json)
    let expectedSdkUser = SDKUser(name: "bob", payment: nil) <<-------------- SDK behavior
    XCTAssertEqual(sdkUser, expectedSdkUser)
}
```

## PartialArray/PartialDictionary
Allows you to decode an array or dictionary with partially incorrect data. If the data is incorrect, the value will be omitted from the result.

```swift
private struct User: Decodable, Equatable {
    enum Payment: String, Decodable, Equatable {
        case newCard = "NewCard"
        case applePay = "ApplePay"
    }

    let name: String

    @PartialArray
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
Allows you to encode 'nil' field as 'null' in JSON when server requires it.

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
