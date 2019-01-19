import UIKit
import FirebaseDatabase
import FirebaseAuth
import SCLAlertView

enum HealthRecord: Int {
    case heart = 0
    case height = 1
    case sleep = 2
    case weight = 3
    case workout = 4
}

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var doctor: Doctor?
    //let doctorUid: String? = Auth.auth().currentUser?.uid
    let doctorUid: String? = "doctorUID"
    var patients = [Patient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInformation()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profilePictureImageView.setRounded()
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var linesStackView: UIStackView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var updatePictureButton: UIButton!
    @IBOutlet weak var savePictureButton: UIButton!
    @IBOutlet weak var myPatientsButton: UIButton!
    
    //MARK: - IBActions

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text {
            doctor?.firstName = firstName
            doctor?.lastName = lastName
            sendWithDelay()
        }
        
        firstNameTextField.isEnabled = false
        firstNameTextField.isHidden = true
        lastNameTextField.isEnabled = false
        lastNameTextField.isHidden = true
        savePictureButton.isEnabled = false
        savePictureButton.isHidden = true
        updatePictureButton.isEnabled = false
        updatePictureButton.isHidden = true
        profilePictureImageView.isUserInteractionEnabled = true
        nameLabel.isHidden = false
        linesStackView.isHidden = true
        
        profilePictureImageView.alpha = 1.0
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showCameraVC", sender: nil)
    }
    
    @IBAction func updateProfilePictureButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true)
            } else {
                SCLAlertView().showError("Error", subTitle: NSLocalizedString("QRAnalyzer.error", comment: ""))
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true)
            } else {
                SCLAlertView().showError("Error", subTitle: NSLocalizedString("QRAnalyzer.error", comment: ""))
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    @IBAction func patientsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showPatientsVC", sender: nil)
    }
    
    @IBAction func appointmentsButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func busyTimeButtonPressed(_ sender: UIButton) {
        print("Busy Mode")
    }
    
    
    //MARK: - Functions
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        nameLabel.isHidden = true
        firstNameTextField.isEnabled = true
        firstNameTextField.isHidden = false
        lastNameTextField.isEnabled = true
        lastNameTextField.isHidden = false
        savePictureButton.isEnabled = true
        savePictureButton.isHidden = false
        updatePictureButton.isEnabled = true
        updatePictureButton.isHidden = false
        profilePictureImageView.isUserInteractionEnabled = false
        linesStackView.isHidden = false
        
        profilePictureImageView.alpha = 0.5
        firstNameTextField.text = doctor?.firstName
        lastNameTextField.text = doctor?.lastName
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        profilePictureImageView.image = image
        doctor?.profilePicture = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func getName() {
        var firstName = ""
        var lastName = ""
        var speciality = ""
        DatabaseService.shared.doctorsRef.child("\(doctorUid!)").child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            firstName = value?["firstName"] as? String ?? ""
            lastName = value?["lastName"] as? String ?? ""
            speciality = value?["speciality"] as? String ?? ""
            self.doctor?.firstName = firstName
            self.doctor?.lastName = lastName
            self.doctor?.specialty = speciality
            DispatchQueue.main.async {
                self.nameLabel.text = "\(firstName) \(lastName)"
                self.roleLabel.text = speciality
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setInformation() {
        doctor = Doctor(uid: doctorUid!)
        getName()
        doctor?.profilePicture = UIImage(named: "Doctor-Profile2")
    }
    
    //MARK: - Sending to Firebase methods and Siri
    
    func sendWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if (self.doctor?.username.count)! < 3 {
                self.sendWithDelay()
                return
            }
        }
    }
    
    /*func createUserActivity() {
        let activity = NSUserActivity(activityType: UserActivityType.sendToServer)
        activity.title = NSLocalizedString("profile.sendToServer", comment: "")
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        
        userActivity = activity
        userActivity?.becomeCurrent()
    }*/
    
    
}
