import UIKit
import CoreData

protocol FaghelgApiProtocol {
    func didRecieveResponse(results: NSDictionary)
}

class FaghelgApi : NSObject, NSFetchedResultsControllerDelegate {
    // Production
    // let HOST = "http://faghelg.herokuapp.com";

    // Branch
    let HOST = "http://faghelg-branch.herokuapp.com"
    
    // Andersmac@mesan
    //let HOST = "http://10.22.200.151:8080";
    
    
    // Simulator local
    //let HOST = "http://localhost:8080"
    
    let CDN = "http://faghelg.s3-website-eu-west-1.amazonaws.com"
    
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
        var request = makeRequest("/program", HTTPMethod: "GET", withAuthentication: false)
        
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
        var request = makeRequest("/persons", HTTPMethod: "GET", withAuthentication: false)
        
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
        var request = makeRequest("/info", HTTPMethod: "GET", withAuthentication: false)
        
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
    
    func makeRequest(path: String, HTTPMethod: String, withAuthentication: Bool) -> NSMutableURLRequest {
        var url = HOST + path
        var request = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = HTTPMethod
        
        if withAuthentication {
            var token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func getImageForShortname(shortname: String, callback: (UIImage?) -> Void) {
        getImage(CDN + "/" + shortname + ".png", callback: callback)
    }
    
    func getImage(imageUrl: String, callback: (UIImage?) -> Void) {
        var managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        

        let shortName = imageUrl.componentsSeparatedByString("/").last!
        var uiImage: UIImage?
        if let imageFromDatabase = self.imageDAO.getImage(shortName) {
            uiImage = UIImage(data: imageFromDatabase.imageData)
        }
        
        if uiImage != nil {
            callback(uiImage)
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
            imageDAO.saveImage(imageData, shortName: shortName)
            return imageData
        }
        
        return nil
    }
    
    func registerForPush(pushDevice: PushDevice) {
        if let registeredForPush = NSUserDefaults.standardUserDefaults().objectForKey("registeredForPush") as? Bool {
            if (registeredForPush) {
                // This device has already registered for push. No need to register again
                return
            }
        }
        
        var request = makeRequest("/push/register", HTTPMethod: "POST", withAuthentication: true)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var err: NSError?
        var params = ["token": pushDevice.token, "owner": pushDevice.owner, "os": pushDevice.os]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var HTTPResponse = response as NSHTTPURLResponse
            if HTTPResponse.statusCode == 201 {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "registeredForPush")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        })
    }
    
    func sendPushIos(message: Message) {
        var request = makeRequest("/push", HTTPMethod: "POST", withAuthentication: true)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "dd.MM.YYYY HH:mm"
        var timestamp = dateStringFormatter.stringFromDate(NSDate())
        
        var params = ["content": message.content!, "title": message.title!] as Dictionary<String, String>
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var HTTPResponse = response as NSHTTPURLResponse
        })
    }
}
