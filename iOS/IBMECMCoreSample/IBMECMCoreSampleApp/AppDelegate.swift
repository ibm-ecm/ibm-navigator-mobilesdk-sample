/*
 * Licensed Materials - Property of IBM
 * (C) Copyright IBM Corporation 2015, 2023. All Rights Reserved.
 * This sample program is provided AS IS and may be used, executed, copied
 * and modified without royalty payment by customer (a) for its own instruction
 * and study, (b) in order to develop applications designed to run with an IBM
 * product, either for customer's own internal use or for redistribution by
 * customer, as part of such an application, in customer's own products.
 */
import UIKit
import IBMECMCore

public typealias OnCompleteBlock = (_ contentItem: IBMECMContentItem) -> Void
public typealias OnCompleteResultSetBlock = (_ resultSet: IBMECMResultSet) -> Void

let USERNAME = "username"
let PASSWORD = "password"
let SERVER_URL = "http://icn_server:port/navigator/"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppLog.initializeLoger()
        AppLog.logInfo("======================== Application Startup  ========================")
        // scenario 1: add folder to root then add document under new folder
        // addFolderThenDocument_Scenario()
        
        // scenario 2: retrieve an existing folder, get its containees, grab one document, then download it
        // retrieveFolderThenGetFolderContaineesThenGetDocument_Scenario()
        
        // scenario 3: retrieve document, check out, check in, add like
        // retrieveDocumentCheckOutThenInThenLike()
        
        // scenario 4: search for documents with criteria
        // searchDocumentsWithCriteria()
        
        return true
    }
    
    fileprivate func searchDocumentsWithCriteria() {
        let ibmecmapp: IBMECMApplication = IBMECMFactory.sharedInstance.getApplication(SERVER_URL)
        
        // SEE: LOGIN
        ibmecmapp.login(USERNAME, password: PASSWORD, onComplete: {
            (error: NSError?) -> Void in
            
            if let loginError = error {
                // login failed
                
                print("login failed for user \(USERNAME). The error was: \(loginError.description)")
                
                return
            }
            let repository: IBMECMRepository = IBMECMFactory.sharedInstance.getCurrentRepository(ibmecmapp)!
            self.searchonRepos(repository)
        })
        
    }
    
    fileprivate func searchonRepos(_ repos: IBMECMRepository){
        
        let criterion1: IBMECMSearchPredicate = IBMECMSearchPredicate.greater(propertyId: "DateLastModified", dataType: IBMECMPropertyDataType.Timestamp, cardinality:IBMECMPropertyCardinality.Single, values: ["2015-06-18T10:00:00.000Z" as AnyObject])
        
        // dataType should map to property type in ICN system, you should consult with admin for it
//        let criterion2: IBMECMSearchPredicate = IBMECMSearchPredicate.Like(propertyId: "DocumentTitle", dataType: IBMECMPropertyDataType.String, cardinality:IBMECMPropertyCardinality.Single, values: ["error \(index)"])
        
        repos.searchAdHoc(
            nil,
            teamspaceId: nil,
            searchClasses: [ "Document" ],
            objectType: IBMECMObjectType.Document,
            searchPredicates: [ criterion1 ],
            textSearchPredicate: nil,
            orderBy: nil,
            descending: nil,
            pageSize: 10, onComplete: {
                (resultSet: IBMECMResultSet?, error: NSError?) -> Void in
                
                if let err = error {
                    // error searching
                    
                    print("Could not get search results. The error was: \(err.description)")
                    
                    return
                }
                
                if let rs = resultSet {
                    if let items = rs.items {
                        for item: IBMECMContentItem in items {
                            print("Search match id = \(item.id), name = \(item.name), isFolder = \(item.isFolder)")
                        }
                    }
                }
                
                print("search done")
                
        })
    }
    
    fileprivate func retrieveDocumentCheckOutThenInThenLike() {
        let ibmecmapp: IBMECMApplication = IBMECMFactory.sharedInstance.getApplication(SERVER_URL)
    
        // SEE: LOGIN
        ibmecmapp.login(USERNAME, password: PASSWORD, onComplete: {
            (error: NSError?) -> Void in
            
            if let loginError = error {
                // login failed
                
                print("login failed for user \(USERNAME). The error was: \(loginError.description)")
                
                return
            }
            
            //Obtain the current repository set for the default desktop
            let repository: IBMECMRepository = IBMECMFactory.sharedInstance.getCurrentRepository(ibmecmapp)!
            
            // SEE: FETCH DOCUMENT BY ID
            repository.retrieveItem("Document,{336211AE-4EB8-4DB3-8E95-BD40317C20BA},{67625351-DB38-4500-B83D-9BAD391358C7}", onComplete: {
                (contentItem, error) -> Void in
                
                if let err = error {
                    // error retriving folder
                    
                    print("Could not get root folder. The error was: \(err.description)")
                    
                    return
                }
                
                if let fetchedDoc: IBMECMContentItem = contentItem {
                    fetchedDoc.addRecommendation({
                        (error: NSError?) -> Void in
                        
                        if let loginError = error {
                            // login failed
                            
                            print("liking the document failed. The error was: \(loginError.description)")
                            
                            return
                        }
                    })
                    
                    fetchedDoc.retrieveRecommendations({
                        (resultSet: IBMECMRecommendationResultSet?, error: NSError?) -> Void in
                        
                        if let recommendationItems = resultSet {
                            if let items = recommendationItems.items {
                                for item: IBMECMSocialItem in items {
                                    // iterate through document likes
                                    print("document like by user: \(String(describing: item.originator))")
                                }
                            }
                            
                            if let _ = recommendationItems.myRecommendation {
                                // determine whether this user has liked the document
                            }
                        }
                    })
                }
            })
        })
    }
    
    fileprivate func retrieveFolderThenGetFolderContaineesThenGetDocument_Scenario() {
        //Create a top level IBMECMApplication object with a Content Navigator desktop URL
        let ibmecmapp: IBMECMApplication = IBMECMFactory.sharedInstance.getApplication(SERVER_URL)
        
        // SEE: LOGIN
        ibmecmapp.login(USERNAME, password: PASSWORD, onComplete: {
            (error: NSError?) -> Void in
            
            if let loginError = error {
                // login failed
                
                print("login failed for user \(USERNAME). The error was: \(loginError.description)")
                
                return
            }
            
            //Obtain the current repository set for the default desktop
            let repository: IBMECMRepository = IBMECMFactory.sharedInstance.getCurrentRepository(ibmecmapp)!
            
            print("logged in as \(USERNAME). Repository name: \(repository.id)")
            
            // SEE: FETCH ITEM BY ID
            repository.retrieveItem("Folder,{336211AE-4EB8-4DB3-8E95-BD40317C20BA},{FAA7B1A0-94FC-4E78-AA28-C540D4B3A0CA}", onComplete: {
                (contentItem, error) -> Void in
                
                if let err = error {
                    // error addind folder
                    
                    print("Could not get root folder. The error was: \(err.description)")
                    
                    return
                }
                
                if let retrievedFolder: IBMECMContentItem = contentItem {
                    print("the retrieved folder's id is: \(retrievedFolder.id), the name is \(retrievedFolder.name)")
                    
                    // SEE: GET FOLDER CONTAINEES
                    retrievedFolder.retrieveFolderContent(false, orderBy: nil, descending: false, pageSize: 25, teamspaceId: nil, onComplete: {
                        (resultSet: IBMECMResultSet?, error) -> Void in
                        
                        if let err = error {
                            // error adding folder
                            
                            print("Could not get folder contents. The error was: \(err.description)")
                            
                            return
                        }
                        
                        if let rs = resultSet {
                            if let items = rs.items {
//                                var foundOne: Bool = false
                                print("items count \(items.count)")
                                for item: IBMECMContentItem in items {
                                    
                                    print("Folder Containeee: id = \(item.id), name = \(item.name), isFolder = \(item.isFolder)")
                                    
                                    if(item.isFolder) {
                                        continue
                                    }
                                    
                                    
                                    // containee is a document, let's get properties and contents
                                    // SEE: GET DOCUMENT PROPERTIES
                                    let docProps: [String : AnyObject] = item.properties
                                    for(propName, propValue) in docProps {
                                        print("Property Name '\(propName)' - Property Value '\(propValue)'")
                                    }
                                    //TODO
                                    let tempFilePath: String = "\(NSTemporaryDirectory())txt" 
                                    
                                    // Remove exising file in tempFilePath
//                                    var error:NSError?
                                    let fileManager = FileManager()
                                    
                                    do {
                                     try fileManager.removeItem(atPath: tempFilePath)
                                        print("Successfully deleted the path \(tempFilePath)")
                                    } catch let err as NSError {
                                        print("Failed to remove path \(tempFilePath) with error \(err)")
                                        
                                    }
                                    // SEE: GET DOCUMENT CONTENT
                                    
                                    item.retrieveDocumentItem(tempFilePath,
                                        onComplete: {
                                            (error: NSError?) -> Void in
                                            
                                            if let err = error {
                                                // error downloading document content
                                                print("document content could not be retrived. The error was: \(err.description)")
                                                
                                                return
                                            }
                                            do{
                                            let contentsOfFile: String = try NSString(contentsOfFile: tempFilePath, encoding: String.Encoding.utf8.rawValue) as String
                                            
                                            print("contents of the file: \(contentsOfFile)")
                                            } catch let err as NSError {
                                                print("Failed to get string content from path \(tempFilePath) with error \(err)")
                                                
                                            }
                                        }, progress: nil)
                                    
                                    // we will just do this for one document for now and then break
                                    break
                                }
                            }
                        }
                    })
                }
            })
        })
    }
    
    fileprivate func addFolderThenDocument_Scenario() {
        let ibmecmapp: IBMECMApplication = IBMECMFactory.sharedInstance.getApplication(SERVER_URL)
        
        // SEE: LOGIN
        ibmecmapp.login(USERNAME, password: PASSWORD, onComplete: {
            (error: NSError?) -> Void in
            
            if let loginError = error {
                // login failed
                
                print("login failed for user \(USERNAME). The error was: \(loginError.description)")
                
                return
            }
            
            //Obtain the current repository set for the default desktop
            let repository: IBMECMRepository = IBMECMFactory.sharedInstance.getCurrentRepository(ibmecmapp)!
            
            print("logged in as \(USERNAME). Repository name: \(repository.id)")
            
            // SEE: FETCH ITEM BY PATH
            repository.retrieveItem("/", onComplete: {
                (contentItem, error) -> Void in
                
                if let err = error {
                    // error addind folder
                    
                    print("Could not get root folder. The error was: \(err.description)")
                    
                    return
                }
                
                if let rootFolder: IBMECMContentItem = contentItem {
                    print("the root folder's id is: \(rootFolder.id), the name is \(rootFolder.name)")
                    let properties = IBMECMFactory.sharedInstance.getIBMECMItemProperties()
                    properties.add("name", value: "FolderName" as AnyObject)
                    properties.add("value", value: "my new folder \(AppDelegate.randomStringWithLength(8))" as AnyObject)
                    
                    repository .addFolderItem("Folder", parentFolderId: rootFolder.id, teamspaceId: nil, properties: properties, onComplete: {
                        (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
                        
                        if let err = error {
                            // error addind folder
                            
                            print("folder could not be added. The error was: \(err.description)")
                            
                            return
                        }
                        
                        // folder was added successfully
                        
                        if let folderAdded: IBMECMContentItem = contentItem {
                            print("the new folder's id is: \(folderAdded.id) and folder name is: \(folderAdded.name)")
                            
                            let properties = IBMECMFactory.sharedInstance.getIBMECMItemProperties()
                            properties.add("name", value: "DocumentTitle" as AnyObject)
                            properties.add("value", value: "my new document" as AnyObject)

                            // SEE: ADD DOCUMENT WITH PROPERTIES
                            repository.addDocumentItem(
                                folderAdded.id,
                                teamspaceId: nil,
                                templateName: "Document",
                                contentSourceType: IBMECMContentSourceType.Document,
                                properties: properties,
                                mimeType: "plain/text",
                                fileName: "textfile.txt",
                                content: "text contents".data(using: String.Encoding.utf8, allowLossyConversion: false),
                                addAsMinorVersion: false,
                                onComplete: {
                                    (contentItem, error) -> Void in
                                    
                                    if let err = error {
                                        // error addind folder
                                        
                                        print("document could not be added. The error was: \(err.description)")
                                        
                                        return
                                    }
                                    
                                    // document added successfully
                                },
                                progress: nil
                            )
                        }
                    })
                }
            })
        })
    }
    
    fileprivate func checkIn(_ contentItem: IBMECMContentItem, onComplete: @escaping OnCompleteBlock){
        let properties = IBMECMFactory.sharedInstance.getIBMECMItemProperties()
        properties.add("name", value: "DocumentTitle" as AnyObject)
        properties.add("value", value: contentItem.name as AnyObject)
        properties.add("dataType", value: "xs:string" as AnyObject)
        properties.add("label", value: "Document Title" as AnyObject)
        properties.add("displayValue", value: contentItem.name as AnyObject)

        let asMinorVersion = false
        
//        var error: NSError?
        do {
        let content:Data? = try NSString(contentsOfFile: "SAMPLE/PATH/SAMPLE.txt", encoding: String.Encoding.utf8.rawValue).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        
        contentItem.checkIn(contentItem.name, templateName: contentItem.templateName!, contentSourceType: IBMECMContentSourceType.Document, mimetype: contentItem.mimetype!, data: content!, properties: properties, asMinorVersion: asMinorVersion, onComplete:
            {
                (contentItem, error) -> Void in
                if let err = error {
                    self.displayError(err)
                }
                else {
                    onComplete(contentItem!)
                }
            },
            progress: nil)
        } catch let err as NSError {
            print("Failed to checkIn with error \(err)")
            
        }

    }
    
    //Retrieve the parent folder by calling the repository.retrieveItem API.  The ID/PATH allows you to retrieve any folder.
    //The single slash is the root folder for the repository.
    fileprivate func retrieveParentFolder(_ repository: IBMECMRepository?, onComplete: @escaping OnCompleteBlock){
        repository?.retrieveItem("/", onComplete: {
            (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
            
            if let item = contentItem {
                print("Item's name: \(item.name)")
                onComplete(item)
            }
        })
    }
    
    //Adds a new document by specifying data to a local file and providing property values
    fileprivate func addDocumentItem(_ repository: IBMECMRepository?, parentFolder: IBMECMContentItem, teamspace: IBMECMTeamspace?, onComplete: OnCompleteBlock?){
        let properties = IBMECMFactory.sharedInstance.getIBMECMItemProperties()
        properties.add("name", value: "DocumentTitle" as AnyObject)
        properties.add("value", value: "New Document \(AppDelegate.randomStringWithLength(8))" as AnyObject)

//        var error: NSError?
        do {

        let content:Data? = try NSString(contentsOfFile: "SAMPLE/PATH/SAMPLE.txt", encoding: String.Encoding.utf8.rawValue).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        
        repository?.addDocumentItem(parentFolder.id, teamspaceId: teamspace?.id, templateName: "Document", contentSourceType: IBMECMContentSourceType.Document, properties: properties, mimeType: "text/plain", fileName: "NewDocument.txt", content: content!, addAsMinorVersion: false, onComplete:
            {
                (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
                if let err = error {
                    self.displayError(err)
                }
                else {
                    print("Finished adding new document")
                    if let item = contentItem {
                        onComplete?(item)
                    }
                }
            },
            progress: nil
        )
        } catch let err as NSError {
            print("Failed to add doc with error \(err)")
            
        }

    }
    
    //Adds a new folder by providing property values
    fileprivate func addFolderItem(_ repository: IBMECMRepository?, parentFolder: IBMECMContentItem, teamspace: IBMECMTeamspace?, onComplete: OnCompleteBlock?) {
        let randomNum = Int(arc4random_uniform(99))
        let folderName = "NewFolder" + String(randomNum)
        let properties = IBMECMFactory.sharedInstance.getIBMECMItemProperties()
        properties.add("name", value: "FolderName" as AnyObject)
        properties.add("value", value: folderName as AnyObject)

        
        repository?.addFolderItem("Folder", parentFolderId: parentFolder.id, teamspaceId: teamspace?.id, properties: properties, onComplete: {
            (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
            if let err = error{
                self.displayError(err)
            }
            else {
                print("Finished adding new folder")
                if let item = contentItem {
                    onComplete?(item)
                }
            }
        })
    }
    
    fileprivate func displayError(_ error: NSError?){
        if let userInfo = error?.userInfo {
            for (key, value) in userInfo {
                print("Error Key: \(key) - Error Message: \(value)")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    class func randomStringWithLength (_ len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0 ..< len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
}

