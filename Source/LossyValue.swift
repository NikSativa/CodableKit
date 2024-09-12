import Foundation

@available(*, deprecated, renamed: "LossyCodable", message: "Just new naming")
typealias OptionalCodable<A> = LossyValue<A>

/// Allows you to decode fields with a partially incorrect format or incorrect value. If the field is incorrect, the value will be nil.
@propertyWrapper
public struct LossyValue<A> {
    public var wrappedValue: A?

    public init(wrappedValue: A?) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Decodable

extension LossyValue: Decodable where A: Decodable {
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try? decoder.singleValueContainer().decode(A.self)
    }
}

// MARK: - Encodable

extension LossyValue: Encodable where A: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension LossyValue: Equatable where A: Equatable {}
extension LossyValue: Hashable where A: Hashable {}

// MARK: - ExpressibleByNilLiteral

extension LossyValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(wrappedValue: nil)
    }
}
