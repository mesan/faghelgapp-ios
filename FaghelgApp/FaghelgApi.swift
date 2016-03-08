import UIKit
import CoreData

protocol FaghelgApiProtocol {
    func didRecieveResponse(results: NSDictionary)
}

class FaghelgApi : NSObject, NSFetchedResultsControllerDelegate {
    // Production
    let HOST = "https://faghelg.herokuapp.com";

    // Branch
    // let HOST = "https://faghelg-branch.herokuapp.com"
    
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
        let request = makeRequest("/program", HTTPMethod: "GET", withAuthentication: false)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            var program: Program?
            
            if error != nil {
                program = self.programDAO.getProgram()
                callback(program)
                return
            }
            
            do {
                let jsonResult: NSDictionary! = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                if (jsonResult != nil) {
                    program = Program.fromJson(jsonResult, managedObjectContext: self.managedObjectContext!)
                    self.programDAO.clearOldProgram()
                } else {
                    program = self.programDAO.getProgram()
                }

            } catch {
                //TODO: Error handling
            }
            
            
            callback(program)
        })
    }
    
    func getEmployees(callback: ([Person]) -> Void) {
        let request = makeRequest("/persons", HTTPMethod: "GET", withAuthentication: false)

        var employees: [Person]?
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in

            
            if error != nil {
                employees = self.personDAO.getPersons()
                let sortedEmployees = (employees!).sort{ $0.fullName < $1.fullName }
                callback(sortedEmployees)
                return
            }
            
            do {
                let jsonResult: NSArray! = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSArray
                
                if (jsonResult != nil) {
                    employees = []
                    //let employeesFromDataBase = self.personDAO.getEntities("Person", includesPendingChanges: false) as! [Person]
                    
                    for jsonObject in jsonResult {
                        let jsonDict = jsonObject as! NSDictionary
                        let shortName = jsonDict["shortName"] as! String
                        var employee = self.personDAO.getPerson(shortName)
                        
                        if employee == nil {
                            employee = Person.fromJson(jsonDict, insertIntoManagedObjectContext: self.managedObjectContext!)
                        }
                        
                        employees!.append(employee!)
                    }
                } else {
                    employees = self.personDAO.getPersons()
                }

            } catch {
                //TODO: Error handling
            }
            
            let sortedEmployees = (employees!).sort{ $0.fullName < $1.fullName }
            callback(sortedEmployees)
        })
    }

    func getInfo(callback: (Info) -> Void) {
        let request = makeRequest("/info", HTTPMethod: "GET", withAuthentication: false)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            if error != nil {
                if let info = self.infoDAO.getInfo() {
                    callback(info)
                }
                return
            }
            
            
            do {
                var info: Info!
                if let jsonResult: NSDictionary! = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    info = Info.fromJson(jsonResult!, insertIntoManagedObjectContext: self.managedObjectContext!)
                }
                else {
                    info = self.infoDAO.getInfo()
                }
                callback(info)
            } catch {
                //TODO: Error handling
            }
        })
    }
    
    func makeRequest(path: String, HTTPMethod: String, withAuthentication: Bool) -> NSMutableURLRequest {
        let url = HOST + path
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = HTTPMethod
        
        if withAuthentication {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    class func getUrlToImageFromShortname(shortname: String) -> String {
        return CDN + "/" + shortname + ".png"
    }
    
    func registerForPushWithoutLogin(pushDevice: PushDevice) {
        let request = makeRequest("/push?registrationId=\(pushDevice.token)&os=\(pushDevice.os)", HTTPMethod: "GET", withAuthentication: false)

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: { (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if let HTTPResponse = response as? NSHTTPURLResponse {
                if !(HTTPResponse.statusCode == 201) {
                    print("Failed registering for push")
                }
            }
            else {
                // TODO: Alert the user
                print("Can't register for push. No internet connection")
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
        
        let request = makeRequest("/push/register", HTTPMethod: "POST", withAuthentication: true)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params = ["token": pushDevice.token, "owner": pushDevice.owner, "os": pushDevice.os]
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch {
            request.HTTPBody = nil
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            let HTTPResponse = response as! NSHTTPURLResponse
            if HTTPResponse.statusCode == 201 {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "registeredForPush")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        })
    }
    
    func sendPush(title: String, content: String) {
        let request = makeRequest("/push", HTTPMethod: "POST", withAuthentication: true)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "dd.MM.YYYY HH:mm"
        
        let params = ["content": content, "title": title] as Dictionary<String, String>
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch {
            request.HTTPBody = nil
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            var HTTPResponse = response as! NSHTTPURLResponse
        })
    }
}
