import UIKit
import EventKit
import FirebaseAuth

class AppointmentsViewController: UITableViewController {
    
    var appointments: [Appointment] = []
    var patientAppointments: [Appointment] = []
    var patient: Patient!
    let doctorUid = Auth.auth().currentUser?.uid
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.attributedTitle = NSAttributedString(string: " ↓ \(NSLocalizedString("table.refresh.message", comment: "")) ↓ ")
        refreshControl?.addTarget(self, action: #selector(AppointmentsViewController.getAppointments), for: .valueChanged)
        refreshControl?.addTarget(self, action: #selector(AppointmentsViewController.getPatientAppointments), for: .valueChanged)
        refreshControl?.addTarget(self, action: #selector(AppointmentsViewController.appointmentsToRemove), for: .valueChanged)
        
        appointmentsToRemove()
        getAppointments()
        getPatientAppointments()
    }
    
    @objc func getPatientAppointments() {
        patientAppointments = []
        DatabaseService.shared.usersRef.child(patient.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let appointmentsId = value?["appointments"] as? NSDictionary ?? [:]
            for appointment in appointmentsId {
                DatabaseService.shared.appointmentsRef.child("\(appointment.key)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let doctorUid = value?["doctorId"] as? String ?? ""
                    let patientUid = value?["patientId"] as? String ?? ""
                    let notes = value?["notes"] as? String ?? ""
                    let startDate = value?["startDate"] as? String ?? ""
                    let endDate = value?["endDate"] as? String ?? ""
                    let localIdentifier = value?["patientLocalIdentifier"] as? String
                    
                    if let formatedStartDate = self.getDateFrom(dateInString: startDate), let formatedEndDate = self.getDateFrom(dateInString: endDate) {
                        let newAppointment = Appointment(startDate: formatedStartDate, endDate: formatedEndDate, doctorUid: doctorUid, patientUid: patientUid)
                        newAppointment.notes = notes
                        newAppointment.localIdentifier = localIdentifier
                        self.patientAppointments.append(newAppointment)
                        self.patient.appointments = self.patientAppointments
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc func getAppointments() {
        appointments = []
        // MARK: - TODO EL ID DEL DOCTOR DEBE DE CAMBIAR
        DatabaseService.shared.doctorsRef.child(doctorUid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let appointmentsId = value?["appointments"] as? NSDictionary ?? [:]
            for appointment in appointmentsId {
                DatabaseService.shared.appointmentsRef.child("\(appointment.key)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let patientUid = value?["patientId"] as? String ?? ""
                    if patientUid == self.patient.uid {
                        let value = snapshot.value as? NSDictionary
                        let patientUid = value?["patientId"] as? String ?? ""
                        let notes = value?["notes"] as? String ?? ""
                        let startDate = value?["startDate"] as? String ?? ""
                        let endDate = value?["endDate"] as? String ?? ""
                        let localIdentifier = value?["patientLocalIdentifier"] as? String ?? ""
                        let doctorLocalIdentifier = value?["doctorLocalIdentifier"] as? String ?? ""
                        if let formatedStartDate = self.getDateFrom(dateInString: startDate), let formatedEndDate = self.getDateFrom(dateInString: endDate) {
                            let newAppointment = Appointment(startDate: formatedStartDate, endDate: formatedEndDate, doctorUid: self.doctorUid!, patientUid: patientUid)
                            newAppointment.notes = notes
                            newAppointment.localIdentifier = doctorLocalIdentifier
                            newAppointment.patientLocalIdentifier = localIdentifier
                            
                            if self.eventExists(appointment: newAppointment) == nil {
                                _ = newAppointment.createInCalendar(patient: self.patient)
                            }
                            self.appointments.append(newAppointment)
                        }
                    }
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
    
    @objc func appointmentsToRemove() {
        //EL ID DEL MEDICO DEBE DE CAMBIAR
        DatabaseService.shared.doctorsRef.child(doctorUid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let appointmentsId = value?["appointmentsToRemove"] as? NSDictionary ?? [:]
            for appointment in appointmentsId {
                DatabaseService.shared.appointmentsRef.child("\(appointment.key)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                        let localIdentifier = value?["doctorLocalIdentifier"] as? String ?? ""
                    let newAppointment = Appointment(startDate: Date(), endDate: Date(), doctorUid: self.doctorUid!, patientUid: self.patient.uid)
                    newAppointment.localIdentifier = localIdentifier
                    
                    newAppointment.totalRemoveFromServer()
                    if (self.eventExists(appointment: newAppointment) != nil) {
                        _ = newAppointment.removeFromLocalCalendar()
                        newAppointment.totalRemoveFromServer()
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
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
    
    func eventExists(appointment: Appointment) -> EKEvent? {
        let eventStore: EKEventStore = EKEventStore()
        var event: EKEvent? = nil
        if let eventIdentifier = appointment.localIdentifier {
            event = eventStore.event(withIdentifier: eventIdentifier)
        }
        return event
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appointments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appointment = appointments[indexPath.row]
        let cellID = "AppointmentCell"
        let actualDate = Date()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! AppointmentTableViewCell
        
        if appointment.startDate.startOfDay == actualDate.startOfDay {
            cell.statusImageView.image = UIImage(named: "yellow-indicator")
        } else if appointment.startDate > actualDate {
            cell.statusImageView.image = UIImage(named: "green-indicator")
        } else {
            cell.statusImageView.image = UIImage(named: "red-indicator")
        }
        cell.hourLabel.text = appointment.startDate.formattedHour
        cell.dateLabel.text = appointment.startDate.formattedDate
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            self.appointments.remove(at: indexPath.row)
        }
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let shareAction = UITableViewRowAction(style: .default, title: NSLocalizedString("appointment.share", comment: "")) { (action, indexPath) in
            let appointmentToShare = self.appointments[indexPath.row]
            let activityController = UIActivityViewController(activityItems: [appointmentToShare], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
        
        shareAction.backgroundColor = UIColor.cyan
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("doctorTable.delete", comment: "")) { (action, indexPath) in
            let appointmentToRemove = self.appointments[indexPath.row]
            if appointmentToRemove.removeFromLocalCalendar() {
                appointmentToRemove.removeFromServer()
                self.appointments.remove(at: indexPath.row)
                self.patient.appointments = self.appointments
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.getPatientAppointments()
            }
        }
        
        deleteAction.backgroundColor = UIColor.red
        
        return [shareAction, deleteAction]
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "createAppointmentVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailAppointmentVC" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selectedAppointment = self.appointments[indexPath.row]
                let destinationViewController = segue.destination as! DetailAppointmentViewController
                destinationViewController.patient = patient
                destinationViewController.appointment = selectedAppointment
            }
        } else if segue.identifier == "createAppointmentVC" {
            let destinationViewController = segue.destination as! CreateAppointmentViewController
            destinationViewController.patient = patient
            destinationViewController.doctorAppointments = self.appointments
        }
    }
    
}
