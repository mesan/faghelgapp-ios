import Foundation

class Program: NSObject {
    var numberOfEvents: NSNumber!
    var events: [Event]!
    
    override init() {
        numberOfEvents = NSNumber()
        events = [Event]()
    }
    func addEvent(event: Event) {
        events.append(event)
    }
    
    func addEvents(events: [Event]) {
        for event in events {
            addEvent(event)
        }
    }
}