import UIKit
import FirebaseAuth
import LocalAuthentication
import SCLAlertView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard Auth.auth().currentUser != nil else {
            performSegue(withIdentifier: "showLoginVC", sender: nil)
            return
        }
        //authenticateUser()
        performSegue(withIdentifier: "showMainPageVC", sender: nil)
    }
    
    func authenticateUser() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Auth"
        
        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    
                    DispatchQueue.main.async {
                        if success {
                            SCLAlertView().showSuccess(NSLocalizedString("login.welcome.title", comment: ""), subTitle: NSLocalizedString("login.welcome.message", comment: ""))
                            self.performSegue(withIdentifier: "showMainPageVC", sender: nil)
                        } else {
                            let alert = UIAlertController(title: NSLocalizedString("login.authError.title", comment: ""), message: NSLocalizedString("login.authError.message", comment: ""), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                self.authenticateUser()
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                }
            } else {
                // Could not evaluate policy
                SCLAlertView().showError(NSLocalizedString("login.touchIdError.title", comment: ""), subTitle: NSLocalizedString("login.touchIdError.message", comment: ""))
            }
        } else {
            // Fallback on earlier versions
            
        }
    }

}
