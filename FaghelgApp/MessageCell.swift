import UIKit
import CoreData

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var senderImage: UIImageView!
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    func setMessage(message: Message) {
        self.sender.text = message.sender
        self.title.text = message.title
        self.content.text = message.content
        self.timestamp.text = message.timestamp
        
        self.content.sizeToFit()
        self.layoutIfNeeded()
    }
    
    func showImage(image: UIImage?) {
        self.senderImage.image = image
        self.roundImage()
    }
    
    func roundImage() {
        senderImage.layer.cornerRadius = senderImage.frame.size.width / 2
        senderImage.clipsToBounds = true
        senderImage.layer.borderWidth = 1.0
        senderImage.layer.borderColor = UIColor.whiteColor().CGColor
    }
}

