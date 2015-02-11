import Foundation
import CoreData

class Program: NSManagedObject {
    @NSManaged var numberOfEvents: NSNumber!
    @NSManaged var events: NSSet
}

extension Program {
    func addEvent(event: Event) {
        self.mutableSetValueForKey("events").addObject(event)
    }
    
    func addEvents(events: [Event]) {
        self.mutableSetValueForKey("events").addObjectsFromArray(events);
    }
    
    func getAllEvents() -> [Event]{
        return self.events.allObjects as [Event]
    }
}
