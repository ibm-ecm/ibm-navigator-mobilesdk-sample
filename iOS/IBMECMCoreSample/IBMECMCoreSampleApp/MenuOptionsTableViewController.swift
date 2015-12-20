/*
* © Copyright IBM Corp. 2015
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MenuOptionTableViewCell") //as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MenuOptionTableViewCell")
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.row) {
        case 0:
            /* browse repository */
            self.performSegueWithIdentifier("transitionToBrowse", sender: self)
        case 1:
            /* search repository */
            self.performSegueWithIdentifier("transitionToSearch", sender: self)
        default:
            return
        }
    }
}