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
}
