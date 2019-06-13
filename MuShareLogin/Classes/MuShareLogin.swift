
import Alamofire

final class MuShareLogin {
    
    static let shared = MuShareLogin()
    
    private init() {}
    
    private var server: String = ""
    private var appId: String = ""
    private var apiSecret: String = ""
    
    private func header() -> HTTPHeaders? {
        let headers: HTTPHeaders = [
            "appId": appId,
            "apiSecret": apiSecret
        ]
        return headers
    }
    
    private func url(from relativeUrl: String) -> String {
        return server + "/" + relativeUrl
    }
    
    func setup(server: String, appId: String, apiSecret: String) {
        self.server = server
        self.appId = appId
        self.apiSecret = apiSecret
    }
    
    func registerByEmail(address: String, password: String, name: String) {
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
        ).responseJSON { response in
            
        }
    }
    
}
