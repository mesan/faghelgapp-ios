import UIKit
import CoreData

class ImageDAO : BaseDAO {
    
    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
    }
    
    func getImage(url: String) -> Image? {
        var image: Image?
        var nsFetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Image")
        nsFetchRequest.includesPendingChanges = false
        nsFetchRequest.predicate = NSPredicate(format: "url = %@", url)
        var images: NSArray = self.managedObjectContext.executeFetchRequest(nsFetchRequest, error: nil) as NSArray!
        
        image = images.firstObject as? Image
        
        return image
    }
}