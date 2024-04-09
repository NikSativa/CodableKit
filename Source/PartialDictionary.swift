import Foundation

/// Allows you to decode an array or dictionary with partially incorrect data. If the data is incorrect, the value will be omitted from the result.
@propertyWrapper
public struct PartialDictionary<K: Hashable, V> {
    public var wrappedValue: [K: V]

    public init(wrappedValue: [K: V] = [:]) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Decodable

extension PartialDictionary: Decodable where K: Decodable, V: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer().decode([K: OptionalCodable<V>].self)
        self.wrappedValue = (container ?? [:]).compactMapValues(\.wrappedValue)
    }
}

// MARK: - Encodable

extension PartialDictionary: Encodable where K: Encodable, V: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension PartialDictionary: Equatable where V: Equatable {}
extension PartialDictionary: Hashable where V: Hashable {}

// MARK: - ExpressibleByDictionaryLiteral

extension PartialDictionary: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (K, V)...) {
        self.init(wrappedValue: .init(uniqueKeysWithValues: elements))
    }
}
