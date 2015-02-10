

import Foundation
import CoreData

class Person: NSManagedObject {

    @NSManaged var id: String?
    @NSManaged var shortName: String?
    @NSManaged var fullName: String?
    @NSManaged var profileImageUrl: String?
    
    func setData(dict: NSDictionary) {
        self.managedObjectContext!.save(nil)
    }
}
