import UIKit

class InfoViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var faghelgApi: FaghelgApi!
    var imageCache = ImageCache.sharedInstance
    
    var info: Info?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationDescription: UILabel!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var hotelDescription: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        faghelgApi = FaghelgApi(managedObjectContext: appDelegate.managedObjectContext!)
    }
    
    override func viewDidAppear(animated: Bool) {
        if info == nil {
            activityIndicator.startAnimating()
            faghelgApi.getInfo(showInfo)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInfo(info: Info) {
        self.info = info
        // reload view using main thread
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.locationName.text = info.locationName
            self.locationDescription.text = info.locationDescription
            self.hotelName.text = info.hotelName
            self.hotelDescription.text = info.hotelDescription
        }
        
        if let image = self.imageCache.getImage(info.imageUrl) {
            dispatch_async(dispatch_get_main_queue(), {
                self.showImage(image)
            })
        }
            
        else {
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: info.imageUrl)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    var image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    self.imageCache.addImage(info.imageUrl, image: image!)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showImage(image)
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
    }
    
    func showImage(image: UIImage?) {
        self.infoImage.image = image
        self.activityIndicator.stopAnimating()
    }
}
