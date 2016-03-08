import Foundation
import CoreData

class Message: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var content: String
    @NSManaged var sender: String
    @NSManaged var timestamp: String

    convenience init(title: String, content: String, sender: String, timestamp: String, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        let entity = NSEntityDescription.entityForName("Message", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.title = title
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
        context.insertObject(self)
    }
    
    class func fromPushPayload(pushPayload: NSDictionary, insertIntoManagedObjectContext context: NSManagedObjectContext!) -> Message {
        let aps = pushPayload["aps"] as! NSDictionary
        let alert = aps["alert"] as! NSDictionary
        let title = alert["title"] as! String
        let body = alert["body"] as! String
        let sender = pushPayload["sender"]as! String
        let timestamp = pushPayload["timestamp"] as! String
        
        return Message(title: title, content: body, sender: sender, timestamp: timestamp, insertIntoManagedObjectContext: context)
    }
}
