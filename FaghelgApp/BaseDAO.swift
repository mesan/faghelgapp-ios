import Foundation
import CoreData

class BaseDAO {
    var managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func persist(entity: NSManagedObject) {
        var err: NSError? = nil
        
        self.managedObjectContext.insertObject(entity)
        self.managedObjectContext.save(&err)
        
        if (err != nil) {
            println("Error in persist: \(err!.description)")
        }
    }
    
    func getEntities(entityName: String, predicate: NSPredicate? = nil) -> [NSManagedObject]? {
        var result:[NSManagedObject]?
        
        dispatch_sync(dispatch_get_main_queue(), {
            let fetchRequest = NSFetchRequest(entityName: entityName)
            fetchRequest.includesPendingChanges = true
            fetchRequest.predicate = predicate
            
            var err: NSError? = nil
            
            result = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &err) as? [NSManagedObject]
            
            if (err != nil) {
                println("Error in getEntities: \(err!.description)")
            }
        })
        
        return result
    }
}
