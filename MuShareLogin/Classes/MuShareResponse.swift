
import Alamofire
import SwiftyJSON

struct MuShareResponse {

    var data: [String: Any] = [:]
    
    init(_ response: DataResponse<Any>) {
        if let value = response.result.value as? [String: Any] {
            data = value
        }
    }
    
    func statusOK() -> Bool {
        guard !data.isEmpty, let status = data["status"] as? Int else {
            return false
        }
        return status == 200
    }
    
    func getResult() -> JSON {
        guard let result = data["result"] as? [String: Any] else {
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
}
