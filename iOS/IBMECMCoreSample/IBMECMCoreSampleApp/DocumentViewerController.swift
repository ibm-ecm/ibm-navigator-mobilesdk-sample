/*
* © Copyright IBM Corp. 2015
*/

import Foundation
import UIKit
import QuickLook

import IBMECMCore

class DocumentViewerController: QLPreviewController, QLPreviewControllerDataSource {
    
    var contentItem: IBMECMContentItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self

        if let _ = contentItem {
            self.downloadDocument()
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int{
        if let _ = self.contentItem {
            return 1
        } else {
            return 0
        }
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let previewItem = SamplePreviewItem(document: self.contentItem!)
        
        return previewItem
    }
    
    fileprivate func downloadDocument() {
        let onComplete : (_ error: NSError?)-> Void =  {
            [weak self] (error) -> Void in
            
            if let weakSelf = self {
                weakSelf.refreshCurrentPreviewItem()
            }
        }
        
        let progress : ((_ theProgress: Progress) -> Void) = {
            /* [weak self] */(_ theProgress: Progress) -> Void in
            // unused
        }
        
        let previewItem = SamplePreviewItem(document: self.contentItem!)
        
        if let previewItemURL = previewItem.previewItemURL {
            let filePath = previewItemURL.path
            DispatchQueue.main.async(execute: {
                previewItem.document.retrieveDocumentItem(filePath, onComplete: onComplete, progress: progress)
            })
        }
    }
}
