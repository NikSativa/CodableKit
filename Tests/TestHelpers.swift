import CodableKit
import Foundation

@inline(__always)
func subjectAction<T: Decodable>(_ json: Any) -> T? {
    guard JSONSerialization.isValidJSONObject(json) else {
        return nil
    }

    guard let data = try? JSONSerialization.data(withJSONObject: json) else {
        return nil
    }

    return try? JSONDecoder().decode(T.self, from: data)
}

extension Data {
    static func make<T: Encodable>(from json: T) throws -> Data {
        let decoder = JSONEncoder()
        decoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try decoder.encode(json)
    }
}
