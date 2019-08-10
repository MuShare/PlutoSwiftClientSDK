
import SwiftyUserDefaults

extension DefaultsKeys {
    static let jwt = DefaultsKey<String?>("org.mushare.pluto.jwt")
    static let refreshToken = DefaultsKey<String?>("org.mushare.pluto.refreshToken")
    static let expire = DefaultsKey<Int>("org.mushare.pluto.exipre", defaultValue: 0)
    static let userId = DefaultsKey<Int?>("org.mushare.pluto.userId")
}

class DefaultsManager {

    static let shared = DefaultsManager()
    
    private init() {}
    
    var jwt: String? {
        set {
            Defaults[.jwt] = newValue
        }
        get {
            return Defaults[.jwt]
        }
    }
    
    var refreshToken: String? {
        set {
            Defaults[.refreshToken] = newValue
        }
        get {
            return Defaults[.refreshToken]
        }
    }
    
    var expire: Int {
        set {
            Defaults[.expire] = newValue
        }
        get {
            return Defaults[.expire]
        }
    }
    
    var userId: Int? {
        set {
            Defaults[.userId] = newValue
        }
        get {
            return Defaults[.userId]
        }
    }
    
}
