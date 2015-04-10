import Foundation
import CoreData

class Event: NSManagedObject {
    @NSManaged var start: NSDate!
    @NSManaged var end: NSDate!
    @NSManaged var desc: String?
    @NSManaged var title: String?
    @NSManaged var hostNames: String?
    @NSManaged var eventImageUrl: String?
    @NSManaged var responsible: Person?
    
    convenience init(start: NSDate, end: NSDate, desc: String?, title: String?, hostNames: String?, eventImageUrl: String?, responsible: Person?, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: context)
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.start = start
        self.end = end
        self.desc = desc
        self.title = title
        self.hostNames = hostNames
        self.eventImageUrl = eventImageUrl
        self.responsible = responsible
        context.insertObject(self)
    }
    
    class func fromJson(jsonDict: NSDictionary, insertIntoManagedObjectContext context: NSManagedObjectContext) -> Event {
        let startTime = jsonDict["start"] as! Double
        let start = NSDate(timeIntervalSince1970: startTime)
        let endTime = jsonDict["end"] as! Double
        let end = NSDate(timeIntervalSince1970: endTime)
        let title = jsonDict["title"] as? String
        let eventImageUrl = jsonDict["eventImageUrl"] as? String
        let desc = jsonDict["description"] as? String
        let hostNames = jsonDict["hostNames"] as? String
        
        var responsible: Person? = nil;
        if let responsibleDict = jsonDict["responsible"] as? NSDictionary {
            var personDAO = PersonDAO(managedObjectContext: context)
            
            var shortName = responsibleDict["shortName"] as! String
            var responsible = personDAO.getPerson(shortName)
            
            if responsible == nil {
                responsible = Person.fromJson(jsonDict, insertIntoManagedObjectContext: context)
            }
        }
        
        var event = Event(start: start, end: end, desc: desc, title: title, hostNames: hostNames, eventImageUrl: eventImageUrl, responsible: responsible, insertIntoManagedObjectContext: context)
        
        return event
    }

}
