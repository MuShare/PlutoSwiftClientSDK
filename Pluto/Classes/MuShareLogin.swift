
import Alamofire

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
    
    public static func accessToken() -> String {
        return DefaultsManager.shared.accessToken ?? ""
    }
    
    public typealias ErrorCompletion = (MuShareLoginError) -> Void
    
    public func registerByEmail(address: String, password: String, name: String, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        Alamofire.request(
            url(from: "sdk/register/email"),
            method: .post,
            parameters: [
                "address": address,
                "password": password,
                "name": name
            ],
            encoding: URLEncoding.default,
            headers: header()
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
            url(from: "sdk/login/email"),
            method: .post,
            parameters: [
                "address": address,
                "password": password,
                "identifier": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
                "os": "ios",
                "version": UIDevice.current.systemVersion,
                "language": Bundle.main.preferredLocalizations[0].components(separatedBy: "-")[0]
            ],
            encoding: URLEncoding.default,
            headers: header()
        ).responseJSON {
            let response = MuShareResponse($0)
            if response.statusOK() {
                DefaultsManager.shared.accessToken = response.getResult()["accessToken"].stringValue
                success()
            } else {
                error?(response.errorCode())
            }
        }
    }
    
}
