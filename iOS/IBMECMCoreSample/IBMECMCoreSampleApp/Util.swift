/*
* © Copyright IBM Corp. 2015
*/

import Foundation
import UIKit

class Util {
    
    class func showError(title: String, message: String, vc: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
}