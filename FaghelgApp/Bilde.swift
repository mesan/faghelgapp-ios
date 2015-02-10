import Foundation
import CoreData

class Bilde: NSManagedObject {
    
    @NSManaged var imageData: NSData
    @NSManaged var shortName: String
    
    func save() {
        self.managedObjectContext?.save(nil);
    }
    
    func rollback() {
        self.managedObjectContext?.rollback();
    }
    
    func getDescription() -> String {
        return "imageData: \(imageData), shortName: \(shortName)"
    }
}
