/*
* © Copyright IBM Corp. 2015
*/

import Foundation
import UIKit
import QuickLook

import IBMECMCore

open class SamplePreviewItem: NSObject, QLPreviewItem {
    
    var document: IBMECMContentItem
    
    init(document: IBMECMContentItem) {
        self.document = document

        super.init()
    }
    
    public var previewItemURL: URL? {
        get {
            return self.document.previewItemURL as URL
        }
    }
    
    public var previewItemTitle: String? {
        get {
            return self.document.name.characters.count == 0 ? "undefined" : self.document.name
        }
    }
}
