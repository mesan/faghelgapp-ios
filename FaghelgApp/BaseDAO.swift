import Foundation
import CoreData

class BaseDAO {
    var managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func getEntities(entityName: String, includesPendingChanges: Bool, predicate: NSPredicate? = nil) -> [NSManagedObject]? {
        var result:[NSManagedObject]?
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.includesPendingChanges = includesPendingChanges
        fetchRequest.predicate = predicate
        
        do {
            result = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch let err as NSError {
            print("Error in getEntities: \(err.description)")
        } 
        return result
    }
}
