import Foundation
import CoreData

class Image: NSManagedObject {
    
    @NSManaged var imageData: NSData
    @NSManaged var shortName: String
    
    convenience init(imageData: NSData, shortName: String, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        let entity = NSEntityDescription.entityForName("Image", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.imageData = imageData
        self.shortName = shortName
        context.insertObject(self)
    }
    
    func getDescription() -> String {
        return "imageData: \(imageData), shortName: \(shortName)"
    }
}
