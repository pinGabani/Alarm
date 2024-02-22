//
//  AlarmInfo.swift
//  Alarm
//
//  Created by pinali gabani on 11/12/23.
//

import Foundation

struct AlarmInfo {
    var curCellIndex: Int
    var isEditMode: Bool
    var label: String
    var mediaLabel: String
    var mediaID: String
    var repeatWeekdays: [Int]
    var enabled: Bool
    var snoozeEnabled: Bool
}

public struct Alarm
{
    var uid : String = ""
    var time : Date = Date()
    var isEnabled : Bool = true
    var label : String = ""
    var isSnoozeEnabled : Bool = true
    var sound : String = ""
    var repeatDays : [Int] = []
}

