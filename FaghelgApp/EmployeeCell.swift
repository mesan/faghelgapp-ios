import UIKit

class EmployeeCell: UITableViewCell {

    @IBOutlet weak var fullName: UILabel!
    var shortName: String!
    @IBOutlet weak var employeeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Make cells not selectable
        self.userInteractionEnabled = false
        
        // Wrap full name
        fullName.lineBreakMode = NSLineBreakMode.ByWordWrapping
        fullName.numberOfLines = 0
        
        // Rounding employee image
        employeeImage.layer.cornerRadius = employeeImage.frame.size.width / 2
        employeeImage.clipsToBounds = true
        employeeImage.layer.borderWidth = 1.0
        employeeImage.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setEmployee(employee: Person) {
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var faghelgApi = FaghelgApi(managedObjectContext: appDelegate.managedObjectContext!)
        var image = faghelgApi.getImage(employee.profileImageUrl!)
        
        self.employeeImage.image = image
        self.fullName.text = employee.fullName
        self.shortName = employee.shortName
    }

}
