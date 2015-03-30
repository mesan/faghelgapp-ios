import CoreData

class MessageDAO : BaseDAO {

    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
    }
    
    func getMessages() -> [Message]? {
        if let messages = getEntities("Message") as? [Message] {
            var sortedMessages = sorted(messages){ $0.timestamp > $1.timestamp }
            return sortedMessages
        }
        
        return nil
    }
}