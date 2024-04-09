import Foundation

/// Allows you to decode fields with a partially incorrect format or incorrect value. If the field is incorrect, the value will be nil.
@propertyWrapper
public struct OptionalCodable<A> {
    public var wrappedValue: A?

    public init(wrappedValue: A?) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Decodable

extension OptionalCodable: Decodable where A: Decodable {
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try? decoder.singleValueContainer().decode(A.self)
    }
}

// MARK: - Encodable

extension OptionalCodable: Encodable where A: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension OptionalCodable: Equatable where A: Equatable {}
extension OptionalCodable: Hashable where A: Hashable {}

// MARK: - ExpressibleByNilLiteral

extension OptionalCodable: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(wrappedValue: nil)
    }
}
