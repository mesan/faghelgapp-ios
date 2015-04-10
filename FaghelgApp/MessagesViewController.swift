import CoreData
import AVFoundation

class MessagesViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var viewCreateMessage: UIView!
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonCreateMessage: UIButton!
    @IBOutlet weak var buttonMinimize: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var constraintValue: CGFloat?
    var oldVerticalSpace: CGFloat?
    
    var placeholderTextTitle: String?
    var placeholderTextContent: String?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var faghelgApi: FaghelgApi!
    var imageCache = ImageCache.sharedInstance
    var messageDAO: MessageDAO!
    
    var messages: [Message] = []
    
    var token: String?
    
    // TODO: Sortering av meldinger kan bli feil for meldinger sendt i samme minutt
    override func viewDidLoad() {
        super.viewDidLoad()
        
        faghelgApi = FaghelgApi(managedObjectContext: appDelegate.managedObjectContext!)
        messageDAO = MessageDAO(managedObjectContext: appDelegate.managedObjectContext!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
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
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        initMessages()
        constraintValue = bottomConstraint.constant
    }
    
    func initMessages() {
        if let messagesFromDatabase = messageDAO.getMessages() {
            self.messages = messagesFromDatabase
            self.tableView.reloadData()
        }
        
        // For testing:
        /*if self.messages.isEmpty {
            var messages = [Message]()
            messages.append(Message(title: "Test 1", content: "test 1", sender: "andersu", timestamp: "31.03.2015 15:21", insertIntoManagedObjectContext: appDelegate.managedObjectContext))
            messages.append(Message(title: "Test 2", content: "test 2", sender: "andersa", timestamp: "31.03.2015 15:21", insertIntoManagedObjectContext: appDelegate.managedObjectContext))
            messages.append(Message(title: "Test 3", content: "test 3", sender: "oddr", timestamp: "31.03.2015 15:21", insertIntoManagedObjectContext: appDelegate.managedObjectContext))
            messages.append(Message(title: "Test 4", content: "test 4", sender: "kajas", timestamp: "31.03.2015 15:21", insertIntoManagedObjectContext: appDelegate.managedObjectContext))
            messages.append(Message(title: "Test 5", content: "test 5 balblablalblablablalblbalba", sender: "haraldk", timestamp: "31.03.2015 15:21", insertIntoManagedObjectContext: appDelegate.managedObjectContext))
            self.messages = messages
            self.tableView.reloadData()
        }*/
    }
    
    override func viewDidAppear(animated: Bool) {
        tabBarItem.badgeValue = nil
        checkForToken()
        if messages.isEmpty {
            initMessages()
        }
    }
    
    func checkForToken() {
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String {
            showCreateMessageButton()
        }
        else {
            showLoginButton()
        }
    }
    
    func showLoginButton() {
        buttonLogin.hidden = false
        buttonCreateMessage.hidden = true
    }
    
    func showCreateMessageButton() {
        buttonLogin.hidden = true
        buttonCreateMessage.hidden = false
        hideCreateMessageView()
    }
    
    func hideCreateMessageView() {
        buttonCreateMessage.hidden = false
        viewCreateMessage.hidden = true
    }
    
    func showCreateMessageView() {
        buttonCreateMessage.hidden = true
        viewCreateMessage.hidden = false
    }
    
    @IBAction func buttonLoginClicked(sender: AnyObject) {
        promptLogin()
    }
    
    @IBAction func buttonCreateMessageClicked(sender: AnyObject) {
        showCreateMessageView()
    }
    
    @IBAction func buttonMinimizeClicked(sender: AnyObject) {
        hideCreateMessageView()
        hideKeyboard()
    }
    
    func promptLogin() {
        var authority = "https://login.windows.net/common"
        var clientID = "685ff077-c1ca-4d18-b364-7746b4560cea"
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
                self.showCreateMessageButton()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForPush(accessToken: String) {
        if let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken") as? String {
            faghelgApi.registerForPush(PushDevice(token: deviceToken, owner: TokenUtil.getUsernameFromToken(accessToken)!))
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
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
            faghelgApi.sendPush(textFieldTitle.text, content: textView.text)
            
            textView.resignFirstResponder()
            fillInPlaceholderText(textFieldTitle, text: placeholderTextTitle!)
            fillInPlaceholderText(textViewMessage, text: placeholderTextContent!)
            hideCreateMessageView()
            playWhooshSound()
        }
        
        return true
    }
    
    func playWhooshSound() {
        var mysoundname = "flyby"
        
        // Load
        let soundURL = NSBundle.mainBundle().URLForResource(mysoundname, withExtension: "wav")
        var mySound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL, &mySound)
        
        // Play
        AudioServicesPlaySystemSound(mySound);
    }
    
    func hideKeyboard() {
        if textViewMessage.isFirstResponder() {
            textViewMessage.resignFirstResponder()
        }
        
        if textFieldTitle.isFirstResponder() {
            textFieldTitle.resignFirstResponder()
        }
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
            var textView = textInput as! UITextView
            textView.text = text
            textView.textColor = UIColor.lightGrayColor()
        }
        
        if textInput is UITextField {
            var textField = textInput as! UITextField
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
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get cell from tableView
        let messageCell: MessageCell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        
        let message = messages[indexPath.row]
        
        messageCell.setMessage(message)
        
        var url = FaghelgApi.getUrlToImageFromShortname(message.sender)
        if let image = self.imageCache.getImage(url) {
            messageCell.showImage(image)
        }
        else {
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: url)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    var image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    self.imageCache.addImage(url, image: image!)
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? EmployeeCell {
                            cellToUpdate.showImage(image)
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        
        // return the cell
        return messageCell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
