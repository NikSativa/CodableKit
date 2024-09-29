import Foundation

@available(*, deprecated, renamed: "LossyDictionary", message: "Just new naming")
typealias PartialDictionary<K: Hashable, V> = LossyDictionary<K, V>

/// Allows you to decode an array or dictionary with partially incorrect data. If the data is incorrect, the value will be omitted from the result.
@propertyWrapper
public struct LossyDictionary<K: Hashable, V> {
    public var wrappedValue: [K: V]

    public init(wrappedValue: [K: V] = [:]) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Decodable

extension LossyDictionary: Decodable where K: Decodable, V: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer().decode([K: LossyValue<V>].self)
        self.wrappedValue = (container ?? [:]).compactMapValues(\.wrappedValue)
    }
}

// MARK: - Encodable

extension LossyDictionary: Encodable where K: Encodable, V: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension LossyDictionary: Equatable where V: Equatable {}
extension LossyDictionary: Hashable where V: Hashable {}

// MARK: - ExpressibleByDictionaryLiteral

extension LossyDictionary: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (K, V)...) {
        self.init(wrappedValue: .init(uniqueKeysWithValues: elements))
    }
}

#if swift(>=6.0)
extension LossyDictionary: Sendable where Key: Sendable, Value: Sendable {}
#endif
