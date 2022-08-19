import Foundation

struct HTTPNetworkResponse {
    static func handleNetworkResponse(for response: HTTPURLResponse?) -> Result<Void, HTTPError> {
        guard let response = response else {
            return .failure(HTTPError.failedResponseUnwrapping)
        }
        switch response.statusCode {
        case 200...299: return .success(())
        case 400: return .failure(HTTPError.wrongRequest)
        case 401: return .failure(HTTPError.authenticationError)
        case 404: return .failure(HTTPError.notFound)
        case 500...599: return .failure(HTTPError.serverSideError)
        default: return .failure(HTTPError.failed)
        }
    }
}
