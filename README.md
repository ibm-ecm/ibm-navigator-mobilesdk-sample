# IBMECMCore SDK

This SDK is a manifestation of the IBM Content Navigator mid-tier API, written exclusively in Swift.

## Features
Some of the goals of this framework are:

* Simple sync and async requests to any IBM Content Navigator back end
* Native object model to consume

## Requirements
* iOS 9
* Xcode 7.3

## Installation
The easiest way to install this framework is to manually drag it into your project’s Frameworks group. If your project does not have a Frameworks group, create one. Set the Embedded Code contains Swift Code of your target to YES. The SDK requires the following libraries in order to build successfully: CocoaLumberjack version 1.9.2, Alamofire version 2.0, Mantle version 2.0.2, and MTLManagedObjectAdapter version 1.0. You can either link those libraries directly into your Xcode project or indirectly by using Cocoapods or Carthage.

As an example, here is a Podfile that we can be used to build a sample project utilizing the Core SDK (suitable for Cocoapods 1.0).

```
platform :ios, '8.4'
use_frameworks!

def corekit_pods
    pod 'CocoaLumberjack', '1.9.2'
    pod 'Alamofire', '~> 2.0'
    pod 'Mantle', '2.0.2'
    pod 'MTLManagedObjectAdapter', '~> 1.0'
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

Usage
This framework is based on a common factory pattern to obtain references to ECM objects. One place to start might be at the IBMECMFactory.sharedInstance, and obtain the top-level IBMECMApplication object by passing in the IBM Content Navigator URL. The URL is usually in the form of http://server:port/navigator.

```
let ibmecmapp: IBMECMApplication = IBMECMFactory.sharedInstance.getApplication("http://server:port/navigator")
```

After the IBMECMApplication object is obtained, you can log in to IBM Content Navigator, and then subsequently obtain references to IBMECMDesktop, IBECMRepository, and other objects.
```
ibmecmapp.login("XXX", password: "XXX", completionBlock: ())
```

From there on, you can follow the API documentation to do general functionalities such as: repository.retrieveItem(contentId: String, completionBlock: ((contentItem: IBMECMContentItem?, error: NSError?) -> Void)?)
```
addDocumentItem(parentFolderId: String, templateName: String, properties: [[String : AnyObject]], mimeType: String, fileName: String, addAsMinorVersion: Bool?, content: NSData, completionBlock: ((contentItem: IBMECMContentItem?, error: NSError?) -> Void)?)

addFolderItem(templateName: String, parentFolderId: String, properties: [[String : AnyObject]], completionBlock: ((contentItem: IBMECMContentItem?, error: NSError?) -> Void)?)
```

