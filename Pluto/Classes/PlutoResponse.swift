
import Alamofire
import SwiftyJSON

struct PlutoResponse {

    var data: [String: Any] = [:]
    
    init(_ response: DataResponse<Any>) {
        if let value = response.result.value as? [String: Any] {
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
    
    func errorCode() -> MuShareLoginError {
        guard !data.isEmpty, let code = data["error"] as? Int else {
            return .badRequest
        }
        return MuShareLoginError(rawValue: code) ?? .badRequest
    }
    
}

public enum MuShareLoginError: Int, Error {
    case badRequest = -99999
    case sdkSecret = 2001
    case emailExist = 2011
    case emailNotExist = 2022
    case personNotFound = 2023
    case passwordWrong = 2024
}
