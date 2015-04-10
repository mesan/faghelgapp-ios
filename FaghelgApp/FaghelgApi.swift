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
    
    
    // Andersmac@home
    //let HOST = "http://192.168.0.198:8080"
    
    // Andersmac@mesan
    //let HOST = "http://10.22.200.155:8080";
    
    
    // Simulator local
    //let HOST = "http://localhost:8080"
    
    static let CDN = "http://faghelg.s3-website-eu-west-1.amazonaws.com"
    
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
                program = Program.fromJson(jsonResult, managedObjectContext: self.managedObjectContext!)
                self.programDAO.clearOldProgram()
            } else {
                program = self.programDAO.getProgram()
            }
            
            callback(program)
        })
    }
    
    func getEmployees(callback: ([Person]) -> Void) {
        var request = makeRequest("/persons", HTTPMethod: "GET", withAuthentication: false)

        var employees: [Person]?
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in

            
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
                let employeesFromDataBase = self.personDAO.getEntities("Person", includesPendingChanges: false) as! [Person]
                
                for jsonObject in jsonResult {
                    var jsonDict = jsonObject as! NSDictionary
                    var shortName = jsonDict["shortName"] as! String
                    var employee = self.personDAO.getPerson(shortName)
                    
                    if employee == nil {
                        employee = Person.fromJson(jsonDict, insertIntoManagedObjectContext: self.managedObjectContext!)
                    }
                    
                    employees!.append(employee!)
                }
            } else {
                employees = self.personDAO.getPersons()
            }
            
            var sortedEmployees = sorted(employees!){ $0.fullName < $1.fullName }
            callback(sortedEmployees)
        })
    }

    func getInfo(callback: (Info) -> Void) {
        var request = makeRequest("/info", HTTPMethod: "GET", withAuthentication: false)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error != nil {
                if let info = self.infoDAO.getInfo() {
                    callback(info)
                }
                return
            }
            
            var info: Info!
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            if let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary {
                info = Info.fromJson(jsonResult!, insertIntoManagedObjectContext: self.managedObjectContext!)
            }
            else {
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
    
    class func getUrlToImageFromShortname(shortname: String) -> String {
        return CDN + "/" + shortname + ".png"
    }
    
    func registerForPushWithoutLogin(pushDevice: PushDevice) {
        var request = makeRequest("/push?registrationId=\(pushDevice.token)&os=\(pushDevice.os)", HTTPMethod: "GET", withAuthentication: false)

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: { (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if let HTTPResponse = response as? NSHTTPURLResponse {
                if !(HTTPResponse.statusCode == 201) {
                    println("Failed registering for push")
                }
            }
            else {
                // TODO: Alert the user
                println("Can't register for push. No internet connection")
            }
        })
        
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
            var HTTPResponse = response as! NSHTTPURLResponse
            if HTTPResponse.statusCode == 201 {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "registeredForPush")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        })
    }
    
    func sendPush(title: String, content: String) {
        var request = makeRequest("/push", HTTPMethod: "POST", withAuthentication: true)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "dd.MM.YYYY HH:mm"
        var timestamp = dateStringFormatter.stringFromDate(NSDate())
        
        var params = ["content": content, "title": title] as Dictionary<String, String>
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var HTTPResponse = response as! NSHTTPURLResponse
        })
    }
}
