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

class Util {
    
    class func showError(_ title: String, message: String, vc: UIViewController) {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
