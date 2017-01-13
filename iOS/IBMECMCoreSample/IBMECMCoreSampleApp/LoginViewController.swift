/*
* © Copyright IBM Corp. 2015
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
    
    @IBAction func submitTapped(_ sender: Any) {

        print("username: \(usernameTxt.text)")
        print("password: you kidding?")
        print("username: \(navigatorUrlTxt.text)")
        usernameTxt.text = "p8admin"
        passwordTxt.text = "filenet"
        navigatorUrlTxt.text = "http://9.110.94.129:9080/navigator/?desktop=icn"
        
        if let user: String = usernameTxt.text, let password = passwordTxt.text, let url = navigatorUrlTxt.text {
            if( user.characters.count < 1 || password.characters.count < 1 || url.characters.count < 1) {
                Util.showError(title: "Error", message: "Username, password and navigator url are all required for login.", vc: self)
                
                return
            }
            
            /* let's login */
            ibmecmapp = IBMECMFactory.sharedInstance.getApplication(url)
            DispatchQueue.main.async(execute: {
                
            self.ibmecmapp?.login(user, password: password, onComplete: { (error: NSError?) in
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
                    
                    if let ibmecmapp = self.ibmecmapp, (IBMECMFactory.sharedInstance.getCurrentRepository(ibmecmapp) == nil) {
                        Util.showError(title: title, message: message, vc: self)
                        
                        return
                    }
                }
            })
            })
            /*
            ibmecmapp?.login(user, password: password,deviceId: "DummyID", onComplete: {
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
                            Util.showError(title: title, message: message, vc: weakSelf)
                        
                            return
                        }
                    }
                    
                    if let _ = ibmecmapp {                        
                        weakSelf.performSegue(withIdentifier: "transitionToMainMenu", sender: weakSelf)
                    }
                }
                })
            
            */
        } else {
            Util.showError(title: "Error", message: "Username, password and navigator url are all required for login.", vc: self)
        }
    }
        
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        print("unwindSegue: LoginViewController")
        
        let svc = segue.source
        self.ibmecmapp?.logoff(nil)
        svc.dismiss(animated: true, completion: nil)
    }
}
