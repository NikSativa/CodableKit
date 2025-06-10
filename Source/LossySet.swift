import Foundation

/// A property wrapper that decodes sets by skipping elements that fail to decode.
///
/// Use `LossySet` to safely decode sets where some elements may be malformed or invalid.
/// During decoding, elements that cannot be decoded are silently discarded; only valid elements are preserved.
///
/// When encoding, the set is encoded as-is without modification.
@propertyWrapper
public struct LossySet<A: Hashable> {
    /// The underlying set containing only successfully decoded values.
    public var wrappedValue: Set<A>
    
    /// Creates a new `LossySet` with the specified set of elements.
    ///
    /// - Parameter wrappedValue: The set to store.
    public init(wrappedValue: Set<A> = []) {
        self.wrappedValue = wrappedValue
    }
}

extension LossySet: Decodable where A: Decodable {
    /// Creates a `LossySet` by decoding a set of lossy values.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer().decode(Set<LossyValue<A>>.self)
        let result = (container ?? []).compactMap(\.wrappedValue)
        self.wrappedValue = Set(result)
    }
}

extension LossySet: Encodable where A: Encodable {
    /// Encodes the wrapped set to the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension LossySet: Equatable where A: Equatable {}
extension LossySet: Hashable where A: Hashable {}

extension LossySet: ExpressibleByArrayLiteral {
    /// Initializes a `LossySet` using an array literal.
    ///
    /// - Parameter elements: A variadic list of elements to include in the set.
    public init(arrayLiteral elements: A...) {
        self.init(wrappedValue: .init(elements))
    }
}

#if swift(>=6.0)
extension LossySet: Sendable where A: Sendable {}
#endif
