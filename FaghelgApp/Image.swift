import Foundation
import CoreData

class Image: NSManagedObject {
    
    @NSManaged var imageData: NSData
    @NSManaged var url: String
    
    convenience init(imageData: NSData, url: String, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        let entity = NSEntityDescription.entityForName("Image", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.imageData = imageData
        self.url = url
        context.insertObject(self)
    }
    
    func getDescription() -> String {
        return "imageData: \(imageData), url: \(url)"
    }
}
