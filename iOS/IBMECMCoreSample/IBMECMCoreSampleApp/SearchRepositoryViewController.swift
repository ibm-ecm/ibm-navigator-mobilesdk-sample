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

class SearchRepositoryViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtDocumentTitle: UITextField!
    @IBOutlet weak var txtDateCreated: UITextField!
    
    var ibmecmapp: IBMECMApplication!
    var repository: IBMECMRepository!
    
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
        }
        
        self.title = "Search Repository"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.hasMore) {
            return self.contentItems.count + 1
        } else {
            return self.contentItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(self.hasMore && indexPath.row == self.contentItems.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMore") //as? UITableViewCell
            
            return cell!
        }
        
        if(indexPath.row > self.contentItems.count) {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "hidden")
            
            cell.isHidden = true
            
            return cell
        }
        
        let cell: RepositoryObjectTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SearchDocumentTableViewCell") as? RepositoryObjectTableViewCell
        
        cell!.contentItem = self.contentItems[indexPath.row] as! IBMECMContentItem
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(cell.reuseIdentifier == "SearchMore") {
            if(self.resultSet != nil) {
                self.getNextPage()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    @IBAction func submitTapped(_ sender: UIButton) {
        self.contentItems.removeAllObjects()
        
        if let _ = self.repository {
            var searchPredicates: [IBMECMSearchPredicate] = []
            
            if self.txtDocumentTitle.text!.count > 0 {
                let docTitlePredicate = IBMECMSearchPredicate.like(propertyId: "DocumentTitle", dataType: IBMECMPropertyDataType.String, cardinality:IBMECMPropertyCardinality.Single, values: [self.txtDocumentTitle.text!])
                
                searchPredicates.append(docTitlePredicate)
            }
            
            if self.txtDateCreated.text!.count > 0 {
                let dateAddedPredicate = IBMECMSearchPredicate.greaterOrEqual(propertyId: "DateCreated", dataType: IBMECMPropertyDataType.Date, cardinality:IBMECMPropertyCardinality.Single, values: [self.txtDateCreated.text! as AnyObject])
                
                searchPredicates.append(dateAddedPredicate)
            }
            
            self.repository.searchAdHoc(nil, teamspaceId: nil, searchClasses: [ "Document" ], objectType: IBMECMObjectType.Document, searchPredicates: searchPredicates, textSearchPredicate: nil, orderBy: nil, descending: nil, pageSize: pageSize as NSNumber, onComplete: {
                [weak self] (resultSet: IBMECMResultSet?, error: NSError?) -> Void in
                
                if let weakSelf = self {
                    if let _ = error {
                        Util.showError("Error", message: "Could not search repository, please login and retry", vc: weakSelf)
                        
                        weakSelf.tableView.reloadData()
                        
                        return
                    }
                    
                    if let resultSet = resultSet {
                        if let items = resultSet.items {
                            for item in items {
                                weakSelf.contentItems.add(item)
                            }
                            
                            weakSelf.resultSet = resultSet
                            weakSelf.hasMore = resultSet.hasMore()
                        }
                    }
                    
                    weakSelf.tableView.reloadData()
                }
                })
        } else {
            Util.showError("Error", message: "No repository available, please login and retry", vc: self)
        }
    }
    
    fileprivate func getNextPage() {
        self.resultSet!.retrieveNextPage({
            [weak self] (results: IBMECMResultSet?, error: NSError?) -> Void in
            
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
