

import Foundation
import UIKit
import UserNotifications

class Scheduler{
    
    class func setNotificationWithDate(_ date: Date, onWeekdaysForNotify weekdays:[Int], snoozeEnabled:Bool, soundName: String) {
        
        let AlarmNotification = UNMutableNotificationContent()
        AlarmNotification.title = "Wake Up!"
        AlarmNotification.body = ""
        AlarmNotification.categoryIdentifier = "myAlarmCategory"
        AlarmNotification.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Ping1.mp3"))
        
        for weekday in weekdays {
            
            var dateComponents1 = DateComponents()
            let calendar = Calendar.current
            dateComponents1.hour = calendar.component(.hour, from: date)
            dateComponents1.minute = calendar.component(.minute, from: date)
            dateComponents1.weekday = weekday
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents1, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: AlarmNotification, trigger: trigger)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                }
            }
        }
    }
    
    class func cancelAllNotifications(){
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()    // to remove all delivered notifications
        center.removeAllPendingNotificationRequests()   // to remove all pending notifications
        UIApplication.shared.applicationIconBadgeNumber = 0 // to clear the icon notification badge
    }
}


