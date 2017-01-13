/*
* © Copyright IBM Corp. 2015
*/

import Foundation
import UIKit

class Util {
    
    class func showError(title: String, message: String, vc: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
    }
}
