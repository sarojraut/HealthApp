import Foundation

struct HearthRecord {
    private var _bpm: Int
    private var _date: Date
    
    init(bpm: Int, date: Date) {
        _bpm = bpm
        _date = date
    }
    
    var bpm:    Int  { return _bpm }
    var date:   Date { return _date }
}

struct WorkoutRecord {
    private var _type: String
    private var _startDate: Date
    private var _endDate: Date
    private var _caloriesBurned: Double
    
    init(startDate: Date, endDate: Date, caloriesBurned: Double) {
        _startDate = startDate
        _endDate = endDate
        _caloriesBurned = caloriesBurned
        _type = ""
    }
    
    var time:       String { return _endDate.offsetFrom(date: _startDate) }
    var calories:   Double { return _caloriesBurned }
    var startDate:  Date   { return _startDate }
    var endDate:    Date   { return _endDate }
}

struct SleepAnalisys {
    private var _date: Date
    private var _hoursSleeping: String
    
    init(date: Date, hoursSleeping: String) {
        _date = date
        _hoursSleeping = hoursSleeping
    }
    
    var hoursSleeping:  String { return _hoursSleeping }
    var startDate:      Date   {  return _date }
}

struct Height {
    private var _height: Double
    private var _date: Date
    
    init(height: Double, date: Date) {
        _height = height
        _date = date
    }
    
    var height: Double  { return _height }
    var date:   Date    { return _date }
}

struct Weight {
    private var _weight: Double
    private var _date: Date
    
    init(weight: Double, date: Date) {
        _weight = weight
        _date = date
    }
    
    var weight:Double { return _weight }
    var date:  Date   { return _date }
}
