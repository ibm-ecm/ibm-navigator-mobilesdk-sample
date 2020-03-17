/*
* © Copyright IBM Corp. 2015
*/

import Foundation
import UIKit

class Util {
    
    class func showError(_ title: String, message: String, vc: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
    }
}
