import Foundation
import CoreData

class EventDAO : BaseDAO {
    
    var personDAO: PersonDAO!
    
    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
        self.personDAO = PersonDAO(managedObjectContext: managedObjectContext)
    }
    
    func saveEvent(event: Event) {
        if let responsible = event.responsible {
            var person = personDAO.savePerson(responsible)
            event.responsible = person
        }
    }
}