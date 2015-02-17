import Foundation
import CoreData

class Bilde: NSManagedObject {
    
    @NSManaged var imageData: NSData
    @NSManaged var shortName: String
    
    func getDescription() -> String {
        return "imageData: \(imageData), shortName: \(shortName)"
    }
}
