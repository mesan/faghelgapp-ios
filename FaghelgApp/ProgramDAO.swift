import Foundation
import CoreData

class ProgramDAO : BaseDAO {
    
    var personDAO: PersonDAO!
    
    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
        self.personDAO = PersonDAO(managedObjectContext: managedObjectContext)
    }
    
    func getProgram() -> Program? {
        var program = Program()
        
        if let events = getEntities("Event") as? [Event] {
            program.addEvents(events)
            return program
        }
        
        return nil
    }
    
    func clearProgram() {
        if let program = getProgram() {
            for event in program.events {
                managedObjectContext.deleteObject(event as NSManagedObject)
            }
        }
    }
    
    func saveProgram(program: Program) {
        managedObjectContext.performBlockAndWait { () -> Void in
            self.clearProgram()
            for event in program.events {
                self.saveEvent(event)
            }
        }
    }
    
    private func saveEvent(event: Event) {
        managedObjectContext.insertObject(event)
        if let responsible = event.responsible {
            var person = savePerson(responsible)
            event.responsible = person
        }
    }
    
    private func savePerson(person: Person) -> Person? {
        var savedPerson: Person? = nil
        if let shortName = person.shortName {
            if let personFromDatabase = personDAO.getPerson(person.shortName!) {
                personFromDatabase.fullName = person.fullName
                personFromDatabase.profileImageUrl = person.profileImageUrl
                savedPerson = personFromDatabase
            }
            else {
                managedObjectContext.insertObject(person)
                savedPerson = person
            }
        }
        return savedPerson
    }
}