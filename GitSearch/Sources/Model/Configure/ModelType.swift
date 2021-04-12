import Then

protocol ModelType: Codable, Then {
  associatedtype Event

  static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}

extension ModelType {
  static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
    .iso8601
  }

  static var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = dateDecodingStrategy
    return decoder
  }
}
