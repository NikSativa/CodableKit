import CodableKit
import Foundation
import XCTest

final class NullableTests: XCTestCase {
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
              "payments" : null
            }
            """
        XCTAssertEqual(str, expected, str ?? "")
    }
}
