import Foundation

/// A property wrapper that explicitly encodes `nil` as `null` when used with `Codable`.
///
/// Use `Nullable` when the receiving server requires a key to be present in the encoded JSON, even if its value is `null`.
/// This differs from default `Optional` encoding behavior, which omits the key entirely when the value is `nil`.
@propertyWrapper
public struct Nullable<T> {
    /// The wrapped optional value.
    ///
    /// When encoded, this value will be represented as `null` if it is `nil`.
    public var wrappedValue: T?
    
    /// Creates a new `Nullable` property wrapper with the specified optional value.
    ///
    /// - Parameter wrappedValue: The value to wrap.
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
}

extension Nullable: Encodable where T: Encodable {
    /// Encodes the wrapped value to the given encoder.
    ///
    /// If the value is `nil`, it is explicitly encoded as `null`.
    ///
    /// - Parameter encoder: The encoder to write to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(value)
        case .none:
            try container.encodeNil()
        }
    }
}

extension Nullable: Decodable where T: Decodable {
    /// Decodes a value of the underlying type, setting `wrappedValue` to `nil` if decoding fails or if the key is absent.
    ///
    /// - Parameter decoder: The decoder to read from.
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try? decoder.singleValueContainer().decode(T.self)
    }
}

extension Nullable: Equatable where T: Equatable {}

extension Nullable: Hashable where T: Hashable {}

#if swift(>=6.0)
extension Nullable: Sendable where T: Sendable {}
#endif
