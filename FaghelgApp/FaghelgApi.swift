import UIKit
import Alamofire
import CoreData
import BrightFutures

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

    init(managedObjectContext: NSManagedObjectContext) {
        super.init()
        self.managedObjectContext = managedObjectContext
        self.programDAO = ProgramDAO(managedObjectContext: managedObjectContext)
        self.personDAO = PersonDAO(managedObjectContext: managedObjectContext)
    }
    
    func getProgram(programViewController: ProgramViewController) {
        var url : String = HOST + "/program"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var program: Program?
            
            if error != nil {
                program = self.programDAO.getProgram()
                programViewController.showProgram(program)
                return
            }
            
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                self.programDAO.clearProgram()
                program = JsonParser.programFromJson(jsonResult, managedObjectContext: self.managedObjectContext!)
                self.programDAO.saveProgram(program!)
            } else {
                program = self.programDAO.getProgram()
            }
            
            programViewController.showProgram(program)
        })
    }
    
    // returns a promise of a list of employees
    func getEmployees(employeeViewController: EmployeeViewController) {
        var url : String = HOST + "/persons"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var employees: [Person]?
            
            if error != nil {
                employees = self.personDAO.getPersons()
                employeeViewController.showEmployees(employees)
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
                }
            } else {
                employees = self.personDAO.getPersons()
            }
            
            employeeViewController.showEmployees(employees)
        })
    }
}
