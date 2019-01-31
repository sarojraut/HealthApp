import Foundation
import FirebaseAuth

typealias Completion = (_ errorMessage: String?, _ data: AnyObject?) -> Void

class AuthService {
    private static let _shared = AuthService()
    
    static var shared: AuthService {
        return _shared
    }
    
    func login(email: String, password: String, onComplete: Completion?) {
        // Try login
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = (error as NSError?) {
                // Something wrong
                if let errorCode = AuthErrorCode.init(rawValue: error.code) {
                    self.handleFireBaseError(error: error, onComplete: onComplete)
                    if errorCode == AuthErrorCode.userNotFound {
                        onComplete?(NSLocalizedString("login.error", comment: ""), nil)
                    } else {
                        self.handleFireBaseError(error: error, onComplete: onComplete)
                    }
                }
            } else {
                onComplete?(nil, user!)
            }
        }
    }
    
    func register(doctor: Doctor, password: String, onComplete: Completion?) {
        let paramDoctor = doctor
        Auth.auth().createUser(withEmail: paramDoctor.email, password: password) { (doctor, error) in
            if let error = (error as NSError?) {
                // Show the error
                self.handleFireBaseError(error: error, onComplete: onComplete)
            } else {
                if doctor?.user.uid != nil {
                    paramDoctor.uid = (doctor?.user.uid)!
                    DatabaseService.shared.saveDoctor(doctor: paramDoctor)
                    // User loggin in
                    Auth.auth().signIn(withEmail: paramDoctor.email, password: password, completion: { (user, error) in
                        if let error = (error as NSError?) {
                            // Show the error
                            self.handleFireBaseError(error: error, onComplete: onComplete)
                        } else {
                            onComplete?(nil, user!)
                            // Login completed successfully
                        }
                    })
                }
            }
        }
    }
    
    func handleFireBaseError(error: NSError, onComplete: Completion?) {
        print(error.debugDescription)
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .invalidEmail:
                onComplete?(NSLocalizedString("firebase.error.invalidEmail", comment: ""), nil)
                break
            case .wrongPassword, .invalidCredential, .accountExistsWithDifferentCredential:
                onComplete?(NSLocalizedString("firebase.error.wrongPassword", comment: ""), nil)
                break
            case .emailAlreadyInUse:
                onComplete?(NSLocalizedString("firebase.error.emailAlreadyInUse", comment: ""), nil)
                break
            case .tooManyRequests:
                onComplete?(NSLocalizedString("firebase.error.tooManyRequests", comment: ""), nil)
                break
            case .weakPassword:
                onComplete?(NSLocalizedString("firebase.error.weakPassword", comment: ""), nil)
                break
            case .userDisabled:
                onComplete?(NSLocalizedString("firebase.error.userDisabled", comment: ""), nil)
                break
            case .userNotFound:
                onComplete?(NSLocalizedString("firebase.error.userNotFound", comment: ""), nil)
                break
            default:
                onComplete?(NSLocalizedString("error.generic", comment: ""), nil)
            }
        }
    }
    
}
