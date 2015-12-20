/*
* © Copyright IBM Corp. 2015
*/

import Foundation
import UIKit
import QuickLook

import IBMECMCore

class SamplePreviewItem: NSObject, QLPreviewItem {
    
    var document: IBMECMContentItem
    
    init(document: IBMECMContentItem) {
        self.document = document

        super.init()
    }
    
    var previewItemURL: NSURL {
        get {
            return self.document.previewItemURL
        }
    }
    
    var previewItemTitle: String? {
        get {
            return self.document.name.characters.count == 0 ? "undefined" : self.document.name
        }
    }
}
