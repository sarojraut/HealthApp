import UIKit
import FirebaseAuth

class MasterViewController: UITableViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!
    var detailViewController: DetailViewController? = nil
    var patients: [Patient] = []
    let doctorUid = "doctorUID"
    var addButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.attributedTitle = NSAttributedString(string: " ↓ \(NSLocalizedString("table.refresh.message", comment: "")) ↓ ")
        refreshControl?.addTarget(self, action: #selector(MasterViewController.setPatients), for: .valueChanged)
    
        navigationItem.leftBarButtonItem = editButtonItem

        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        setPatients()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc func setPatients() {
        patients = []
        DatabaseService.shared.doctorsRef.child(doctorUid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let patientsUid = value?["patients"] as? NSDictionary ?? [:]
            for patient in patientsUid {
                let patientUid = "\(patient.key)"
                DatabaseService.shared.usersRef.child(patientUid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                    let profile = snapshot.value as? NSDictionary
                    let age = profile?["age"] as? String ?? ""
                    let biologicalSex = profile?["biologicalSex"] as? String ?? ""
                    let bloodType = profile?["bloodType"] as? String ?? ""
                    let firstName = profile?["firstName"] as? String ?? ""
                    let lastName = profile?["lastName"] as? String ?? ""
                    let newPatient = Patient(uid: patientUid)
                    newPatient.age = Int(age) ?? 0
                    newPatient.biologicalSex = biologicalSex
                    newPatient.bloodType = bloodType
                    newPatient.firstName = firstName
                    newPatient.lastName = lastName
                    newPatient.profilePicture = UIImage(named: "picture")!
                    self.setRecordsOf(patient: newPatient)
                    self.patients.append(newPatient)
                    self.refreshControl?.endRefreshing()
                    self.spinner.stopAnimating()
                    self.tableView.reloadData()
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
            self.refreshControl?.endRefreshing()
            self.spinner.stopAnimating()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setRecordsOf(patient: Patient) {
        let records = ["hearthRecords", "heightRecords", "sleepRecords", "weightRecords"]
        
        for record in records {
            DatabaseService.shared.usersRef.child(patient.uid).child(record).observeSingleEvent(of: .value, with: { (snapshot) in
                let values = snapshot.value as? NSDictionary ?? [:]
                
                for value in values {
                    let date = self.getDateFrom(dateInString: "\(value.key)") ?? Date()
                    let data = value.value
                    
                    switch record {
                    case "hearthRecords":
                        let bmp = Int("\(data)") ?? 0
                        let hearthRecord = HearthRecord(bpm: bmp, date: date)
                        patient.add(hearthRecord: hearthRecord)
                    case "heightRecords":
                        let height = Double("\(data)") ?? 0.0
                        let heightRecord = Height(height: height, date: date)
                        patient.add(heightRecord: heightRecord)
                    case "sleepRecords":
                        let hoursSleeping = "\(data)"
                        let sleepAnalisys = SleepAnalisys(date: date, hoursSleeping: hoursSleeping)
                        patient.add(sleepRecord: sleepAnalisys)
                    case "weightRecords":
                        let wight = Double("\(data)") ?? 0.0
                        let weightRecord = Weight(weight: wight, date: date)
                        patient.add(weightRecord: weightRecord)
                    default:
                        break
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }

    func getDateFrom(dateInString: String) -> Date? {
        var stringDate = dateInString
        stringDate = stringDate.replacingOccurrences(of: " ", with: "")
        
        if stringDate.count < 10 { return nil }
        
        stringDate.insert("T", at: stringDate.index(stringDate.startIndex, offsetBy: 10))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        let date = dateFormatter.date(from: stringDate)
        return date
    }
    
    @objc func insertNewObject() {
        let alert = UIAlertController(title: "Add", message: "Select an option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Show my Doctor ID", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "showDoctorIdVC", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Scan Patient ID", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "showScanVC", sender: nil)
        }))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = addButton
        }
        
        present(alert, animated: true)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let patient = patients[indexPath.row]
        cell.textLabel!.text = patient.username
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            patients.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedPatient = patients[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = selectedPatient
                controller.patient = selectedPatient
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }


}

