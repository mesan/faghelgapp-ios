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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInfo(info: Info?) {
        // reload view using main thread
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.locationName.text = info!.locationName
            self.desc.text = info!.locationDescription
            self.hotelName.text = info!.hotelName
            self.hotelDescription.text = info!.hotelDescription
        }
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        dispatch_async(backgroundQueue, {
            self.faghelgApi.getImage(info!.imageUrl, self.showImage)
        })
    }
    
    func showImage(image: UIImage?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.infoImage.image = image
        })
    }
}
