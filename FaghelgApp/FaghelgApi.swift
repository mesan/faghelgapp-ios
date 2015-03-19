import UIKit
import CoreData

protocol FaghelgApiProtocol {
    func didRecieveResponse(results: NSDictionary)
}

class FaghelgApi : NSObject, NSFetchedResultsControllerDelegate {
    let HOST = "http://faghelg.herokuapp.com";
    
    var data: NSMutableData = NSMutableData()
    var delegate: FaghelgApiProtocol?
    
    var managedObjectContext: NSManagedObjectContext?
    
    var programDAO: ProgramDAO!
    var personDAO: PersonDAO!
    var imageDAO: ImageDAO!
    var infoDAO: InfoDAO!

    init(managedObjectContext: NSManagedObjectContext) {
        super.init()
        self.managedObjectContext = managedObjectContext
        self.programDAO = ProgramDAO(managedObjectContext: managedObjectContext)
        self.personDAO = PersonDAO(managedObjectContext: managedObjectContext)
        self.imageDAO = ImageDAO(managedObjectContext: managedObjectContext)
        self.infoDAO = InfoDAO(managedObjectContext: managedObjectContext)
    }
    
    func getProgram(callback: (Program?) -> Void) {
        var request = makeRequest("/program")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var program: Program?
            
            if error != nil {
                program = self.programDAO.getProgram()
                callback(program)
                return
            }
            
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                program = JsonParser.programFromJson(jsonResult, managedObjectContext: self.managedObjectContext!)
                self.programDAO.saveProgram(program!)
            } else {
                program = self.programDAO.getProgram()
            }
            
            callback(program)
        })
    }
    
    func getEmployees(callback: ([Person]) -> Void) {
        var request = makeRequest("/persons")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var employees: [Person]?
            
            if error != nil {
                
                employees = self.personDAO.getPersons()
                var sortedEmployees = sorted(employees!){ $0.fullName < $1.fullName }
                callback(sortedEmployees)
                return
            }
            
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSArray! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSArray
            
            if (jsonResult != nil) {
                employees = [Person]()
                for jsonObject in jsonResult {
                    var jsonDict = jsonObject as NSDictionary
                    let employee = JsonParser.personFromJson(jsonDict, managedObjectContext: self.managedObjectContext!)
                    employees!.append(employee)
                    self.personDAO.savePerson(employee)
                    self.managedObjectContext?.save(nil);
                }
            } else {
                employees = self.personDAO.getPersons()
            }
            
            var sortedEmployees = sorted(employees!){ $0.fullName < $1.fullName }
            callback(sortedEmployees)
        })
    }

    func getInfo(callback: (Info?) -> Void) {
        var request = makeRequest("/info")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var info: Info?
            
            if error != nil {
                info = self.infoDAO.getInfo()
                callback(info)
                return
            }
            
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                info = JsonParser.infoFromJson(jsonResult, managedObjectContext: self.managedObjectContext!)
                self.infoDAO.persist(info!)
            } else {
                info = self.infoDAO.getInfo()
            }
            
            callback(info)
        })

        
    }
    
    func makeRequest(path: String) -> NSMutableURLRequest {
        var url = HOST + path
        var request = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        return request
    }
    
    func getImage(imageUrl: String, callback: (UIImage?) -> Void) {
        var managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        

        let shortName = imageUrl.componentsSeparatedByString("/").last!
        
        if let imageFromDatabase = imageDAO.getImage(shortName) {
            callback(UIImage(data: imageFromDatabase.imageData))
            return
        }
        
        
        
        if let imageData = downloadImageFromWeb(imageUrl, shortName: shortName, managedObjectContext: managedObjectContext!) {
            callback(UIImage(data: imageData)!)
            return
        }
        
        callback(UIImage(named: "ukjent"))
    }
    
    func downloadImageFromWeb(imageUrl: String, shortName: String, managedObjectContext: NSManagedObjectContext) -> NSData? {
        let url = NSURL(string:imageUrl);
        var err: NSError? = nil
        
        if let imageData = NSData(contentsOfURL: url!,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.saveBilde(imageData, shortName: shortName)
            })

            return imageData
        }
        
        return nil
    }
    
    func saveBilde(imageData: NSData, shortName: String) {
        var bilde: Bilde = Bilde(entity: NSEntityDescription.entityForName("Bilde", inManagedObjectContext: managedObjectContext!)!, insertIntoManagedObjectContext: managedObjectContext)
        
        bilde.shortName = shortName
        bilde.imageData = imageData
        imageDAO.persist(bilde)
    }
    

}
