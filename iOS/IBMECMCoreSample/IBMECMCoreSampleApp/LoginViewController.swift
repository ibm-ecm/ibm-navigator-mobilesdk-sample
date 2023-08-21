/*
 * Licensed Materials - Property of IBM
 * (C) Copyright IBM Corporation 2015, 2023. All Rights Reserved.
 * This sample program is provided AS IS and may be used, executed, copied
 * and modified without royalty payment by customer (a) for its own instruction
 * and study, (b) in order to develop applications designed to run with an IBM
 * product, either for customer's own internal use or for redistribution by
 * customer, as part of such an application, in customer's own products.
 */
import Foundation
import UIKit

import IBMECMCore

class LoginViewController : UIViewController {
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var navigatorUrlTxt: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    var ibmecmapp: IBMECMApplication?
    
    @IBAction func submitTapped(_ sender: UIButton) {
        print("username: \(String(describing: usernameTxt.text))")
        print("password: you kidding?")
        print("username: \(String(describing: navigatorUrlTxt.text))")
        
        if let user: String = usernameTxt.text, let password = passwordTxt.text, let url = navigatorUrlTxt.text {
            if( user.count < 1 || password.count < 1 || url.count < 1) {
                Util.showError("Error", message: "Username, password and navigator url are all required for login.", vc: self)
                
                return
            }
            
            /* let's login */
            ibmecmapp = IBMECMFactory.sharedInstance.getApplication(url)
            
            ibmecmapp!.login(user, password: password, onComplete: {
                [weak self, weak ibmecmapp] (error: NSError?) -> Void in
                
                if let weakSelf = self {
                    if let loginError = error {
                        // login failed
                        var title = "Login error"
                        if let detailTitle = loginError.localizedFailureReason {
                            title = detailTitle
                        }
                        
                        var message = "Enter the right username/password/url and try again"
                        if let detailMessage = loginError.localizedRecoverySuggestion {
                            message = detailMessage
                        }
                        
                        if let ibmecmapp = ibmecmapp, (IBMECMFactory.sharedInstance.getCurrentRepository(ibmecmapp) == nil) {
                            Util.showError(title, message: message, vc: weakSelf)
                        
                            return
                        }
                    }
                    
                    if let _ = ibmecmapp {                        
                        weakSelf.performSegue(withIdentifier: "transitionToMainMenu", sender: weakSelf)
                    }
                }
                })
        } else {
            Util.showError("Error", message: "Username, password and navigator url are all required for login.", vc: self)
        }
    }
        
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        print("unwindSegue: LoginViewController")
        
        let svc = segue.source
        self.ibmecmapp?.logoff(nil)
        svc.dismiss(animated: true, completion: nil)
    }
}
