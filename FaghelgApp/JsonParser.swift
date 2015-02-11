import Foundation
import CoreData

class JsonParser {
    
    class func personFromJson(jsonDict: NSDictionary, managedObjectContext: NSManagedObjectContext) -> Person {
        var person = Person(entity: NSEntityDescription.entityForName("Person", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: nil)
        
        person.id = jsonDict["id"] as? String
        person.fullName = jsonDict["fullName"] as? String
        person.shortName = jsonDict["shortName"] as? String
        person.profileImageUrl = jsonDict["profileImageUrl"] as? String
        
        return person
    }

    class func eventFromJson(jsonDict: NSDictionary, managedObjectContext: NSManagedObjectContext) -> Event {
        var event = Event(entity: NSEntityDescription.entityForName("Event", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: nil)
        
        let startTime = jsonDict["start"] as Double
        event.start = NSDate(timeIntervalSince1970: startTime)
        let endTime = jsonDict["end"] as Double
        event.end = NSDate(timeIntervalSince1970: endTime)
        event.title = jsonDict["title"] as String
        event.desc = jsonDict["description"] as? String
        event.hostNames = jsonDict["hostNames"] as? String
        
        if (jsonDict["responsible"] != nil) {
            var responsibleDict: NSDictionary? = jsonDict["responsible"] as? NSDictionary
            
            event.responsible = personFromJson(responsibleDict!, managedObjectContext: managedObjectContext)
        }
        
        event.tags = jsonDict["tags"] as? String

        return event
    }
    
    class func programFromJson(jsonDict: NSDictionary, managedObjectContext: NSManagedObjectContext) -> Program {
        var program = Program()
        
        program.numberOfEvents = jsonDict["numberOfEvents"] as? Int
        
        program.events = NSMutableSet()
        
        var eventsDict: NSArray = jsonDict["events"] as NSArray
        for eventDict in eventsDict as [NSDictionary] {
            var event = eventFromJson(eventDict, managedObjectContext: managedObjectContext)
            program.addEvent(event)
        }
        
        return program
    }
}
