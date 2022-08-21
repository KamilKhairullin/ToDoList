import Foundation

struct HTTPRequest {
    let route: String
    let headers: [String: String]
    let body: Data?
    let queryItems: [(key: String, value: String?)]
    let httpMethod: HTTPMethod

    let keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
    let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy

    init(
        route: String,
        headers: [String: String] = [:],
        body: Data? = nil,
        queryItems: [(key: String, value: String?)] = [],
        httpMethod: HTTPMethod = .get,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970
    ) {
        self.route = route
        self.headers = headers
        self.body = body
        self.queryItems = queryItems
        self.httpMethod = httpMethod
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dateDecodingStrategy = .secondsSince1970
    }
}
