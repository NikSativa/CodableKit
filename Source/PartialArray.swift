import Foundation

/// Allows you to decode an array or dictionary with partially incorrect data. If the data is incorrect, the value will be omitted from the result.
@propertyWrapper
public struct PartialArray<A> {
    public var wrappedValue: [A]

    public init(wrappedValue: [A] = []) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Decodable

extension PartialArray: Decodable where A: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer().decode([OptionalCodable<A>].self)
        self.wrappedValue = (container ?? []).compactMap(\.wrappedValue)
    }
}

// MARK: - Encodable

extension PartialArray: Encodable where A: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension PartialArray: Equatable where A: Equatable {}
extension PartialArray: Hashable where A: Hashable {}

// MARK: - ExpressibleByArrayLiteral

extension PartialArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: A...) {
        self.init(wrappedValue: elements)
    }
}
