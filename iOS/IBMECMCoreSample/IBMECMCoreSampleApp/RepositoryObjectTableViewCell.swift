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

class RepositoryObjectTableViewCell: UITableViewCell {
    
    fileprivate var _contentItem: IBMECMContentItem!
    
    var isFavorite: Bool = false
    
    var contentItem: IBMECMContentItem {
        get {
            return _contentItem
        }
        set {
            self._contentItem = newValue
            
            updateCellState(self._contentItem)
        }
    }
    
    fileprivate func updateCellState(_ cItem: IBMECMContentItem) {
        self.textLabel?.text = cItem.name
        
        if let created: String = cItem.properties["DateCreated"] as? String {
            self.detailTextLabel?.text = "Date Created: \(created)"
        } else {
            self.detailTextLabel?.text = ""
        }
        
        if(self.contentItem.isFolder) {
            self.imageView?.image = UIImage(named: "folderIcon")
        } else {
            self.imageView?.image = loadThumbnail(cItem)
            
            if(self.imageView?.image == nil) {
                self.imageView?.image = UIImage(named: "fileIcon")
            }
        }
        
        self.isFavorite = cItem.isFavoriteEnabled
    }
    
    fileprivate func loadThumbnail(_ cItem: IBMECMContentItem) -> UIImage? {
        if let imagedata = cItem.getThumbnail() {
            return UIImage(data: imagedata)
        }
        
        return nil
    }
}
