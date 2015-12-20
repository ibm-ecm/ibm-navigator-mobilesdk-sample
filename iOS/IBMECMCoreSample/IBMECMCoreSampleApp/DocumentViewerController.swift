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
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
        if let _ = self.contentItem {
            return 1
        } else {
            return 0
        }
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let previewItem = SamplePreviewItem(document: self.contentItem!)
        
        return previewItem
    }
    
    private func downloadDocument() {
        let onComplete : (error: NSError?)-> Void =  {
            [weak self] (error) -> Void in
            
            if let weakSelf = self {
                weakSelf.refreshCurrentPreviewItem()
            }
        }
        
        let progress : (bytesRead:Int64, totalBytesRead:Int64, totalBytesExpectedToRead:Int64) -> Void = {
           /* [weak self] */(bytesRead, totalBytesRead, totalBytesExpectedToRead ) -> Void in
            // unused
        }
        
        let previewItem = SamplePreviewItem(document: self.contentItem!)
        
        if let filePath = previewItem.previewItemURL.path {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                previewItem.document.retrieveDocumentItem(filePath, onComplete: onComplete, progress: progress)
            })
        }
    }
}