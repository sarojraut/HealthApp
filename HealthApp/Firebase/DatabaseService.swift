import Foundation
import FirebaseDatabase
import FirebaseAuth

let FIR_CHILD_DOCTORS = "doctors"
let FIR_CHILD_USERS = "users"
let FIR_CHILD_APPOINTMENT = "appointments"
let FIR_CHILD_APPOINTMENT_REMOVE = "appointmentsToRemove"

enum UserType: Int {
    case patient = 0
    case doctor = 1
    case other = 3
}

class DatabaseService {
    
    private static let _shared = DatabaseService()
    
    static var shared: DatabaseService {
        return _shared
    }
    
    var mainRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var doctorsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_DOCTORS)
    }
    
    var usersRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_USERS)
    }
    
    var appointmentsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_APPOINTMENT)
    }
    
    private func addUserTo(patient withUid: String, doctorId: String) {
        self.mainRef.child("\(FIR_CHILD_USERS)/\(withUid)/doctors/\(doctorId)").setValue(doctorId)
    }
    
    private func add(appointment: Appointment, doctorUid: String, patientUid: String) {
        let appointmentId = appointment.id
        self.mainRef.child("\(FIR_CHILD_DOCTORS)/\(doctorUid)/\(FIR_CHILD_APPOINTMENT)/\(appointmentId)").setValue(appointmentId)
        self.mainRef.child("\(FIR_CHILD_USERS)/\(patientUid)/\(FIR_CHILD_APPOINTMENT)/\(appointmentId)").setValue(appointmentId)
    }
    
    func add(patient: String) {
        let doctorId = Auth.auth().currentUser?.uid
         self.mainRef.child("\(FIR_CHILD_DOCTORS)/\(doctorId!)/patients/\(patient)").setValue(patient)
        addUserTo(patient: patient, doctorId: doctorId!)
    }
    
    func saveUser(uid: String) {
        let profile: Dictionary<String, AnyObject> = ["firstName": "" as AnyObject, "secondName": "" as AnyObject, "gender": "" as AnyObject]
        self.mainRef.child(FIR_CHILD_USERS).child(uid).child("profile").setValue(profile)
    }
    
    func create(appointment: Appointment) {
        let firebaseAppointment: Dictionary<String, AnyObject> = ["doctorId": appointment.doctorUid as AnyObject, "patientId": appointment.patientUid as AnyObject, "startDate": "\(appointment.startDate)" as AnyObject, "endDate": "\(appointment.endDate)" as AnyObject, "notes": appointment.notes as AnyObject, "doctorLocalIdentifier": appointment.localIdentifier as AnyObject, "patientLocalIdentifier": appointment.patientLocalIdentifier as AnyObject]
        self.mainRef.child("\(FIR_CHILD_APPOINTMENT)").child(appointment.id).setValue(firebaseAppointment)
        self.add(appointment: appointment, doctorUid: appointment.doctorUid, patientUid: appointment.patientUid)
    }
    
    func totalRemove(appointment: Appointment) {
        
        self.appointmentsRef.child(appointment.id).removeValue()
        
        self.mainRef.child("\(FIR_CHILD_USERS)/\(appointment.patientUid)/\(FIR_CHILD_APPOINTMENT)/\(appointment.id)").removeValue()
        
        self.mainRef.child("\(FIR_CHILD_DOCTORS)/\(appointment.doctorUid)/\(FIR_CHILD_APPOINTMENT)/\(appointment.id)").removeValue()
        
        self.removeReferenceOf(appointment: appointment, forUser: UserType.doctor)
    }
    
    func remove(appointment: Appointment) {
        self.mainRef.child("\(FIR_CHILD_USERS)/\(appointment.patientUid)/\(FIR_CHILD_APPOINTMENT)/\(appointment.id)").removeValue()
        self.mainRef.child("\(FIR_CHILD_DOCTORS)/\(appointment.doctorUid)/\(FIR_CHILD_APPOINTMENT)/\(appointment.id)").removeValue()
        
        self.mainRef.child("\(FIR_CHILD_DOCTORS)/\(appointment.doctorUid)/appointmentsToRemove/\(appointment.id)").setValue(appointment.id)
    }
    
    func removeReferenceOf(appointment: Appointment, forUser: UserType) {
        if forUser == UserType.doctor {
            self.mainRef.child("\(FIR_CHILD_DOCTORS)/\(appointment.doctorUid)/appointmentsToRemove/\(appointment.id)").removeValue()
        } else {
            self.mainRef.child("\(FIR_CHILD_USERS)/\(appointment.patientUid)/appointmentsToRemove/\(appointment.id)").removeValue()
        }
    }
    
}
    
