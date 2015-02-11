import UIKit
import CoreData

class ImageDAO : BaseDAO {
    
    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
    }
    
    func getImage(shortName: String) -> Bilde? {
        var nsFetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Bilde")
        nsFetchRequest.includesPendingChanges = false
        nsFetchRequest.predicate = NSPredicate(format: "shortName = %@", shortName)
        var images: NSArray = managedObjectContext.executeFetchRequest(nsFetchRequest, error: nil) as NSArray!
        
        if let image = images.firstObject as? Bilde {
            return image
        }
        
        return nil
    }
}