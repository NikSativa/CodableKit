import CodableKit
import Foundation
import XCTest

final class LossyValueTests: XCTestCase {
    enum Payment: String, Codable, Equatable {
        case newCard = "NewCard"
        case applePay = "ApplePay"
    }

    private struct WrappedUser: Codable, Equatable {
        let name: String

        @LossyValue
        var payment: Payment?
    }

    private struct SDKUser: Codable, Equatable {
        let name: String
        let payment: Payment?
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
        let expectedUser = WrappedUser(name: "bob", payment: nil)
        XCTAssertEqual(wrappedUser, expectedUser)

        let sdkUser: SDKUser? = subjectAction(json)
        XCTAssertNil(sdkUser)
    }

    func test_when_decoding_data_is_lack() {
        let json = [
            "name": "bob",
            // payment field is required
            "other name of field": "NewCard"
        ]
        let wrappedUser: WrappedUser? = subjectAction(json)
        XCTAssertNil(wrappedUser)

        let sdkUser: SDKUser? = subjectAction(json)
        let expectedSdkUser = SDKUser(name: "bob", payment: nil)
        XCTAssertEqual(sdkUser, expectedSdkUser)
    }
}
