import Foundation
import CoreData

class ProgramDAO: BaseDAO {
    
    var personDAO: PersonDAO!
    
    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
        self.personDAO = PersonDAO(managedObjectContext: managedObjectContext)
    }
    
    func getProgram() -> Program? {
        var program = Program()
        
        if let events = getEntities("Event", includesPendingChanges: false) as? [Event] {
            program.addEvents(events)
            return program
        }
        
        return nil
    }
    
    func clearOldProgram() {
        if let program = getProgram() {
            for event in program.events {
                managedObjectContext.deleteObject(event as NSManagedObject)
            }
        }
    }
}