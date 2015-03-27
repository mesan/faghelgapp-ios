import UIKit
import CoreData

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var extraInfoView: UIView!
    
    // Constraint used for automatic resizing
    @IBOutlet weak var extraInfoViewHeight: NSLayoutConstraint!
    
    var extraInfoViewHeightConstraintConstant: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.extraInfoViewHeightConstraintConstant = self.extraInfoViewHeight.constant
        
        // Rounding event image
        eventImage.layer.cornerRadius = eventImage.frame.size.width / 2
        eventImage.clipsToBounds = true
        eventImage.layer.borderWidth = 1.0
        eventImage.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func setEvent(event: Event) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateStringFormatter.stringFromDate(event.start)
        if (event.hostNames != nil) {
            nameLabel.text = event.hostNames
        }
        else {
            nameLabel.text = nil
        }
        var durationSeconds:Double = event.end.timeIntervalSinceDate(event.start)
        var durationMinutes:Double = durationSeconds / 60
        var durationString: String? = String(format: "%.0f min", durationMinutes)
        if (durationString != nil) {
            durationLabel.text = durationString
        }
        else {
            durationLabel.text = nil
        }
        
        abstractLabel.text = event.desc
        titleLabel.text = event.title
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var faghelgApi = FaghelgApi(managedObjectContext: appDelegate.managedObjectContext!)
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            faghelgApi.getImage(event.eventImageUrl, self.showImage)
        })
        
    }
    
    func showExtraInfoView(show: Bool) {
        if (show) {
            self.extraInfoViewHeight.constant = self.extraInfoViewHeightConstraintConstant
        } else {
            self.extraInfoViewHeight.constant = 0
        }
        
        self.extraInfoView.hidden = !show
        self.layoutIfNeeded()
    }
    
    func showImage(image: UIImage?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.eventImage.image = image
        })
    }
}
