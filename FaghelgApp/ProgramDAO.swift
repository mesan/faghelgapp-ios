import Foundation
import CoreData

class ProgramDAO : BaseDAO {
    
    var eventDAO: EventDAO!
    
    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
        self.eventDAO = EventDAO(managedObjectContext: managedObjectContext)
    }
    
    func getProgram() -> Program? {
        let fetchRequest = NSFetchRequest(entityName: "Program")
        fetchRequest.includesPendingChanges = true
        
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Program] {
            return fetchResults.first
        }
        else {
            return nil
        }
    }
    
    func clearProgram() {
        if let program = getProgram() {
            managedObjectContext.deleteObject(program)
            managedObjectContext.save(nil)
        }
    }
    
    func saveProgram(program: Program) {
        for event in program.events.allObjects as [Event] {
            eventDAO.saveEvent(event)
        }
        managedObjectContext.save(nil)
    }
}