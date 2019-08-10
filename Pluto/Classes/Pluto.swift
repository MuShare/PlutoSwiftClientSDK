
import Alamofire
import SwiftyJSON

final public class Pluto {
    
    public static let shared = Pluto()
    
    private init() {}
    
    private var server: String = ""
    private var appId: String = ""
   
    private func url(from relativeUrl: String) -> String {
        return server + "/" + relativeUrl
    }
    
    public typealias ErrorCompletion = (PlutoError) -> Void
    
}

extension Pluto {
    
    public static func setup(server: String, appId: String) {
        Pluto.shared.server = server
        Pluto.shared.appId = appId
    }
    
    public static func refreshToken() -> String {
        return DefaultsManager.shared.refreshToken ?? ""
    }
    
    public static func expire() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(DefaultsManager.shared.expire))
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
                "app_id": appId
//                "version": UIDevice.current.systemVersion,
//                "language": Bundle.main.preferredLocalizations[0].components(separatedBy: "-")[0]
            ],
            encoding: JSONEncoding.default,
            headers: nil
        ).responseJSON {
            let response = PlutoResponse($0)
            if response.statusOK() {
                let body = response.getBody()
                guard
                    let refreshToken = body["refresh_token"].string,
                    let jwt = body["jwt"].string
                else {
                    error?(PlutoError.parseError)
                    return
                }
                
                DefaultsManager.shared.refreshToken = refreshToken
                DefaultsManager.shared.jwt = jwt
                
                let parts = jwt.split(separator: ".").map(String.init)
                guard
                    parts.count == 3, let restoreData = Data(base64Encoded: parts[1]),
                    let restoreString = String(data: restoreData, encoding: .utf8)
                else {
                    error?(PlutoError.parseError)
                    return
                }
                
                let user = JSON(parseJSON: restoreString)
                guard
                    let userId = user["userId"].int,
                    let expire = user["expire"].int
                else {
                    error?(PlutoError.parseError)
                    return
                }
                DefaultsManager.shared.userId = userId
                DefaultsManager.shared.expire = expire
                success()
            } else {
                error?(response.errorCode())
            }
        }
    }
    
}

extension Pluto {
    
    public func getToken(completion: @escaping (String?) -> Void) {
        let expire = DefaultsManager.shared.expire
        guard
            let jwt = DefaultsManager.shared.jwt,
            expire - Int(Date().timeIntervalSince1970) > 5 * 60
        else {
            refreshToken(completion: completion)
            return
        }
        completion(jwt)
    }
    
    private func refreshToken(completion: @escaping (String?) -> Void) {
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
                "app_id": appId
            ],
            encoding: JSONEncoding.default
        ).responseJSON {
            let response = PlutoResponse($0)
            if response.statusOK() {
                let body = response.getBody()
                guard let jwt = body["jwt"].string else {
                    completion(nil)
                    return
                }
                DefaultsManager.shared.jwt = jwt
                completion(jwt)
            }
        }
    }
    
}
