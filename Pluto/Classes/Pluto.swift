
import Alamofire
import SwiftyJSON

final public class Pluto {
    
    public static let shared = Pluto()
    
    private init() {}
    
    private var server: String = ""
   
    private func url(from relativeUrl: String) -> String {
        return server + "/" + relativeUrl
    }
    
    public typealias ErrorCompletion = (MuShareLoginError) -> Void
    
}

extension Pluto {
    
    public static func setup(server: String) {
        Pluto.shared.server = server
    }
    
    public static func refreshToken() -> String {
        return DefaultsManager.shared.refreshToken ?? ""
    }
    
    public static func expire() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(DefaultsManager.shared.expire ?? 0))
    }
    
}

extension Pluto {
    
    public func registerByEmail(address: String, password: String, name: String, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        Alamofire.request(
            url(from: "api/user/register"),
            method: .post,
            parameters: [
                "mail": address,
                "password": password,
                "name": name
            ],
            encoding: JSONEncoding.default,
            headers: nil
        ).responseJSON {
            let response = PlutoResponse($0)
            if response.statusOK() {
                success()
            } else {
                error?(response.errorCode())
            }
        }
    }
    
    public func loginWithEmail(address: String, password: String, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        Alamofire.request(
            url(from: "api/user/login"),
            method: .post,
            parameters: [
                "mail": address,
                "password": password,
                "device_id": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
                "app_id": "easyjapanese"
//                "version": UIDevice.current.systemVersion,
//                "language": Bundle.main.preferredLocalizations[0].components(separatedBy: "-")[0]
            ],
            encoding: JSONEncoding.default,
            headers: nil
        ).responseJSON {
            let response = PlutoResponse($0)
            if response.statusOK() {
                let body = response.getBody()
                DefaultsManager.shared.refreshToken = body["refresh_token"].stringValue
                
                let parts = body["jwt"].stringValue.split(separator: ".").map(String.init)
                guard
                    parts.count == 3, let restoreData = Data(base64Encoded: parts[1]),
                    let restoreString = String(data: restoreData, encoding: .utf8)
                else {
                    // TODO: Throw error here.
                    return
                }
                let user = JSON(parseJSON: restoreString)
                print(user)
                DefaultsManager.shared.userId = user["userId"].stringValue
                DefaultsManager.shared.expire = user["expire"].intValue
                success()
            } else {
                error?(response.errorCode())
            }
        }
    }
    
}

extension Pluto {
    
    public func getToken(completion: (String) -> Void) {
        
    }
    
    private func refreshToken(completion: (String?) -> Void) {
        guard
            let userId = DefaultsManager.shared.userId,
            let refreshToken = DefaultsManager.shared.refreshToken
        else {
            completion(nil)
            return
        }
        Alamofire.request(
            url(from: "api/auth/refresh"),
            method: .post,
            parameters: [
                "refresh_token": refreshToken,
                "user_id": userId,
                "device_id": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
                "app_id":"easyjapanese"
            ]
        )
    }
    
}
