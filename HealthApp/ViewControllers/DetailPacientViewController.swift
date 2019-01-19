import UIKit

class DetailPacientViewController: UITableViewController {
    
    var arrayToShow = [Any]()
    var healthDataName: HealthDataName!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 100
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayToShow.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "RecordCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PatientCell
        
        cell.backgroundImage.image = UIImage(named: "green")
        
        if let hearthRecords = arrayToShow as? [HearthRecord] {
            cell.dateLabel.text = hearthRecords[indexPath.row].date.formattedDate
            cell.quantityLabel.text = "\(hearthRecords[indexPath.row].bpm)"
            cell.titleLabel.text = "Hearth Record"
            cell.unitLabel.text = "bmp"
            cell.backgroundImage.image = UIImage(named: "soft-red")
        } else if let heightRecords = arrayToShow as? [Height] {
            cell.dateLabel.text = heightRecords[indexPath.row].date.formattedDate
            cell.quantityLabel.text = "\(heightRecords[indexPath.row].height)"
            cell.titleLabel.text = "Height Record"
            cell.unitLabel.text = "Mts"
        } else if let weightRecords = arrayToShow as? [Weight] {
            cell.dateLabel.text = weightRecords[indexPath.row].date.formattedDate
            cell.quantityLabel.text = "\(weightRecords[indexPath.row].weight)"
            cell.titleLabel.text = "Weight Record"
            cell.unitLabel.text = "Lb"
        } else if let sleepRecords = arrayToShow as? [SleepAnalisys] {
            cell.dateLabel.text = sleepRecords[indexPath.row].startDate.formattedDate
            cell.quantityLabel.text = sleepRecords[indexPath.row].hoursSleeping
            cell.titleLabel.text = "Sleep Record"
            cell.unitLabel.text = ""
            cell.backgroundImage.image = UIImage(named: "Blue")
        }
        
        return cell
    }

}
