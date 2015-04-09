import CoreData

class Program: NSObject {
    var numberOfEvents: Int!
    var events: [Event]!
    
    override init() {
        numberOfEvents = Int()
        events = [Event]()
    }
    
    init(numberOfEvents: Int?, events: [Event]) {
        self.numberOfEvents = numberOfEvents
        self.events = events
    }
    
    func addEvent(event: Event) {
        events.append(event)
    }
    
    func addEvents(events: [Event]) {
        for event in events {
            addEvent(event)
        }
    }
    
    class func fromJson(jsonDict: NSDictionary, managedObjectContext: NSManagedObjectContext) -> Program {
        var numberOfEvents = jsonDict["numberOfEvents"] as? Int
        var events = [Event]()
        
        var eventsDict: NSArray = jsonDict["events"] as! NSArray
        for eventDict in eventsDict as! [NSDictionary] {
            var event = Event.fromJson(eventDict, insertIntoManagedObjectContext: managedObjectContext)
            events.append(event)
        }
        
        return Program(numberOfEvents: numberOfEvents, events: events)
    }

}