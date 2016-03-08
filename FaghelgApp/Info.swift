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
    @NSManaged var toDoList: String?
    @NSManaged var directions: String?

    convenience init(address: String, locationDescription: String, imageUrl: String, lat: String, lng: String, locationName: String, hotelDescription: String, hotelName: String, toDoList: String?, directions: String?, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Info", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.address = address
        self.locationDescription = locationDescription
        self.imageUrl = imageUrl
        self.lat = lat
        self.lng = lng
        self.locationName = locationName
        self.hotelDescription = hotelDescription
        self.hotelName = hotelName
        self.toDoList = toDoList
        self.directions = directions
        context.insertObject(self)
    }
    
    class func fromJson(jsonDict: NSDictionary, insertIntoManagedObjectContext context: NSManagedObjectContext) -> Info {
        let imageUrl = jsonDict["imageUrl"] as! String
        let locationName = jsonDict["locationName"] as! String
        let locationDescription = jsonDict["locationDescription"] as! String
        let address = jsonDict["address"]as! String
        let lat = jsonDict["lat"] as! String
        let lng = jsonDict["lng"]as! String
        let hotelName = (jsonDict["hotelName"] as! String).capitalizedString
        let hotelDescription = jsonDict["hotelDescription"]as! String
        
        let info = Info(address: address, locationDescription: locationDescription, imageUrl: imageUrl, lat: lat, lng: lng, locationName: locationName, hotelDescription: hotelDescription, hotelName: hotelName, toDoList: nil, directions: nil, insertIntoManagedObjectContext: context)
        
        return info
    }
}
