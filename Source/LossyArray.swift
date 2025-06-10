import Foundation

/// Alias for `LossyArray`, kept for backward compatibility.
@available(*, deprecated, renamed: "LossyArray", message: "Just new naming")
typealias PartialArray<A> = LossyArray<A>

/// A property wrapper that decodes arrays by skipping elements that fail to decode.
///
/// Use `LossyArray` to safely decode arrays where some elements may be invalid or malformed.
/// Invalid elements are silently discarded during decoding; only successfully decoded elements are kept.
///
/// When encoding, the array is encoded as-is, without modification.
///
/// - Note: This wrapper is useful when working with data from external APIs that may return partially corrupt or inconsistent arrays.
@propertyWrapper
public struct LossyArray<A> {
    /// The underlying array containing only successfully decoded values.
    public var wrappedValue: [A]

    /// Creates a new `LossyArray` with the given array of elements.
    ///
    /// - Parameter wrappedValue: The array of elements to store.
    public init(wrappedValue: [A] = []) {
        self.wrappedValue = wrappedValue
    }
}

extension LossyArray: Decodable where A: Decodable {
    /// Creates a `LossyArray` by decoding an array of potentially lossy values.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer().decode([LossyValue<A>].self)
        self.wrappedValue = (container ?? []).compactMap(\.wrappedValue)
    }
}

extension LossyArray: Encodable where A: Encodable {
    /// Encodes the wrapped array to the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension LossyArray: Equatable where A: Equatable {}
extension LossyArray: Hashable where A: Hashable {}

extension LossyArray: ExpressibleByArrayLiteral {
    /// Initializes a `LossyArray` using an array literal.
    ///
    /// - Parameter elements: A variadic list of elements to include in the array.
    public init(arrayLiteral elements: A...) {
        self.init(wrappedValue: elements)
    }
}

#if swift(>=6.0)
extension LossyArray: Sendable where A: Sendable {}
#endif
