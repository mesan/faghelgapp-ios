import Foundation
import CoreData

class PersonDAO: BaseDAO {

    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
    }
    
    func getPersons() -> [Person]? {
        if let persons = getEntities("Person", includesPendingChanges: true) as? [Person] {
            var sortedPersons = sorted(persons){ $0.fullName < $1.fullName }
            return sortedPersons
        }

        return nil
    }
    
    func getPerson(shortName: String) -> Person? {
        return getEntities("Person", includesPendingChanges: true, predicate: NSPredicate(format: "shortName = %@", shortName))?.first as? Person
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
