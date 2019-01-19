import Foundation
import UIKit

class Doctor {
    private var _username: String
    private var _direction: String
    private var _email: String
    private var _firstName: String
    private var _lastName: String
    private var _phone: String
    private var _uid: String
    private var _profileImage: UIImage?
    private var _appointments: [Appointment]
    private var _specialty: String
    
    var uid:        String { return _uid }
    var username:   String { return _username }
    var direction:  String { return _direction }
    var email:      String { return _email }
    var phone:      String { return _phone }
    
    var firstName: String {
        set {
            _firstName = newValue
        }
        get {
            return _firstName
        }
    }
    
    var lastName: String {
        set {
            _lastName = newValue
        }
        get {
            return _lastName
        }
    }
    
    var specialty: String {
        set {
            _specialty = newValue
        }
        get {
            return _specialty
        }
    }
    
    var appointments: [Appointment] {
        set {
            _appointments = newValue
        }
        get {
            return _appointments
        }
    }
    
    var profilePicture: UIImage? {
        set {
            _profileImage = newValue
        } get {
             return _profileImage
        }
    }
    
    init(uid: String) {
        _uid = uid
        _firstName = ""
        _lastName = ""
        _username = ""
        _direction = ""
        _email = ""
        _phone = ""
        _specialty = ""
        _appointments = []
    }
    
    init(uid: String, firstName: String, lastName: String, direction: String, email: String, phone: String, specialty: String) {
        _uid = uid
        _firstName = firstName
        _lastName = lastName
        _username = "\(firstName) \(lastName)"
        _direction = direction
        _email = email
        _phone = phone
        _specialty = specialty
        _appointments = []
    }
    
    func add(appointment: Appointment) {
        _appointments.append(appointment)
    }
    
}
