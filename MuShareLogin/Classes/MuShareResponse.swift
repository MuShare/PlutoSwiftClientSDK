
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
    
    func errorCode() -> ErrorCode {
        guard !data.isEmpty, let code = data["errorCode"] as? Int else {
            return .badRequest
        }
        return ErrorCode(rawValue: code) ?? .badRequest
    }
    
}

enum ErrorCode: Int {
    case badRequest = -99999
}
