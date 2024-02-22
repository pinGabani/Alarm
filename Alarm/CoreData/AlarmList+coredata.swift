//
//  AlarmList+coredata.swift
//  Alarm
//
//  Created by pinali gabani on 08/12/23.
//

import Foundation   
import CoreData

public extension AlarmList {
    @nonobjc class func fetchRequest() -> NSFetchRequest<AlarmList> {
        return NSFetchRequest<AlarmList>(entityName: "AlarmList")
    }

    @NSManaged var id : String
    @NSManaged var time: Date
    @NSManaged var sound: String
    @NSManaged var label: String
    @NSManaged var isEnabled : Bool
    @NSManaged var isSnoozeEnabled : Bool
    @NSManaged var repeatDays: [Int]
    
    class func delete(object : AlarmList){
        let context = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        context.delete(object)
    }
    
    class func save(object: Alarm) {
        
        let context = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        
        let AlarmList = NSEntityDescription.insertNewObject(forEntityName: "AlarmList", into: context) as! AlarmList
        AlarmList.time = object.time
        AlarmList.sound = object.sound
        AlarmList.label = object.label
        AlarmList.isEnabled = object.isEnabled
        AlarmList.isSnoozeEnabled = object.isSnoozeEnabled
        AlarmList.repeatDays = object.repeatDays
        
        do {
            try context.save()
            print("successfully saved")
        } catch {
            print("Could not save")
        }
    }
    
    class func fetch() -> [AlarmList] {
        var alarmList = [AlarmList]()
        let context = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        do {
            
            alarmList =
                try context.fetch(AlarmList.fetchRequest())
        } catch {
            print("couldnt fetch")
        }
        return alarmList
    }
}

extension AlarmList: Identifiable {}

