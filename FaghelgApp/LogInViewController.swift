import UIKit

class LogInViewController: UIViewController {

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
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
