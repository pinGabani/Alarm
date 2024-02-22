//
//  AlarmAddEditVC.swift
//  Alarm
//
//  Created by pinali gabani on 08/12/23.
//

import UIKit

class AlarmAddEditVC: UIViewController {
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    var alarmList : AlarmList?
    var alarmInfo : AlarmInfo!
    var snoozeEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if alarmInfo.isEditMode{
            timePicker.setDate(alarmList!.time, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        snoozeEnabled = alarmInfo.snoozeEnabled
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        var alarm = Alarm()
        alarm.time = timePicker.date
        alarm.isEnabled = true
        alarm.label = alarmInfo.label
        alarm.isSnoozeEnabled = alarmInfo.snoozeEnabled
        alarm.repeatDays = alarmInfo.repeatWeekdays
        alarm.sound = alarmInfo.mediaLabel
        if alarmInfo.isEditMode{
            alarmList?.time = alarm.time
            alarmList?.sound = alarm.sound
            alarmList?.label = alarm.label
            alarmList?.isEnabled = alarm.isEnabled
            alarmList?.isSnoozeEnabled = alarm.isSnoozeEnabled
            alarmList?.repeatDays = alarm.repeatDays
            Scheduler.cancelAllNotifications()
            Scheduler.setNotificationWithDate(alarm.time, onWeekdaysForNotify: alarm.repeatDays, snoozeEnabled: alarm.isSnoozeEnabled, soundName: alarm.sound)
        }
        else
        {
            AlarmList.save(object: alarm)
            Scheduler.setNotificationWithDate(alarm.time, onWeekdaysForNotify: alarm.repeatDays, snoozeEnabled: alarm.isSnoozeEnabled, soundName: alarm.sound)
        }
        navigationController?.popToRootViewController(animated: true)
    }
}
extension AlarmAddEditVC : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier:"alarmEditCell")
        if indexPath.row == 0 {
            cell.textLabel!.text = "Repeat"
            cell.detailTextLabel!.text = WeekdaysViewController.repeatText(weekdays: alarmInfo.repeatWeekdays)
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        else if indexPath.row == 1 {
            cell.textLabel!.text = "Label"
            cell.detailTextLabel!.text = alarmInfo.label
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        else if indexPath.row == 2 {
            cell.textLabel!.text = "Sound"
            cell.detailTextLabel!.text = alarmInfo.mediaLabel
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        else if indexPath.row == 3 {
           
            cell.textLabel!.text = "Snooze"
            let sw = UISwitch(frame: CGRect())
            sw.addTarget(self, action: #selector(snoozeSwitchTapped(_:)), for: .touchUpInside)
            
            if snoozeEnabled {
               sw.setOn(true, animated: false)
            }
            
            cell.accessoryView = sw
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
            switch indexPath.row{
            case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WeekdaysViewController") as! WeekdaysViewController
                vc.delegate = self
                vc.weekdays = alarmInfo.repeatWeekdays
                navigationController?.pushViewController(vc, animated: true)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            case 1:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LabelEditVC") as! LabelEditVC
                vc.delegate = self
                vc.label = alarmInfo.label
                navigationController?.pushViewController(vc, animated: true)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            case 2:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MediaVC") as! MediaVC
                vc.delegate = self
                vc.mediaLabel = alarmInfo.mediaLabel
                navigationController?.pushViewController(vc, animated: true)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            default:
                break
            }
        }
    }
    
    @objc func snoozeSwitchTapped (_ sender: UISwitch) {
        snoozeEnabled = sender.isOn
    }
}
extension AlarmAddEditVC : WeekdaysDelegate{
    func weekDays(days: [Int]) {
        alarmInfo.repeatWeekdays = days
    }
}
extension AlarmAddEditVC : LabelDelegate{
    func labelDidChange(label: String) {
        alarmInfo.label = label
    }
}
extension AlarmAddEditVC : MediaDelegate{
    func media(sound: String) {
        alarmInfo.mediaLabel = sound
    }
}
