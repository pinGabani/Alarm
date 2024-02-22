
import Foundation
import UIKit

protocol AlarmSchedulerDelegate {
    
    func setNotificationWithDate(_ date: Date, onWeekdaysForNotify:[Int], snoozeEnabled: Bool, onSnooze:Bool, soundName: String, index: Int)
    func setNotificationForSnooze(snoozeMinute: Int, soundName: String, index: Int)
    func setupNotificationSettings() -> UNNotificationSettings
    func reSchedule()
    func checkNotification()
}

