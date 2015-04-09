import UIKit

class EmployeeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var employees: [Person] = []
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var faghelgApi: FaghelgApi!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        faghelgApi = FaghelgApi(managedObjectContext: appDelegate.managedObjectContext!)
        faghelgApi.getEmployees({ self.showEmployees($0) })
    }
    
    override func viewDidAppear(animated: Bool) {
        if employees.isEmpty {
            activityIndicator.startAnimating()
            faghelgApi.getEmployees({ self.showEmployees($0) })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    // return the number of cells needed
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    // create table cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get cell from tableView
        let employeeCell: EmployeeCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EmployeeCell
        
        let person = employees[indexPath.row]
        
        employeeCell.setEmployee(person)
        
        // return the cell
        return employeeCell
    }
    
    func showEmployees(employees: [Person]?) {
        if (employees == nil) {
            self.employees = []
            return
        }
        
        self.employees = employees!
        
        // reload view using main thread
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    // These two functions remove the whitespace in front of the separator
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("separatorInset")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        if cell.respondsToSelector(Selector("layoutMargins")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func viewDidLayoutSubviews() {
        if self.tableView.respondsToSelector(Selector("separatorInset")) {
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if self.tableView.respondsToSelector(Selector("layoutMargins")) {
            self.tableView.layoutMargins = UIEdgeInsetsZero;
        }
    }
}
