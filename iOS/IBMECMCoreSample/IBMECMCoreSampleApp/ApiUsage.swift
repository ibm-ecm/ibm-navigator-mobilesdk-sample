/*
* © Copyright IBM Corp. 2015
*/


import IBMECMCore

class ApiUsage {
    
    let ibmecmapp: IBMECMApplication
    
    init(navigatorUrl: String) {
        ibmecmapp = IBMECMFactory.sharedInstance.getApplication(navigatorUrl)
    }
    
    /**
    Performs login to the default navigator repository
    
    :param: username user to login as
    :param: password username's corresponding password
    */
    func login(username: String, password: String) {
        ibmecmapp.login(username, password: password, onComplete: {
            (error: NSError?) -> Void in
            
            if let _ = error {
                // login failed
            } else {
                // login succeeded
                
                //Obtain the current repository set for the default desktop
                let repository: IBMECMRepository = IBMECMFactory.sharedInstance.getCurrentRepository(self.ibmecmapp)!
                
                print("logged in as \(username). Repository name: \(repository.id)")
            }
        })
    }
    
    /**
    Retrieve an item from a given repository based on path
    
    :param: path       the item's path (for example '/' for root folder, or Guid to retrieve by Id)
    :param: repository the repository to fetch from
    */
    func retrieveRepositoryItemByPathOrId(pathOrId: String, repository: IBMECMRepository) {
        repository.retrieveItem(pathOrId, onComplete: {
            (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
            
            if let item = contentItem {
                print("item's name: \(item.name)")
            }
        })
    }
    
    /**
    Retrieve all versions for one document from a given repository based on item id
    
    :param: itemId     the item's Guid
    :param: repository the repository to fetch from
    */
    func retrieveRepostioryItemAllVersions(itemId: String, repository: IBMECMRepository) {
        repository.retrieveContentItemAllVersions(itemId, onComplete: {
            (resultSet: IBMECMResultSet?, error: NSError?) -> Void in
            
            if let _ = error {
                // error while retrieving all versions for current item
            } else {
                if let rs = resultSet {
                    // all versions retrieved successfully
                    print("resultSet | .pageSize =>\(rs.pageSize)")
                    
                    if let items = rs.items {
                        // do something after retrieving all versions of a document
                        print("items | .count =>\(items.count)")
                        
                        for item in items {
                            print("item | .id = \(item.id), .name = \(item.name), .isFolder = \(item.isFolder), .versionStatus = \(item.versionStatus?.description)")
                        }
                    }
                }
            }
        })
    }
    
    /**
    Retrieve the personal folders from a given navigator desktop
    
    :param: desktop desktop to retrieve from
    */
    func retrievePersonalFolder(desktop: IBMECMDesktop) {
        desktop.retrieveMyPersonalFolder({
            (favorite: IBMECMFavorite?, error: NSError?) -> Void in
            
            if let _ = error {
                // error while retrieving personal folder
            } else {
                if let _ = favorite {
                    // personal folder retrived successfully
                } else {
                    // no personal folder exists for user (very uncommon)
                }
            }
        })
    }
    
    /**
    Retrieve all contents from a given folder
    
    :param: folder the folder whose contents to fetch
    */
    
    
    /**
    Retrieves a folder's content
    
    :param: foldersOnly  whether to return folders only
    :param: orderBy      sort result by
    :param: descending   whether to sort result in a descending way
    :param: teamspaceId  team space id if the current folder is a folder within team space
    :param: folder       folder object to be operated
    */
    func retrieveFolderContents(foldersOnly: Bool, orderBy: String?, descending: Bool, teamspaceId: String?, folder: IBMECMContentItem) {
        if !folder.isFolder {
            // you can only get contents of folders
            return
        }
        
        folder.retrieveFolderContent(
            foldersOnly,
            orderBy: orderBy,
            descending: descending,
            pageSize: 25,
            teamspaceId: teamspaceId,
            onComplete:
            {
                (resultSet: IBMECMResultSet?, error: NSError?) -> Void in
                if let _ = error {
                    // error retrieving folder contents
                }
                
                if let rs = resultSet {
                    print("resultSet | .pageSize =>\(rs.pageSize)")
                    
                    if let items = rs.items {
                        // do something after retrieving contents of a folder
                        print("items | .count =>\(items.count)")
                        
                        for item in items {
                            print("item | .id = \(item.id), .name = \(item.name), .isFolder = \(item.isFolder)")
                        }
                    }
                    
                    // SEE: Paging
                    if rs.hasMore() {
                        rs.retrieveNextPage({
                            (resultSet: IBMECMResultSet?, error: NSError?) -> Void in
                            
                            if let _ = error {
                                // error retrieving folder contents
                            }
                            
                            if let rs = resultSet {
                                print("resultSet | .pageSize =>\(rs.pageSize)")
                                
                                if let items = rs.items {
                                    // do something after retrieving contents of next page for a folder
                                    print("items | .count =>\(items.count)")
                                    
                                    for item in items {
                                        print("item | .id = \(item.id), .name = \(item.name), .isFolder = \(item.isFolder)")
                                    }
                                }
                            }
                        })
                    }
                    
                }
            }
        )
    }
    
    /**
    Retrieve the documents from repository based on search classes and criterias provided
    
    :param: searchFolderId      The folder id if the search scope is restricted to one folder
    :param: teamspaceId         The teamspace id if the search is restricted within one teamspace
    :param: searchClasses       the classes the documents are retrieved from(eg.  ["BMW", "Cruise"]), which should be with the same object type
    :param: searchPredicates    The list of search predicate for properties, the relation among these search predicates are conjunction or intersection. IBMECMSearchPredicate can be used to construct predicate.
    :param: textSearchPredicate The text search predicate. IBMECMTextSearchPredicate can be used to construct text search predicate
    :param: pageSize            The initial page size to show search result
    :param: repository          The IBMECMRepository object
    :param: onComplete          The completion block for call back
    */
    func searchDocuments(searchFolderId: String?, teamspaceId: String?, searchClasses: [String], searchPredicates: [IBMECMSearchPredicate]?, textSearchPredicate: IBMECMTextSearchPredicate?, pageSize: NSNumber?, repository: IBMECMRepository) {
        
        // Already done the following TODO, please check it
        // TODO: ALL parameters have to be filtered up to the method declaration above
        // TODO: it is unclear to me how you define operators for criteria (>, like, =, ! etc)
        // TODO: I see you can specify multiple classes to search, it is unclear to me if those are union-ed or intersect-ed etc (AND, OR)
        // TODO: how do you specific the initial page size, it is not right for the initial page to be hardcode and then we allow you to change it
        // TODO: the method declaration above is missing documentation
        
        repository.searchAdHoc(searchFolderId, teamspaceId: teamspaceId, searchClasses: searchClasses, objectType: IBMECMObjectType.Document, searchPredicates: searchPredicates, textSearchPredicate: textSearchPredicate, orderBy: nil, descending: nil, pageSize: pageSize, onComplete: {
            (resultSet: IBMECMResultSet?, error: NSError?) -> Void in
            
            if let _ = error {
                // handle the error once failure to search
            } else {
                if let resultSet = resultSet {
                    // do something as will after searching sucessfully
                    print("resultSet | id =>\(resultSet.id), pageSize =>\(resultSet.pageSize)")
                    
                    if let items = resultSet.items {
                        for item in items {
                            print("item | .id = \(item.id), .name = \(item.name), .isFolder = \(item.isFolder)")                        }
                        
                        if resultSet.hasMore() { // can fetch next page
                            resultSet.pageSize = 2
                            resultSet.retrieveNextPage({
                                (resultSet, error) -> Void in
                                
                                if let _ = error {
                                    // handle error on failure to fetch next page
                                }
                                
                                if let resultSet = resultSet {
                                    // do something as will after fetching next page sucessfully
                                    print("resultSet | id =>\(resultSet.id), pageSize =>\(resultSet.pageSize)")
                                    
                                    if let items = resultSet.items {
                                        for item in items {
                                            print("item | .id = \(item.id), .name = \(item.name), .isFolder = \(item.isFolder)")
                                            
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    /**
    Add a new document to the repository
    
    :param: documentTitle     new document's title (eg. "This is the title of my new document")
    :param: documentClassName the class name for the new document (eg. "Document")
    :param: contentSourceType the document's content source, see IBMECMContentSourceType
    :param: contentMimeType   the document's mime type (eg. "text/plain")
    :param: contentData       the document's binary data. It's nil for external document or content-less document
    :param: contentFileName   a filename for this document (can be anything) or URL for external document; otherwise, nil
    :param: isMajor           whether the document added will have a major version or minor
    :param: parentFolder      the folder to put the document in (required)
    :param: teamspace         the teamspace to put the document in (optional)
    :param: repository        the repository to add the document into
    */
    func addDocumentItem(documentTitle: String, documentClassName: String, contentSourceType: IBMECMContentSourceType, contentMimeType: String, contentData: NSData?, contentFileName: String?, isMajor: Bool?, parentFolder: IBMECMContentItem, teamspace: IBMECMTeamspace?, repository: IBMECMRepository){
        
        var asMinorVersion: Bool = false
        if let major = isMajor {
            asMinorVersion = !major
        }
        
        var properties = [[String : AnyObject]]()
        properties.append([
            "name": "DocumentTitle",
            "value": documentTitle])
        
        repository.addDocumentItem(
            parentFolder.id,
            teamspaceId: teamspace?.id,
            templateName: documentClassName,
            contentSourceType: contentSourceType,
            properties: properties,
            mimeType: contentMimeType,
            fileName: contentFileName,
            content: contentData,
            addAsMinorVersion: asMinorVersion,
            onComplete: {
                (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
                if let _ = error {
                    // error adding document
                } else {
                    // document was added successfully
                }
            }, progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                // progress
        })
    }
    
    /**
    Add a new folder to the repository
    
    :param: folderName   name of the folder ("This is my new folder")
    :param: folderClass  the class name for the new folder (eg. "Folder")
    :param: parentFolder the folder to put the new folder into (required)
    :param: teamspace    the teamspace to put the new folder into (optional)
    :param: repository   the repository to add the folder in
    */
    func addFolder(folderName: String, folderClass: String, parentFolder: IBMECMContentItem, teamspace: IBMECMTeamspace?, repository: IBMECMRepository) {
        var properties = [[String : AnyObject]]()
        properties.append([
            "name": "FolderName",
            "value": folderName])
        
        repository.addFolderItem(folderClass, parentFolderId: parentFolder.id, teamspaceId: teamspace?.id, properties: properties, onComplete: {
            (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
            if let _ = error {
                // error addind folder
            } else {
                // folder was added successfully
            }
        })
    }
    
    /**
    Checks out a document
    
    :param: document the document to checkout
    */
    func checkOutDocument(document: IBMECMContentItem) {
        document.checkout(
            {
                (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
                
                if let _ = error {
                    // error checking out
                } else {
                    // checkout succeeded
                }
            }
        )
    }
    
    /**
    Checks in a document
    
    :param: documentTitle      the title of the document (optional, this method will use the title from the existing version if none is supplied)
    :param: documentClassName  the class of the document (optional, will use the older one)
    :param: contentSourceType the document's content source, see IBMECMContentSourceType
    :param: contentMimeType    the content mime type
    :param: contentData        the data of the content. It's nil for external document or content-less document
    :param: contentFileName    the filename of the content or URL for external document; otherwise, nil
    :param: isMajor            true for major false otherwise
    :param: checkedOutDocument the document to checkin (must be checked out)
    */
    func checkInDocument(documentTitle: String?, documentClassName: String?, contentSourceType: IBMECMContentSourceType,contentMimeType: String, contentData: NSData?, contentFileName: String?, isMajor: Bool?, checkedOutDocument: IBMECMContentItem) {
        
        var docName: String
        if let docTitle = documentTitle {
            docName = docTitle
        } else {
            docName = checkedOutDocument.name
        }
        
        var className: String
        if let docClass = documentClassName {
            className = docClass
        } else {
            className = checkedOutDocument.templateName!
        }
        
        var properties = [[String : AnyObject]]()
        properties.append(["name": "DocumentTitle", "value": docName])
        
        var asMinorVersion: Bool = false
        if let major = isMajor {
            asMinorVersion = !major
        }
        
        checkedOutDocument.checkIn(
            docName,
            templateName: className,
            contentSourceType: contentSourceType,
            mimetype: contentMimeType,
            data: contentData,
            properties: properties,
            asMinorVersion: asMinorVersion,
            onComplete:
            {
                (contentItem: IBMECMContentItem?, error: NSError?) -> Void in
                
                if let _ = error {
                    // error checking in document
                } else {
                    // checkin succeeded
                }
            }, progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                // progress
            }
        )
    }
    
    /**
    Persist a document 'like' for the user signed in
    
    :param: document the document to like
    */
    func likeDocument(document: IBMECMContentItem)
    {
        document.addRecommendation()
            {
                (error: NSError?) -> Void in
                if let _ = error {
                    // save document like failed
                }
        }
    }
    
    /**
    Retrieves document likes
    
    :param: document the document whose likes to retrieve
    */
    func retrieveDocumentLikes(document: IBMECMContentItem) {
        document.retrieveRecommendations {
            (resultSet: IBMECMRecommendationResultSet?, error: NSError?) -> Void in
            
            if let _ = error {
                // retrieve document recommendations failed
            }
            
            if let recommendationItems = resultSet {
                if let items = recommendationItems.items {
                    for _: IBMECMSocialItem in items {
                        // iterate through document likes
                    }
                }
                
                if let _ = recommendationItems.myRecommendation {
                    // determine whether this user has liked the document
                }
            }
        }
    }
    
    /**
    Add a comment on a document
    
    :param: comment   the comment text
    :param: document  the document which the comment is on
    */
    func commentOnDocument(comment: String, document: IBMECMContentItem) {
        document.addComment(comment, onComplete: {
            (icnResult: IBMECMComment?, error: NSError?) -> Void in
            
            if let _ = error {
                // adding a comment to a document failed
            } else {
                // adding a comment succeeded
            }
        })
    }
    
    /**
    Retrieves document comments
    
    :param: document document whose comments to retrieve
    */
    func retrieveDocumentComments(document: IBMECMContentItem) {
        document.retrieveComments {
            (resultSet: IBMECMCommentsResultSet?, error: NSError?) -> Void in
            
            if let _ = error {
                // retrieving documents failed
            }
            
            if let commentsResultSet = resultSet {
                if let items = commentsResultSet.items {
                    print("items.count = \(items.count)")
//                    for item: IBMECMComment in items {
//                        let text = item.comment
//                        let id = item.id
//                        let commentor = item.originatorDisplayValue
                    }
//                }
            }
        }
    }
}