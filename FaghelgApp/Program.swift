import Foundation
import CoreData

class Program: NSManagedObject {

    @NSManaged var numberOfEvents: NSNumber!
    @NSManaged var events: NSSet
    
    func setData(dict: NSDictionary) {

        numberOfEvents = dict["numberOfEvents"] as? Int
        
        events = NSMutableSet()
        
        var eventsDict: NSArray = dict["events"] as NSArray
        for eventDict in eventsDict as [NSDictionary] {
            var event = JsonParser.eventFromJson(eventDict, managedObjectContext: managedObjectContext!)

            self.addEvent(event)
            event.setData(eventDict)
        }
        self.managedObjectContext?.save(nil)
    }
}

extension Program {
    func addEvent(event: Event) {
        self.mutableSetValueForKey("events").addObject(event)
    }
    
    func getAllEvents() -> [Event]{
        return self.events.allObjects as [Event]
    }
}
