import UIKit

class InfoViewController: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var faghelgApi : FaghelgApi!
    
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var hotelDescription: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        faghelgApi = FaghelgApi(managedObjectContext: appDelegate.managedObjectContext!)
        
        faghelgApi.getInfo(showInfo)
    }
    
    /*override func viewWillAppear(animated: Bool) {
        scrollView.contentSize = CGSizeMake(320', 200)
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInfo(info: Info?) {
        var image = faghelgApi.getImage(info!.imageUrl)
        // reload view using main thread
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.infoImage.image = image
            self.locationName.text = info!.locationName
            self.desc.text = info!.locationDescription
            self.hotelName.text = info!.hotelName
            self.hotelDescription.text = info!.hotelDescription
        }
    }
}
