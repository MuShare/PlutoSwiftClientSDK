
import Alamofire
import SwiftyJSON

final public class Pluto {
    
    public typealias ErrorCompletion = (PlutoError) -> Void
    
    public enum State {
        case notSignin
        case loading
        case signin
    }
    
    public static let shared = Pluto()
    
    private var server: String = ""
    private var appId: String = ""
    
    private var stateObserver: ((State) -> Void)?
    private var state: State = .loading {
        didSet {
            stateObserver?(state)
        }
    }
    
    private let devideId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    
    private init() {}
   
    private func url(from relativeUrl: String) -> String {
        return server + "/" + relativeUrl
    }
    
    public func setup(server: String, appId: String) {
        self.server = server
        self.appId = appId
        
        refreshToken { [unowned self] in
            guard $0 != nil else {
                self.state = .notSignin
                return
            }
            self.state = .signin
        }
    }
    
    public func observeState(observer: ((State) -> Void)?) {
        stateObserver = observer
    }

}

extension Pluto {

    public func registerByEmail(address: String, password: String, name: String, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        AF.request(
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
    
    public func loginWithEmail(address: String, password: String, success: (() -> Void)? = nil, error: ErrorCompletion? = nil) {
        AF.request(
            url(from: "api/user/login"),
            method: .post,
            parameters: [
                "mail": address,
                "password": password,
                "device_id": devideId,
                "app_id": appId
//                "version": UIDevice.current.systemVersion,
//                "language": Bundle.main.preferredLocalizations[0].components(separatedBy: "-")[0]
            ],
            encoding: JSONEncoding.default,
            headers: nil
        ).responseJSON { [weak self] in
            guard let `self` = self else {
                error?(PlutoError.unknown)
                return
            }
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
                self.state = .signin
                success?()
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
        AF.request(
            url(from: "api/auth/refresh"),
            method: .post,
            parameters: [
                "refresh_token": refreshToken,
                "user_id": userId,
                "device_id": devideId,
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
