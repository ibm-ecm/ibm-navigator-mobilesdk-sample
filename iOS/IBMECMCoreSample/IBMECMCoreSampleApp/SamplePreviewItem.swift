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
            return self.document.name.count == 0 ? "undefined" : self.document.name
        }
    }
}
