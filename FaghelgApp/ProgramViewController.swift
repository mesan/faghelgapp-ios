import Foundation
import UIKit
import CoreData

class ProgramViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum Day : Int {
        case Sunday = 1
        case Monday
        case Tuesday
        case Wednesday
        case Thursday
        case Friday
        case Saturday
        
        var description : String {
            switch(self) {
            case Sunday: return "Søndag"
            case Monday: return "Mandag"
            case Tuesday: return "Tirsdag"
            case Wednesday: return "Onsdag"
            case Thursday: return "Torsdag"
            case Friday: return "Fredag"
            case Saturday: return "Lørdag"
            }
        }
    }
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var faghelgApi: FaghelgApi!
    var imageCache = ImageCache.sharedInstance
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayFilter: UISegmentedControl!
    
    var allEvents: [Event] = []
    var filteredEvents : [Event] = []
    var eventDates: [NSDate] = []
    let cellIdentifier = "eventCell"
    
    var selectedIndexPath: NSIndexPath?
    
    var program: Program?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        faghelgApi = FaghelgApi(managedObjectContext: appDelegate.managedObjectContext!)
        
        initRefreshControl()
    }
    
    func initRefreshControl() {
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("handleRefresh:"), forControlEvents: UIControlEvents.ValueChanged )
        self.tableView.addSubview(refreshControl)
    }
    
    func handleRefresh(refresh: UIRefreshControl) {
        faghelgApi.getProgram(showProgram)
        refresh.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        if allEvents.isEmpty {
            activityIndicator.startAnimating()
            if program == nil {
                faghelgApi.getProgram(showProgram)
            }
        }
    }
    
    func showProgram(program: Program?) {
        self.program = program
        if (program == nil) {
            return
        }
        
        self.allEvents = program!.events
        self.allEvents.sort { (event1, event2) -> Bool in
            return event1.start.compare(event2.start) == NSComparisonResult.OrderedAscending
        }
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        self.eventDates = []
        for event in self.allEvents {
            let dateComponents = calendar?.components(NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear, fromDate: event.start)
            let date = calendar?.dateFromComponents(dateComponents!)
            
            if (!contains(self.eventDates, date!)) {
                self.eventDates.append(date!)
            }
        }
        
        let today = self.currentDayOfWeek()
        dispatch_sync(dispatch_get_main_queue(), {
            self.setupDayFilter(today)
            self.filterEvents()
            self.tableView.reloadData()
            /*if !self.filteredEvents.isEmpty {
            self.scrollToCurrentEvent()
            }*/
            
            
            self.activityIndicator.stopAnimating()

        })
    }
    
    func setupDayFilter(selectedDay: Day) {
        self.dayFilter.removeAllSegments()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        var selectedIndex = 0
        for (var i = 0; i < eventDates.count; i++) {
            let day = calendar?.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: eventDates[i])
            self.dayFilter.insertSegmentWithTitle(Day(rawValue: day!)!.description, atIndex: i, animated: false)
            
            if (day == selectedDay.rawValue) {
                selectedIndex = i
            }
        }
        
        self.dayFilter.selectedSegmentIndex = selectedIndex
    }
    
    func currentDayOfWeek() -> Day {
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let day = calendar?.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: today)
        
        return Day(rawValue: day!)!
    }
    
    func scrollToCurrentEvent() {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let currentHour = calendar?.component(NSCalendarUnit.CalendarUnitHour, fromDate: NSDate())
        
        var currentEventIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        for (index, event: Event) in enumerate(self.filteredEvents) {
            let eventHour = calendar?.component(NSCalendarUnit.CalendarUnitHour, fromDate: event.start)
            
            if (currentHour == eventHour) {
                currentEventIndexPath = NSIndexPath(forRow: index, inSection: 0)
                break
            }
        }
        
        self.selectedIndexPath = currentEventIndexPath
        self.tableView.scrollToRowAtIndexPath(currentEventIndexPath, atScrollPosition:UITableViewScrollPosition.Top, animated: true)
    }
    
    @IBAction func filter(sender: UISegmentedControl) {
        self.filterEvents()
        self.selectedIndexPath = nil;
        self.tableView.reloadData()
    }
    
    func filterEvents() {
        if (eventDates.isEmpty) {
            return;
        }
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = eventDates[dayFilter.selectedSegmentIndex]
        
        filteredEvents = allEvents.filter() { (event: Event) -> Bool in
            return calendar?.compareDate(date, toDate: event.start, toUnitGranularity: NSCalendarUnit.CalendarUnitDay) == NSComparisonResult.OrderedSame
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : EventTableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! EventTableViewCell
        
        var event : Event! = filteredEvents[indexPath.row] as Event
        cell.setEvent(event);
        
        if let image = self.imageCache.getImage(event.eventImageUrl!) {
            cell.showImage(image)
        }
        else {
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: event.eventImageUrl!)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    let image = UIImage(data: data)
                        
                    if image != nil {
                        // Store the image in to our cache
                        self.imageCache.addImage(event.eventImageUrl!, image: image!)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.showImage(image)
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        
        if (self.selectedIndexPath != nil && self.selectedIndexPath!.row == indexPath.row) {
            cell.showExtraInfoView(true)
        } else {
            cell.showExtraInfoView(false)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var previousIndexPath : NSIndexPath?
        
        if (self.selectedIndexPath == nil) {
            self.selectedIndexPath = indexPath
        } else if (self.selectedIndexPath?.row == indexPath.row) {
            self.selectedIndexPath = nil
        } else {
            previousIndexPath = self.selectedIndexPath
            self.selectedIndexPath = indexPath
        }
        
        var indexPaths = [NSIndexPath]()
        indexPaths.append(indexPath);
        if (previousIndexPath != nil) {
            indexPaths.append(previousIndexPath!)
        }
        
        self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
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
