
import SwiftyUserDefaults

extension DefaultsKeys {
    static let refreshToken = DefaultsKey<String?>("refreshToken")
    static let expire = DefaultsKey<Int?>("0")
}

class DefaultsManager {

    static let shared = DefaultsManager()
    
    private init() {}
    
    var refreshToken: String? {
        set {
            Defaults[.refreshToken] = newValue
        }
        get {
            return Defaults[.refreshToken]
        }
    }
    
    var expire: Int? {
        set {
            Defaults[.expire] = newValue
        }
        get {
            return Defaults[.expire]
        }
    }
    
}
