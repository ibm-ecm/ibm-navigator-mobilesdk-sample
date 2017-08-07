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
    
    func setTitle(_ contentItem: IBMECMContentItem?) {
        if let cItem = contentItem {
            self.title = cItem.name
        } else {
            self.title = "loading..."
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.hasMore) {
            return self.contentItems.count + 1
        } else {
            return self.contentItems.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(self.hasMore && indexPath.row == self.contentItems.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BrowseMore")// as? UITableViewCell
            
            return cell!
        }
        
        if(indexPath.row > self.contentItems.count) {
            let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "hidden")
            
            cell.isHidden = true
            
            return cell
        }
        
        let cItem = self.contentItems[indexPath.row] as! IBMECMContentItem
        
        var cell: RepositoryObjectTableViewCell? = nil
        if(cItem.isFolder) {
            cell = tableView.dequeueReusableCell(withIdentifier: "BrowseFolderTableViewCell") as? RepositoryObjectTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "BrowseDocumentTableViewCell") as? RepositoryObjectTableViewCell
        }
        
        cell!.contentItem = cItem
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(cell.reuseIdentifier == "BrowseMore") {
            // load next page
            if(self.resultSet != nil) {
                self.getNextPage()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = self.tableView.cellForRow(at: indexPath) as? RepositoryObjectTableViewCell
        
        if let cell = selectedCell {
            if(!cell.contentItem.isFolder) {
                let qlp = DocumentViewerController()
                qlp.contentItem = cell.contentItem
                
                self.show(qlp, sender: self)
            } else {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let destinationVC: BrowseRepositoryTableViewController = storyBoard.instantiateViewController(withIdentifier: "BrowseRepositoryScene") as! BrowseRepositoryTableViewController
                
                destinationVC.folderBrowsed = cell.contentItem
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        code
//    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if(self.hasMore && indexPath.row == self.contentItems.count) {
            return nil
        }
        
        let selectedCell = self.tableView.cellForRow(at: indexPath) as? RepositoryObjectTableViewCell
        let contentItem = selectedCell?.contentItem
        
        var favLabel = "Favorite"
        if(selectedCell!.isFavorite) {
            favLabel = "Unfavorite"
        }
        
        let favoriteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: favLabel , handler: {
            (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            
        })
        
        favoriteAction.backgroundColor = UIColor.gray
        
        var actions: [UITableViewRowAction] = [favoriteAction]
        
        if (!contentItem!.isFolder) {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: {
                [weak contentItem, weak self] (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
                
                if let weakSelf = self, let weakCitem = contentItem {
                    let confirmation = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    confirmation.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                        weakSelf.deleteObject(weakCitem, indexPath: indexPath)
                    }))
                    
                    confirmation.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
                    }))
                    
                    weakSelf.present(confirmation, animated: true, completion: nil)
                }
                })
            deleteAction.backgroundColor = UIColor.red
            
            actions.append(deleteAction)
        }
        
        return actions
    }
    
    fileprivate func deleteObject(_ cItem: IBMECMContentItem, indexPath: IndexPath) {
        self.repository.deleteItems([cItem], onComplete: {
            (error: NSError?) -> Void in
            
            if let _ = error {
                Util.showError("Error", message: "Could not delete repository object, please login and retry", vc: self)
            } else {
                self.contentItems.removeObject(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        })
        
    }
    
    fileprivate func loadFolderBrowsed() {
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
    
    fileprivate func loadContainees() {
        if let folderToBrowse = self.folderBrowsed {
            folderToBrowse.retrieveFolderContent(false , orderBy: nil, descending: false, pageSize: pageSize as NSNumber, teamspaceId: nil, onComplete: {
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
                                weakSelf.contentItems.add(item)
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
    
    fileprivate func getNextPage() {
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
                            weakSelf.contentItems.add(item)
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
