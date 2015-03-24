import Foundation
import CoreData

class Image: NSManagedObject {
    
    @NSManaged var imageData: NSData
    @NSManaged var shortName: String
    
    func getDescription() -> String {
        return "imageData: \(imageData), shortName: \(shortName)"
    }
}
