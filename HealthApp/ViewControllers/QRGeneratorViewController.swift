import UIKit
import FirebaseAuth

class QRGeneratorViewController: UIViewController {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var qrImageView: UIImageView!
    var doctor: Doctor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureImageView.setRounded()
        profilePictureImageView.image = doctor?.profilePicture ?? UIImage(named: "profile-placeholder")
        generateQR()
    }
    
    func generateQR() {
        if let uid = Auth.auth().currentUser?.uid {
            let data = uid.data(using: .ascii, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            let ciImage = filter?.outputImage
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let transformImage = ciImage?.transformed(by: transform)
            let image = UIImage(ciImage: transformImage!)
            qrImageView.image = image
        }
        
    }
}
