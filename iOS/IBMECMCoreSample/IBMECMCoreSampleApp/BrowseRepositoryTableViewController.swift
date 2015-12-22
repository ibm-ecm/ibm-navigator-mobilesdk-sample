/*
* © Copyright IBM Corp. 2015
*/

import Foundation
import UIKit
import QuickLook

import IBMECMCore

class BrowseRepositoryTableViewController : UITableViewController {
    
    var ibmecmapp: IBMECMApplication!
    var repository: IBMECMRepository!
    
    var folderBrowsed: IBMECMContentItem?
    var resultSet: IBMECMResultSet?
    
    var contentItems: NSMutableArray = NSMutableArray()
    
    var hasMore: Bool = false
    let pageSize: Int = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentItems = NSMutableArray()
        
        hasMore = false
        
        ibmecmapp = IBMECMFactory.sharedInstance.getCurrentApplication()
        
        if let repos = IBMECMFactory.sharedInstance.getCurrentRepository(ibmecmapp) {
            repository = repos
            
            loadContainees()
        } else {
            Util.showError("Error", message: "No repository available, please login and retry", vc: self)
        }
        
        setTitle(folderBrowsed)
    }
    
    func setTitle(contentItem: IBMECMContentItem?) {
        if let cItem = contentItem {
            self.title = cItem.name
        } else {
            self.title = "loading..."
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.hasMore) {
            return self.contentItems.count + 1
        } else {
            return self.contentItems.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(self.hasMore && indexPath.row == self.contentItems.count) {
            let cell = tableView.dequeueReusableCellWithIdentifier("BrowseMore")// as? UITableViewCell
            
            return cell!
        }
        
        if(indexPath.row > self.contentItems.count) {
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "hidden")
            
            cell.hidden = true
            
            return cell
        }
        
        let cItem = self.contentItems[indexPath.row] as! IBMECMContentItem
        
        var cell: RepositoryObjectTableViewCell? = nil
        if(cItem.isFolder) {
            cell = tableView.dequeueReusableCellWithIdentifier("BrowseFolderTableViewCell") as? RepositoryObjectTableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("BrowseDocumentTableViewCell") as? RepositoryObjectTableViewCell
        }
        
        cell!.contentItem = cItem
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(cell.reuseIdentifier == "BrowseMore") {
            // load next page
            if(self.resultSet != nil) {
                self.getNextPage()
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = self.tableView.cellForRowAtIndexPath(indexPath) as? RepositoryObjectTableViewCell
        
        if let cell = selectedCell {
            if(!cell.contentItem.isFolder) {
                let qlp = DocumentViewerController()
                qlp.contentItem = cell.contentItem
                
                self.showViewController(qlp, sender: self)
            } else {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let destinationVC: BrowseRepositoryTableViewController = storyBoard.instantiateViewControllerWithIdentifier("BrowseRepositoryScene") as! BrowseRepositoryTableViewController
                
                destinationVC.folderBrowsed = cell.contentItem
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        code
//    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if(self.hasMore && indexPath.row == self.contentItems.count) {
            return nil
        }
        
        let selectedCell = self.tableView.cellForRowAtIndexPath(indexPath) as? RepositoryObjectTableViewCell
        let contentItem = selectedCell?.contentItem
        
        var favLabel = "Favorite"
        if(selectedCell!.isFavorite) {
            favLabel = "Unfavorite"
        }
        
        let favoriteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: favLabel , handler: {
            (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
        })
        
        favoriteAction.backgroundColor = UIColor.grayColor()
        
        var actions: [UITableViewRowAction] = [favoriteAction]
        
        if (!contentItem!.isFolder) {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: {
                [weak contentItem, weak self] (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                
                if let weakSelf = self, let weakCitem = contentItem {
                    let confirmation = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    confirmation.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction!) in
                        weakSelf.deleteObject(weakCitem, indexPath: indexPath)
                    }))
                    
                    confirmation.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) in
                    }))
                    
                    weakSelf.presentViewController(confirmation, animated: true, completion: nil)
                }
                })
            deleteAction.backgroundColor = UIColor.redColor()
            
            actions.append(deleteAction)
        }
        
        return actions
    }
    
    private func deleteObject(cItem: IBMECMContentItem, indexPath: NSIndexPath) {
        self.repository.deleteItems([cItem], onComplete: {
            (error: NSError?) -> Void in
            
            if let _ = error {
                Util.showError("Error", message: "Could not delete repository object, please login and retry", vc: self)
            } else {
                self.contentItems.removeObjectAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        })
        
    }
    
    private func loadFolderBrowsed() {
        self.repository.retrieveItem("/", onComplete: {
            [weak self] (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
            
            if let weakSelf = self {
                if let _ = error {
                    Util.showError("Error", message: "Could not fetch repository objects, please login and retry", vc: weakSelf)
                    
                    return
                }
                
                weakSelf.folderBrowsed = contentItem
                
                weakSelf.setTitle(weakSelf.folderBrowsed)
                
                weakSelf.loadContainees()
            }
            })
    }
    
    private func loadContainees() {
        if let folderToBrowse = self.folderBrowsed {
            folderToBrowse.retrieveFolderContent(false , orderBy: nil, descending: false, pageSize: pageSize, teamspaceId: nil, onComplete: {
                [weak self] (resultSet: IBMECMResultSet?, error: NSError?) -> Void in
                
                if let weakSelf = self {
                    if let _ = error {
                        Util.showError("Error", message: "Could not fetch repository objects, please login and retry", vc: weakSelf)
                        
                        weakSelf.tableView.reloadData()
                        
                        return
                    }
                    
                    if let result = resultSet {
                        if let items = result.items {
                            for item in items {
                                weakSelf.contentItems.addObject(item)
                            }
                            
                            weakSelf.resultSet = result
                            weakSelf.hasMore = result.hasMore()
                        }
                    }
                    
                    weakSelf.tableView.reloadData()
                }
                })
        } else {
            loadFolderBrowsed()
        }
    }
    
    private func getNextPage() {
        self.resultSet!.retrieveNextPage({
            [weak self](results: IBMECMResultSet?, error: NSError?) -> Void in
            
            if let weakSelf = self {
                if let _ = error {
                    Util.showError("Error", message: "Could not next page, please login and retry", vc: weakSelf)
                    
                    return
                }
                
                if let result = results {
                    if let items = result.items {
                        for item in items {
                            weakSelf.contentItems.addObject(item)
                        }
                        
                        weakSelf.resultSet = result
                        weakSelf.hasMore = result.hasMore()
                    }
                }
                
                weakSelf.tableView.reloadData()
            }
            })
    }
}