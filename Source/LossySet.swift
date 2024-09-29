import Foundation

/// Allows you to decode an array or dictionary with partially incorrect data. If the data is incorrect, the value will be omitted from the result.
@propertyWrapper
public struct LossySet<A: Hashable> {
    public var wrappedValue: Set<A>

    public init(wrappedValue: Set<A> = []) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Decodable

extension LossySet: Decodable where A: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer().decode(Set<LossyValue<A>>.self)
        let result = (container ?? []).compactMap(\.wrappedValue)
        self.wrappedValue = Set(result)
    }
}

// MARK: - Encodable

extension LossySet: Encodable where A: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension LossySet: Equatable where A: Equatable {}
extension LossySet: Hashable where A: Hashable {}

// MARK: - ExpressibleByArrayLiteral

extension LossySet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: A...) {
        self.init(wrappedValue: .init(elements))
    }
}

#if swift(>=6.0)
extension LossySet: Sendable where A: Sendable {}
#endif
