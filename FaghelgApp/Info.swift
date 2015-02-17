import Foundation
import CoreData

class Info: NSManagedObject {

    @NSManaged var address: String
    @NSManaged var locationDescription: String
    @NSManaged var imageUrl: String
    @NSManaged var lat: String
    @NSManaged var lng: String
    @NSManaged var locationName: String
    @NSManaged var hotelDescription: String
    @NSManaged var hotelName: String
    @NSManaged var toDoList: String
    @NSManaged var directions: String

}
