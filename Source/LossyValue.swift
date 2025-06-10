import Foundation

@available(*, deprecated, renamed: "LossyCodable", message: "Just new naming")
typealias OptionalCodable<A> = LossyValue<A>

/// A property wrapper that safely decodes a value, setting it to `nil` if decoding fails.
///
/// Use `LossyValue` to decode fields from external sources where the data may be invalid, malformed, or incompatible with the expected type.
/// This wrapper prevents decoding failures from propagating by silently defaulting the value to `nil` instead.
///
/// When encoding, the wrapped value is encoded as-is.
@propertyWrapper
public struct LossyValue<A> {
    /// The decoded value, or `nil` if decoding failed or the value was missing.
    public var wrappedValue: A?
    
    /// Creates a new `LossyValue` instance with an optional initial value.
    ///
    /// - Parameter wrappedValue: The value to wrap.
    public init(wrappedValue: A?) {
        self.wrappedValue = wrappedValue
    }
}

extension LossyValue: Decodable where A: Decodable {
    /// Initializes a `LossyValue` by attempting to decode the underlying value.
    ///
    /// If decoding fails, the wrapped value is set to `nil` instead of throwing an error.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try? decoder.singleValueContainer().decode(A.self)
    }
}

extension LossyValue: Encodable where A: Encodable {
    /// Encodes the wrapped value to the given encoder.
    ///
    /// If the value is `nil`, it is encoded as `null`.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension LossyValue: Equatable where A: Equatable {}
extension LossyValue: Hashable where A: Hashable {}

extension LossyValue: ExpressibleByNilLiteral {
    /// Creates a `LossyValue` initialized with `nil`, supporting `ExpressibleByNilLiteral` conformance.
    public init(nilLiteral: ()) {
        self.init(wrappedValue: nil)
    }
}

#if swift(>=6.0)
extension LossyValue: Sendable where A: Sendable {}
#endif
