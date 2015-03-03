//
//  LogInViewController.swift
//  FaghelgApp
//
//  Created by Anders Ullnæss on 03/03/15.
//  Copyright (c) 2015 Mesan. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var tenant:NSString = "rzna.onmicrosoft.com"
        var authority:NSString = "https://login.windows.net/\(tenant)"
        var clientID:NSString = "2908e4e2-c6a4-4829-b065-b15f7ab3ecef"
        var redirectURI:NSURL = NSURL(string: "https://orgdna.azurewebsites.net")!
        //var resources:Dictionary<String, Resource> = Dictionary<String, Resource>()
        
        //Use ADAL to authenticate the user against Azure Active Directory
        var er:ADAuthenticationError? = nil
        var authContext:ADAuthenticationContext = ADAuthenticationContext(authority: authority, error: &er)
        authContext.acquireTokenWithResource("Microsoft.SharePoint", clientId: clientID, redirectUri: redirectURI, completionBlock: { (result: ADAuthenticationResult!) in
            //validate token exists in response
            if (result.accessToken == nil) {
                println("token nil")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
