import Foundation
import CoreData

class PersonDAO: BaseDAO {

    override init(managedObjectContext: NSManagedObjectContext) {
        super.init(managedObjectContext: managedObjectContext)
    }
    
    func getPersons() -> [Person]? {
        if let persons = getEntities("Person", includesPendingChanges: true) as? [Person] {
            let sortedPersons = persons.sort{ $0.fullName < $1.fullName }
            return sortedPersons
        }

        return nil
    }
    
    func getPerson(shortName: String) -> Person? {
        return getEntities("Person", includesPendingChanges: true, predicate: NSPredicate(format: "shortName = %@", shortName))?.first as? Person
    }
}
