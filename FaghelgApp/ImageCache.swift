import CoreData

class ImageCache {
    static let sharedInstance = ImageCache()
    
    private var images = [String: UIImage]()
    
    var imageDAO: ImageDAO
    var managedObjectContext: NSManagedObjectContext!
    
    init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        imageDAO = ImageDAO(managedObjectContext: managedObjectContext!)
        let imagesFromDatabase = imageDAO.getEntities("Image", includesPendingChanges: true) as! [Image]
        for image in imagesFromDatabase {
            images[image.url] = UIImage(data: image.imageData)!
        }
    }
    
    func getImage(url: String) -> UIImage? {
        // Return image from cache if it exists
        if let uiImage = images[url] {
            return uiImage
        }
        
        return nil
    }
    
    func addImage(url: String, image: UIImage) {
        dispatch_async(dispatch_get_main_queue(), {
            let _ = Image(imageData: UIImagePNGRepresentation(image)!, url: url, insertIntoManagedObjectContext: self.managedObjectContext)
        })
        images[url] = image
    }
}
