import UIKit

class LogInViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var parentView: UIView!
    
    var constraintValue: CGFloat?
    var placeholderText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        var authority:NSString = "https://login.windows.net/common"
        var clientID:NSString = "685ff077-c1ca-4d18-b364-7746b4560cea"
        var redirectURI:NSURL = NSURL(string: "https://faghelg.herokuapp.com")!
        //var resources:Dictionary<String, Resource> = Dictionary<String, Resource>()
        
        //Use ADAL to authenticate the user against Azure Active Directory
        var er:ADAuthenticationError? = nil
        var authContext:ADAuthenticationContext = ADAuthenticationContext(authority: authority, error: &er)
        authContext.acquireTokenWithResource("https://faghelg.herokuapp.com", clientId: clientID, redirectUri: redirectURI, completionBlock: { (result: ADAuthenticationResult!) in
            //validate token exists in response
            if (result.accessToken == nil) {
                println("token nil")
            }
            else {
                println(result.accessToken)
                self.registerForPush()
            }
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        constraintValue = self.bottomConstraint.constant
        placeholderText = textViewMessage.text
        
        textViewMessage.layer.borderColor = UIColor.lightGrayColor().CGColor
        textViewMessage.layer.borderWidth = 1.0
        textViewMessage.layer.cornerRadius = 8
        textViewMessage.delegate = self
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapReceived:")
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForPush() {
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound
        
        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
        
        UIApplication.sharedApplication().registerUserNotificationSettings( settings )
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textViewMessage.text == placeholderText {
            textViewMessage.text = nil
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            textView.text = placeholderText
        }
        
        // TODO: legg til meldingen i tabellen med klokkeslett og avsender
        
        return true
    }
    
    func tapReceived(tapGestureRecognizer: UITapGestureRecognizer) {
        if textViewMessage.isFirstResponder() && tapGestureRecognizer.view != textViewMessage {
            textViewMessage.resignFirstResponder()
        }
    }
}
