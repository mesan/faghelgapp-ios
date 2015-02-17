import Foundation
import CoreData

class BaseDAO {
    var managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func persist(entity: NSManagedObject) {
        var err: NSError? = nil
        
        managedObjectContext.insertObject(entity)
        managedObjectContext.save(&err)
        
        if (err != nil) {
            println("Error in persist: \(err!.description)")
        }
    }
    
    func getEntities(entityName: String, predicate: NSPredicate? = nil) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.includesPendingChanges = true
        fetchRequest.predicate = predicate
        
        var err: NSError? = nil
        
        var result = managedObjectContext.executeFetchRequest(fetchRequest, error: &err) as? [NSManagedObject]
        
        if (err != nil) {
            println("Error in getEntities: \(err!.description)")
        }
        
        return result
    }
}
