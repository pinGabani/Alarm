//
//  ViewController.swift
//  Alarm
//
//  Created by pinali gabani on 07/12/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var alarmList = [AlarmList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alarmList = AlarmList.fetch()
        tableView.reloadData()
    }
    
    @IBAction func addAlarmClicked(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlarmAddEditVC") as! AlarmAddEditVC
        vc.navigationItem.title = "Add Alarm"
        vc.alarmInfo = AlarmInfo(curCellIndex: alarmList.count, isEditMode: false, label: "Alarm", mediaLabel: "", mediaID: "", repeatWeekdays: [], enabled: false, snoozeEnabled: false)
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension ViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmListCell", for: indexPath) as! AlarmListCell
        cell.timeLbl.text = alarmList[indexPath.row].time.formattedTime
        cell.alarmSwitch.isOn = alarmList[indexPath.row].isEnabled
        cell.daysLbl.text = WeekdaysViewController.repeatText(weekdays: alarmList[indexPath.row].repeatDays)
        cell.alarmSwitch.tag = indexPath.row
        cell.alarmSwitch.addTarget(self, action: #selector(switchTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlarmAddEditVC") as! AlarmAddEditVC
        vc.navigationItem.title = "Edit Alarm"
        vc.alarmList = alarmList[indexPath.row]
        vc.alarmInfo = AlarmInfo(curCellIndex: indexPath.row, isEditMode: true, label: alarmList[indexPath.row].label, mediaLabel: alarmList[indexPath.row].sound, mediaID: "", repeatWeekdays: alarmList[indexPath.row].repeatDays, enabled: alarmList[indexPath.row].isEnabled, snoozeEnabled: alarmList[indexPath.row].isSnoozeEnabled)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.row
            AlarmList.delete(object: alarmList[indexPath.row])
            alarmList.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
extension ViewController{
    @objc func switchTapped(_ sender : UISwitch){
        let index = sender.tag
        alarmList[index].isEnabled = sender.isOn
        if sender.isOn {
        
        }
        else {
            
        }
    }
}
