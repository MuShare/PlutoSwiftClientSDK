
import Alamofire
import SwiftyJSON

struct PlutoResponse {

    var data: [String: Any] = [:]
    
    init(_ response: DataResponse<Any>) {
        if let value = response.value as? [String: Any] {
            data = value
            print(value)
        }
    }
    
    func statusOK() -> Bool {
        guard !data.isEmpty, let status = data["status"] as? String else {
            return false
        }
        return status == "ok"
    }
    
    func getBody() -> JSON {
        guard let result = data["body"] as? [String: Any] else {
            return JSON()
        }
        return JSON(result)
    }
    
    func errorCode() -> PlutoError {
        guard
            !data.isEmpty,
            let error = data["error"] as? [String: Any],
            let code = error["code"] as? Int
        else {
            return .badRequest
        }
        return PlutoError(rawValue: code) ?? .badRequest
    }
    
}

public enum PlutoError: Int, Error {
    case unknown = -99999
    case badRequest = -99998
    case parseError = -99997
    case mailIsAlreadyRegister = 2001
    case mailIsNotExsit = 2002
    case mailIsNotVerified = 2003
    case mailAlreadyVerified = 2004
    case invalidPassword = 3001
    case invalidRefreshToken = 3002
    case invalidJWTToekn = 3003
}
