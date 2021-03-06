import Foundation
import EventKit

class Appointment {
    private var _startDate: Date
    private var _endDate: Date
    private var _doctorUid: String
    private var _patientUid: String
    private var _notes: String?
    private var _id: String
    private var _patientLocalIdentifier: String?
    private var _doctorLocalIdentifier: String?
    
    init(startDate: Date, endDate: Date, doctorUid: String, patientUid: String) {
        _startDate = startDate
        _endDate = endDate
        _doctorUid = doctorUid
        _patientUid = patientUid
        _id = "\(startDate)-\(doctorUid)-\(patientUid)"
    }
    
    var doctorUid:  String { return _doctorUid }
    var id:         String { return _id }
    var patientUid: String { return _patientUid }
    var startDate:  Date { return _startDate }
    var endDate:    Date { return _endDate }
    
    var doctorLocalIdentifier: String? {
        set {
            _doctorLocalIdentifier = newValue
        }
        get {
            return _doctorLocalIdentifier
        }
    }
    
    var localIdentifier: String? {
        set {
            _patientLocalIdentifier = newValue
        }
        get {
            return _patientLocalIdentifier
        }
    }
    
    var notes: String? {
        set {
            _notes = newValue
        }
        get {
            return _notes
        }
    }
    
    var duration: String {
        return "1 Hour"
    }
    
    func sendToServer() {
        DatabaseService.shared.create(appointment: self)
    }
    
    func totalRemoveFromServer() {
        DatabaseService.shared.totalRemove(appointment: self)
    }
    
    func removeFromServer() {
        DatabaseService.shared.remove(appointment: self)
    }
    
    func removeFromLocalCalendar() -> Bool {
        var removed = true
        let eventStore: EKEventStore = EKEventStore()
        let eventToRemove = eventStore.event(withIdentifier: self.localIdentifier!)
        do {
            if eventToRemove != nil {
                try eventStore.remove(eventToRemove!, span: .thisEvent)
            }
        } catch {
            removed = false
        }
        
        return removed
    }
    
    func createInCalendar(doctor: Doctor) -> String? {
        var messageInfo: String?
        let eventStore: EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                let title = "\(NSLocalizedString("createAppointment.title", comment: "")) \(doctor.specialty) \(doctor.username)"
                let event: EKEvent = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = self.startDate
                event.endDate = self.endDate
                event.notes = self.notes
                event.location = doctor.direction
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                    self.localIdentifier = event.eventIdentifier
                    _ = self.sendToServer()
                } catch let error as NSError {
                    messageInfo = NSLocalizedString("createAppointment.localError", comment: "")
                    _ = self.removeFromServer()
                    print("ERROR => \(error)")
                }
            } else {
                messageInfo = NSLocalizedString("errorInfo.accesNotGranted", comment: "")
            }
        }
        return messageInfo
    }
    
}
