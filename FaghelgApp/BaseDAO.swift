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
        
        var err: NSError? = nil
        
        result = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &err) as? [NSManagedObject]
        
        if (err != nil) {
            println("Error in getEntities: \(err!.description)")
        }
        
        return result
    }
}
