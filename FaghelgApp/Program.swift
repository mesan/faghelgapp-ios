import Foundation

class Program: NSObject {
    var numberOfEvents: NSNumber!
    var events: NSMutableSet!
    
    override init() {
        numberOfEvents = NSNumber()
        events = NSMutableSet()
    }
    func addEvent(event: Event) {
        events.addObject(event)
    }
    
    func addEvents(events: [Event]) {
        self.events.addObjectsFromArray(events)
    }
}