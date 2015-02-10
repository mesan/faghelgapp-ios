import Foundation
import CoreData

class Event: NSManagedObject {

    @NSManaged var start: NSDate!
    @NSManaged var end: NSDate!
    @NSManaged var desc: String!
    @NSManaged var title: String!
    @NSManaged var hostNames: String!
    @NSManaged var tags: String?
    @NSManaged var responsible: Person?
    
    func setData(dict: NSDictionary) {
        let startTime = dict["start"] as Double
        start = NSDate(timeIntervalSince1970: startTime)
        let endTime = dict["end"] as Double
        end = NSDate(timeIntervalSince1970: endTime)
        title = dict["title"] as String
        desc = dict["description"] as? String
        hostNames = dict["hostNames"] as? String
        
        if (dict["responsible"] != nil) {
            var responsibleDict: NSDictionary? = dict["responsible"] as? NSDictionary
            
            //responsible = Person(entity: NSEntityDescription.entityForName("Person", inManagedObjectContext: managedObjectContext!)!, insertIntoManagedObjectContext: self.managedObjectContext)
            
            responsible = JsonParser.personFromJson(dict, managedObjectContext: managedObjectContext!)
            responsible!.setData(responsibleDict!)
        }
        
        tags = dict["tags"] as? String
    }
    
}
