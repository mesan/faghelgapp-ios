import Foundation
import CoreData

class Person: NSManagedObject {
    @NSManaged var shortName: String!
    @NSManaged var fullName: String!
    @NSManaged var profileImageUrl: String!
    
    convenience init(shortName: String, fullName: String, profileImageUrl: String, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: context)
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.shortName = shortName
        self.fullName = fullName
        self.profileImageUrl = profileImageUrl
        context.insertObject(self)
    }
    
    class func fromJson(jsonDict: NSDictionary, insertIntoManagedObjectContext context: NSManagedObjectContext) -> Person {
        let fullName = jsonDict["fullName"] as! String
        let shortName = jsonDict["shortName"] as! String
        let profileImageUrl = jsonDict["profileImageUrl"] as! String
        
        var person = Person(shortName: shortName, fullName: fullName, profileImageUrl: profileImageUrl, insertIntoManagedObjectContext: context)
        
        return person
    }
}
