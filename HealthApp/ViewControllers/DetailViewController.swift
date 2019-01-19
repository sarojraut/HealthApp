import UIKit

class DetailViewController: UIViewController {
    
    var healthDataName: HealthDataName!
    var patient: Patient!
    var arrayToShow = [Any]()
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var bloodTypeLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    func configureView() {
        if let detail = detailItem {
            patient = detail
            
            if let label = nameLabel {
                label.text = detail.username
            }
            
            if let label = genderLabel {
                label.text = detail.biologicalSex
            }
            
            if let label = ageLabel  {
                label.text = String(detail.age)
            }
            
            if let label = bloodTypeLabel {
                label.text = detail.bloodType
            }
            
            if let label = heightLabel {
                label.text = "\(detail.heightRecords.last?.height ?? 0.0) Mt"
            }
            
            if let label = weightLabel {
                label.text = "\(detail.weightRecords.last?.weight ?? 0.0) Kg"
            }
        }
    }
    
    @IBAction func appointmentsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showAppointmentsVC", sender: nil)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            arrayToShow = patient.hearthRecords
        case 1:
            arrayToShow = patient.sleepRecords
        case 2:
            arrayToShow = patient.heightRecords
        case 3:
            arrayToShow = patient.weightRecords
        case 5:
            //workouts
            break
        default:
            break
        }
        performSegue(withIdentifier: "showDetailedPatientVC", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    var detailItem: Patient? {
        didSet {
            configureView()
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailedPatientVC" {
            let destinationViewController = segue.destination as! DetailPacientViewController
            destinationViewController.healthDataName = self.healthDataName
            destinationViewController.arrayToShow = self.arrayToShow
        } else if segue.identifier == "showAppointmentsVC" {
            let destinationViewController = segue.destination as! AppointmentsViewController
            destinationViewController.patient = self.patient
        }
    }
}
