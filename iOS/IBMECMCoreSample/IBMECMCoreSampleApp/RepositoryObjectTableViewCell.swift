/*
* © Copyright IBM Corp. 2015
*/

import Foundation
import UIKit

import IBMECMCore

class RepositoryObjectTableViewCell: UITableViewCell {
    
    private var _contentItem: IBMECMContentItem!
    
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
    
    private func updateCellState(cItem: IBMECMContentItem) {
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
    
    private func loadThumbnail(cItem: IBMECMContentItem) -> UIImage? {
        if let imagedata = cItem.getThumbnail() {
            return UIImage(data: imagedata)
        }
        
        return nil
    }
}