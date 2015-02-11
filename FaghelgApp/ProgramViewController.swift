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
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var faghelgApi: FaghelgApi!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayFilter: UISegmentedControl!
    
    var allEvents: [Event] = []
    var filteredEvents : [Event] = []
    var eventDates: [NSDate] = []
    let cellIdentifier = "eventCell"
    
    var selectedIndexPath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.tableView.rowHeight = UITableViewAutomaticDimension
        faghelgApi = FaghelgApi(managedObjectContext: appDelegate.managedObjectContext!)

        faghelgApi.getProgram(self)
    }
    
    func showProgram(program: Program?) {
        if (program == nil) {
            return
        }
        
        self.allEvents = program!.events.allObjects as [Event]
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
        dispatch_async(dispatch_get_main_queue(), {
            self.setupDayFilter(today)
            self.filterEvents()
            self.tableView.reloadData()
            
            self.scrollToCurrentEvent()
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
        var cell : EventTableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as EventTableViewCell
        
        var event : Event! = filteredEvents[indexPath.row] as Event
        cell.setEvent(event);
        
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
}
