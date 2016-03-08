import UIKit
import CoreData

class ImageDAO : BaseDAO {
    
    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
    }
    
    func getImage(url: String) -> Image? {
        var image: Image?
        let nsFetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Image")
        nsFetchRequest.includesPendingChanges = false
        nsFetchRequest.predicate = NSPredicate(format: "url = %@", url)
        let images: NSArray = (try? self.managedObjectContext.executeFetchRequest(nsFetchRequest)) as NSArray!
        
        image = images.firstObject as? Image
        
        return image
    }
}