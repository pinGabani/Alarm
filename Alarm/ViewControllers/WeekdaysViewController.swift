
import UIKit

protocol WeekdaysDelegate : NSObjectProtocol{
    func weekDays(days : [Int])
}

class WeekdaysViewController: UITableViewController {
    
    var weekdays: [Int]!
    var delegate : WeekdaysDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        for weekday in weekdays
        {
            if weekday == (indexPath.row + 1) {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        if let index = weekdays.firstIndex(of: (indexPath.row + 1)){
            weekdays.remove(at: index)
            cell.setSelected(true, animated: true)
            cell.setSelected(false, animated: true)
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        else{
            //row index start from 0, weekdays index start from 1 (Sunday), so plus 1
            weekdays.append(indexPath.row + 1)
            delegate?.weekDays(days: weekdays)
            cell.setSelected(true, animated: true)
            cell.setSelected(false, animated: true)
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
    }
}
extension WeekdaysViewController {
    static func repeatText(weekdays: [Int]) -> String {
        if weekdays.count == 7 {
            return "Every day"
        }
        
        if weekdays.isEmpty {
            return "Never"
        }
        
        var ret = String()
        var weekdaysSorted:[Int] = [Int]()
        
        weekdaysSorted = weekdays.sorted(by: <)
        
        for day in weekdaysSorted {
            switch day{
            case 1:
                ret += "Sun "
            case 2:
                ret += "Mon "
            case 3:
                ret += "Tue "
            case 4:
                ret += "Wed "
            case 5:
                ret += "Thu "
            case 6:
                ret += "Fri "
            case 7:
                ret += "Sat "
            default:
                //throw
                break
            }
        }
        return ret
    }
}
