import Foundation

/// Allows you to encode 'nil' field as 'null' in JSON when server requires it.
@propertyWrapper
public struct Nullable<T> {
    public var wrappedValue: T?

    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Encodable

extension Nullable: Encodable where T: Encodable {
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

// MARK: - Decodable

extension Nullable: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try? decoder.singleValueContainer().decode(T.self)
    }
}

// MARK: - Equatable

extension Nullable: Equatable where T: Equatable {}

// MARK: - Hashable

extension Nullable: Hashable where T: Hashable {}

#if swift(>=6.0)
extension Nullable: Sendable where T: Sendable {}
#endif
