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

class MenuOptionsTableViewController : UITableViewController {
    
    var ibmecmapp: IBMECMApplication!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ibmecmapp = IBMECMFactory.sharedInstance.getCurrentApplication()
        
        self.title = "'\(ibmecmapp.currentDesktop!.name)' Desktop"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MenuOptionTableViewCell") //as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MenuOptionTableViewCell")
        }
        
        switch(indexPath.row) {
        case 0:
            cell!.textLabel!.text = "Browse repository"
        case 1:
            cell!.textLabel!.text = "Search repository"
        default:
            cell!.textLabel!.text = ""
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0:
            /* browse repository */
            self.performSegue(withIdentifier: "transitionToBrowse", sender: self)
        case 1:
            /* search repository */
            self.performSegue(withIdentifier: "transitionToSearch", sender: self)
        default:
            return
        }
    }
}
