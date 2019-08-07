
import SwiftyUserDefaults

extension DefaultsKeys {
    static let refreshToken = DefaultsKey<String?>("org.mushare.pluto.refreshToken")
    static let expire = DefaultsKey<Int?>("org.mushare.pluto.exipre")
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
