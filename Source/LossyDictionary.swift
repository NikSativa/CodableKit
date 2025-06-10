import Foundation

@available(*, deprecated, renamed: "LossyDictionary", message: "Just new naming")
typealias PartialDictionary<K: Hashable, V> = LossyDictionary<K, V>

/// A property wrapper that decodes dictionaries by skipping key-value pairs where the value fails to decode.
///
/// Use `LossyDictionary` when working with potentially malformed or inconsistent dictionary values from external sources.
/// If decoding a value fails, the corresponding key-value pair is silently discarded. Only successfully decoded entries are preserved.
///
/// When encoding, the dictionary is encoded as-is without modification.
@propertyWrapper
public struct LossyDictionary<K: Hashable, V> {
    /// The underlying dictionary containing only successfully decoded key-value pairs.
    public var wrappedValue: [K: V]

    /// Creates a new `LossyDictionary` with the specified dictionary.
    ///
    /// - Parameter wrappedValue: The dictionary to store.
    public init(wrappedValue: [K: V] = [:]) {
        self.wrappedValue = wrappedValue
    }
}

extension LossyDictionary: Decodable where K: Decodable, V: Decodable {
    /// Creates a `LossyDictionary` by decoding a dictionary of lossy values.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer().decode([K: LossyValue<V>].self)
        self.wrappedValue = (container ?? [:]).compactMapValues(\.wrappedValue)
    }
}

extension LossyDictionary: Encodable where K: Encodable, V: Encodable {
    /// Encodes the wrapped dictionary to the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension LossyDictionary: Equatable where V: Equatable {}
extension LossyDictionary: Hashable where V: Hashable {}

extension LossyDictionary: ExpressibleByDictionaryLiteral {
    /// Initializes a `LossyDictionary` from a dictionary literal.
    ///
    /// - Parameter elements: A variadic list of key-value pairs.
    public init(dictionaryLiteral elements: (K, V)...) {
        self.init(wrappedValue: .init(uniqueKeysWithValues: elements))
    }
}

#if swift(>=6.0)
extension LossyDictionary: Sendable where Key: Sendable, Value: Sendable {}
#endif
