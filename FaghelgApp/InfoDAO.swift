import CoreData

class InfoDAO : BaseDAO {
    
    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
    }
    
    func getInfo() -> Info? {
        let fetchRequest = NSFetchRequest(entityName: "Info")
        fetchRequest.includesPendingChanges = true
        
        return managedObjectContext.executeFetchRequest(fetchRequest, error: nil)?.first as Info?
    }
}