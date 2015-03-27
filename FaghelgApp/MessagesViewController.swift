import UIKit

class MessagesViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var messageTableView: UITableView!
    
    var constraintValue: CGFloat?
    var placeholderTextTitle: String?
    var placeholderTextContent: String?
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var faghelgApi : FaghelgApi!
    
    var messages: [Message] = []
    
    var token: String?
    
    
    // TODO: området for å skrive en ny melding bør bare vises når man skal skrive. Tar for mye plass ellers.
    // TODO: holde på meldingene i meldingslista hvis appen blir drept
    // TODO: gå rett til meldinger-tabben når man åpner appen fra en notification
    override func viewDidLoad() {
        super.viewDidLoad()
        
        faghelgApi = FaghelgApi(managedObjectContext: appDelegate.managedObjectContext!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        constraintValue = self.bottomConstraint.constant
        placeholderTextTitle = textFieldTitle.text
        placeholderTextContent = textViewMessage.text
        
        textViewMessage.layer.borderColor = UIColor.lightGrayColor().CGColor
        textViewMessage.layer.borderWidth = 1.0
        textViewMessage.layer.cornerRadius = 5
        textViewMessage.delegate = self
        
        textFieldTitle.layer.borderColor = UIColor.lightGrayColor().CGColor
        textFieldTitle.layer.borderWidth = 1.0
        textFieldTitle.layer.cornerRadius = 5
        textFieldTitle.autocapitalizationType = UITextAutocapitalizationType.Sentences
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapReceived:")
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.messageTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        tabBarItem.badgeValue = nil
        
        // Prompt the user to log in if he has no accesstoken
        token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String
        if token == nil {
            promptLogin()
        }
    }
    
    func promptLogin() {
        var authority:NSString = "https://login.windows.net/common"
        var clientID:NSString = "685ff077-c1ca-4d18-b364-7746b4560cea"
        var redirectURI:NSURL = NSURL(string: "https://faghelg.herokuapp.com")!
        
        //Use ADAL to authenticate the user against Azure Active Directory
        var er:ADAuthenticationError? = nil
        var authContext:ADAuthenticationContext = ADAuthenticationContext(authority: authority, error: &er)
        authContext.acquireTokenWithResource("https://faghelg.herokuapp.com", clientId: clientID, redirectUri: redirectURI, completionBlock: { (result: ADAuthenticationResult!) in
            
            if result.error != nil {
                // Go back to the first ViewController
                self.tabBarController?.selectedIndex = 0
            }
            if result.accessToken != nil {
                NSUserDefaults.standardUserDefaults().setObject(result.accessToken, forKey: "token")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.registerForPush(result.accessToken)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForPush(accessToken: String) {
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound
        
        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
        
        UIApplication.sharedApplication().registerUserNotificationSettings( settings )
        var deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken") as? String
        faghelgApi.registerForPush(PushDevice(token: deviceToken!, owner: TokenUtil.getUsernameFromToken(accessToken)!))
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        if let height = tabBarController?.tabBar.frame.size.height {
            self.bottomConstraint.constant = keyboardFrame.size.height - height + constraintValue!
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        
        self.bottomConstraint.constant = constraintValue!
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == placeholderTextTitle {
            textField.text = nil
        }
        if textViewMessage.text.isEmpty {
            fillInPlaceholderText(textViewMessage, text: placeholderTextContent!)
        }
        
        textField.textColor = UIColor.blackColor()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textViewMessage.text == placeholderTextContent {
            textViewMessage.text = nil
        }
        
        if textFieldTitle.text.isEmpty {
            fillInPlaceholderText(textFieldTitle, text: placeholderTextTitle!)
        }
        
        textView.textColor = UIColor.blackColor()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            var message = Message(title: textFieldTitle.text, content: textView.text)
            faghelgApi.sendPushIos(message)
            
            textView.resignFirstResponder()
            fillInPlaceholderText(textFieldTitle, text: placeholderTextTitle!)
            fillInPlaceholderText(textViewMessage, text: placeholderTextContent!)
        }
        
        return true
    }
    
    func tapReceived(tapGestureRecognizer: UITapGestureRecognizer) {
        if textViewMessage.isFirstResponder() && tapGestureRecognizer.view != textViewMessage {
            textViewMessage.resignFirstResponder()
            if textViewMessage.text.isEmpty {
                fillInPlaceholderText(textViewMessage, text: placeholderTextContent!)
            }
        }
        
        if textFieldTitle.isFirstResponder() && tapGestureRecognizer.view != textFieldTitle {
            textFieldTitle.resignFirstResponder()
            if textFieldTitle.text.isEmpty {
                fillInPlaceholderText(textFieldTitle, text: placeholderTextTitle!)
            }
        }
    }
    
    private func fillInPlaceholderText(textInput: UITextInput, text: String) {
        if textInput is UITextView {
            var textView = textInput as UITextView
            textView.text = text
            textView.textColor = UIColor.lightGrayColor()
        }
        
        if textInput is UITextField {
            var textField = textInput as UITextField
            textField.text = text
            textField.textColor = UIColor.lightGrayColor()
        }
    }
    
    func increaseBadgeValue() {
        if !viewIsShowing() {
            if let badgeValue = tabBarItem.badgeValue?.toInt() {
                var newValue = badgeValue + 1
                tabBarItem.badgeValue = String(newValue)
            }
            else {
                tabBarItem.badgeValue = String(1)
            }
        }
    }
    
    func viewIsShowing() -> Bool {
        return self.isViewLoaded() && self.view.window != nil
    }
    
    
    func addMessage(message: Message) {
        messages.insert(message, atIndex: 0)
        
        // Reload data only if the message view has been loaded
        if self.isViewLoaded() {
            // reload view using main thread
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.messageTableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get cell from tableView
        let messageCell: MessageCell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as MessageCell
        
        let message = messages[indexPath.row]
        
        messageCell.setMessage(message)
        
        // return the cell
        return messageCell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
