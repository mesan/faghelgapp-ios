import UIKit
import CoreData

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    func setMessage(message: Message) {
        self.sender.text = message.sender
        self.message.text = message.content
        self.timestamp.text = message.timestamp
    }
}

