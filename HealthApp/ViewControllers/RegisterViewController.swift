import UIKit
import SCLAlertView

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        specialityPickerView.selectRow(0, inComponent: 0, animated: true)
        setSpecialities()
    }
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var specialityPickerView: UIPickerView!
    var specialities = [String]()
    var selectedSpeciality = 0
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let mail = emailTextField.text
        let password = passwordTextField.text
        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
        let address = addressTextField.text
        let phone = phoneTextField.text
        let specialtiy = specialities[selectedSpeciality]
        if mail?.isEmail != nil {
            if password == repeatPasswordTextField.text {
                if password?.isPassword != nil {
                    if firstName?.isName != nil, lastName?.isName != nil {
                        let newDoctor = Doctor(uid: "", firstName: firstName!, lastName: lastName!, direction: address!, email: mail!, phone: phone!, specialty: specialtiy)
                        AuthService.shared.register(doctor: newDoctor, password: password!) { (message, data) in
                            guard message == nil else {
                                SCLAlertView().showError("Error", subTitle: message!)
                                return
                            }
                            self.performSegue(withIdentifier: "showMainPageVC", sender: nil)
                        }
                    } else {
                        SCLAlertView().showError("Error", subTitle: NSLocalizedString("register.alert.nameError", comment: ""))
                    }
                } else {
                    SCLAlertView().showError("Error", subTitle: NSLocalizedString("register.alert.insecurePassword", comment: ""))
                }
            } else {
                SCLAlertView().showError("Error", subTitle: NSLocalizedString("register.alert.passwordNotMatch", comment: ""))
            }
        } else {
            SCLAlertView().showError("Error", subTitle: NSLocalizedString("register.alert.wrongEmail", comment: ""))
        }
    }
    
    func setSpecialities() {
        specialities = ["General Doctor / Other",
                        "General Surgery",
                        "Cardiothoracic Surgery",
                        "Vascular Surgery",
                        "Cosmetic and Reconstructive Surgery",
                        "Colorectal Surgery",
                        "Surgical Oncology",
                        "Transplant Surgery",
                        "Trauma Surgery",
                        "Surgical Endocrinology",
                        "Orthopedic Surgery",
                        "Neurosurgery",
                        "Urology",
                        "ENT",
                        "Ophthalmology",
                        "Obstetrics / Gynecology",
                        "Dermatology",
                        "Neurology",
                        "Pathology",
                        "Radiology",
                        "Anesthesiology",
                        "Psychiatry",
                        "Pediatrics",
                        "Family Practice",
                        "Radiation Oncology",
                        "Physical Medicine and Rehab",
                        "Emergency Medicine",
                        "Psychologist / Counselor",
                        "Podiatrists",
                        "Optometrists",
                        "Maternal-Fetal Medicine",
                        "Reproductive Endocrinology",
                        "Gynecologic Oncology",
                        "Urogynecology"
        ]
        //specialities = specialities.sorted(by: { $0 < $1 } )
        specialities.sort()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return specialities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return specialities[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSpeciality = row
    }
    
    
}
