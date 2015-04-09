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
        var aps = pushPayload["aps"] as! NSDictionary
        var alert = aps["alert"] as! NSDictionary
        var title = alert["title"] as! String
        var body = alert["body"] as! String
        var sender = pushPayload["sender"]as! String
        var timestamp = pushPayload["timestamp"] as! String
        
        return Message(title: title, content: body, sender: sender, timestamp: timestamp, insertIntoManagedObjectContext: context)
    }
}
