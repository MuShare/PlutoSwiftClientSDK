
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
        guard !data.isEmpty, let code = data["error"] as? Int else {
            return .badRequest
        }
        return PlutoError(rawValue: code) ?? .badRequest
    }
    
}

public enum PlutoError: Int, Error {
    case unknown = -99999
    case badRequest = -99998
    case parseError = -99997
    case sdkSecret = 2001
    case emailExist = 2011
    case emailNotExist = 2022
    case personNotFound = 2023
    case passwordWrong = 2024
}
