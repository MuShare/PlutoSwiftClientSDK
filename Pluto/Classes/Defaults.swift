
import SwiftyUserDefaults

extension DefaultsKeys {
    static let accessToken = DefaultsKey<String?>("accessToken")
}

class DefaultsManager {

    static let shared = DefaultsManager()
    
    private init() {}
    
    var accessToken: String? {
        set {
            Defaults[.accessToken] = newValue
        }
        get {
            return Defaults[.accessToken]
        }
    }
    
}
