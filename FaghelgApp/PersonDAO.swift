import Foundation
import CoreData

class PersonDAO: BaseDAO {

    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
    }
    
    func getPersons() -> [Person]? {
        let fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.includesPendingChanges = true
        
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Person] {
            return fetchResults
        }
        else {
            return nil
        }
    }
    
    func getPerson(shortName: String) -> Person? {
        let fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "shortName = %@", shortName)
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Person] {
            return fetchResults.first
        }
        else {
            return nil
        }
    }
    
    func savePerson(person: Person) -> Person? {
        var savedPerson: Person? = nil
        if let shortName = person.shortName {
            if let personFromDatabase = getPerson(person.shortName!) {
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
