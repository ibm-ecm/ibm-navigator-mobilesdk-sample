# IBMECMCore SDK

This SDK is a manifestation of the IBM Content Navigator mid-tier API, written exclusively in Swift.

## Features

Some of the goals of this framework are to provide the following:

* Simple sync and async requests to any IBM Content Navigator back end
* A native object model to consume

## Requirements

* iOS 9
* Xcode 11.4

## Installation

One way to install this framework is to manually drag it into your project's Frameworks group. If your project does not have a Frameworks group, create one. Set the `Embedded Code contains Swift Code` of your target to `YES`. The SDK requires the following libraries in order to build successfully: 
* CocoaLumberjack version 3.6.1
* Alamofire version 4.9.1
* Mantle version 2.0.2
* MTLManagedObjectAdapter version 1.0.3

You can either link the libraries directly into your Xcode project or indirectly by using Cocoapods or Carthage.

Following is a Podfile that you can use to build a sample project utilizing the Core SDK (suitable for Cocoapods 1.0).

```
platform :ios, '9.0'
use_frameworks!

def corekit_pods
    pod 'CocoaLumberjack', '3.6.1'
    pod 'Alamofire', '4.9.1'
    pod 'Mantle', '2.0.2'
    pod 'MTLManagedObjectAdapter', '1.0.3'
end

target 'SampleApp' do
    project 'SampleApp.xcodeproj'

    corekit_pods

    target 'SampleAppTests' do
        inherit! :search_paths
    end
end

workspace 'myworkspace'
```

## Usage

This framework is based on a common factory pattern to obtain references to ECM objects. One place to start might be at the IBMECMFactory.sharedInstance, and obtain the top-level IBMECMApplication object by passing in the IBM Content Navigator URL. The URL is usually in the form: `http://server:port/navigator`.  

`let ibmecmapp: IBMECMApplication = IBMECMFactory.sharedInstance.getApplication("http://server:port/navigator")`

After the IBMECMApplication object is obtained, you can log in to IBM Content Navigator, and then obtain references to IBMECMDesktop, IBMECMRepository, and other objects.  

`ibmecmapp.login("XXX", password: "XXX", onComplete: ())`

From there, you can follow the API documentation to use other features such as:

`IBMECMRepository.retrieveItem(_ itemIdOrFullPath: String, onComplete: ((_ contentItem: IBMECMContentItem?, _ error: NSError?) -> Void)?)`

`IBMECMRepository.addDocumentItem(_ entryTemplate: IBMECMEntryTemplate, parentFolderId: String, teamspaceId: String?, contentSourceType: IBMECMContentSourceType, properties: IBMECMItemProperties, mimeType: String, fileName: String?, content: Data?, onComplete: ((_ contentItem: IBMECMContentItem?, _ error: NSError?) -> Void)?, progress: ((_ theProgress: Progress) -> Void)?)`

`IBMECMRepository.addFolderItem(_ templateName: String, parentFolderId: String, teamspaceId: String?, properties: IBMECMItemProperties, onComplete: ((_ contentItem: IBMECMContentItem?, _ error: NSError?) -> Void)?)`


## Contact

Qi Wang - wangqqi@cn.ibm.com - @qi-wang
