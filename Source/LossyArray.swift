import Foundation

@available(*, deprecated, renamed: "LossyArray", message: "Just new naming")
typealias PartialArray<A> = LossyArray<A>

/// Allows you to decode an array or dictionary with partially incorrect data. If the data is incorrect, the value will be omitted from the result.
@propertyWrapper
public struct LossyArray<A> {
    public var wrappedValue: [A]

    public init(wrappedValue: [A] = []) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Decodable

extension LossyArray: Decodable where A: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer().decode([LossyValue<A>].self)
        self.wrappedValue = (container ?? []).compactMap(\.wrappedValue)
    }
}

// MARK: - Encodable

extension LossyArray: Encodable where A: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

extension LossyArray: Equatable where A: Equatable {}
extension LossyArray: Hashable where A: Hashable {}

// MARK: - ExpressibleByArrayLiteral

extension LossyArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: A...) {
        self.init(wrappedValue: elements)
    }
}
