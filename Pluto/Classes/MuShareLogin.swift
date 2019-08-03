
import Alamofire
import SwiftyJSON

final public class MuShareLogin {
    
    public static let shared = MuShareLogin()
    
    private init() {}
    
    private var server: String = ""
    private var sdkSecret: String = ""
    
    private func header() -> HTTPHeaders? {
        let headers: HTTPHeaders = [
            "sdkSecret": sdkSecret
        ]
        return headers
    }
    
    private func url(from relativeUrl: String) -> String {
        return server + "/" + relativeUrl
    }
    
    public static func setup(server: String, sdkSecret: String) {
        MuShareLogin.shared.server = server
        MuShareLogin.shared.sdkSecret = sdkSecret
    }
    
    public static func refreshToken() -> String {
        return DefaultsManager.shared.refreshToken ?? ""
    }
    
    public static func expire() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(DefaultsManager.shared.expire ?? 0))
    }
    
    public typealias ErrorCompletion = (MuShareLoginError) -> Void
    
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
            let response = MuShareResponse($0)
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
            let response = MuShareResponse($0)
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
                DefaultsManager.shared.expire = user["expire"].intValue
                success()
            } else {
                error?(response.errorCode())
            }
        }
    }
    
}
