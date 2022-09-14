# netID MobileSDK for iOS

## About

## Initialize NetIDService

First you need to assign a delegate of type  'NetIdServiceDelegate' for recieving all callbacks.
```swift
NetIdService.sharedInstance.registerListener(self)
```

Then, construct a configuration object for the NetIDService:
```swift
let config = NetIdConfig(host: "broker.netid.de",
                clientId: "26e016e7-54c7-4ffd-bee0-782a9a4f87d6",
                redirectUri: "de.netid.mobile.sdk.NetIdMobileSdk:/oauth2redirect/example-provider",
                originUrlScheme: "netIdExample",
                claims: nil)
```

The parameters have the following meaning:
| Parameter | Description |
| :---        |    :---   |
| host | The name of the broker for the SSO service. This Parameter is optional. If ommited, this is set to the default broker broker.netid.de |
| clientId | The client id of your application. You can retrieve it from the netID Developer portal. This parameter is mandatory. |
| redirectUri | An URI that is used by your application to catch callbacks when using the wep2app flow. This parameter is mandatory. |
| originUrlScheme | Used for creating deep links, not in use anymore (will be removed) |
| claims | An array of strings, denoting additional claims that should be set during authorization. Can be nil. |

And then, initialize the NetIdService.
```swift
NetIdService.sharedInstance.initialize(config)
```
It makes sense to sum this up into one method like e.g.:
```swift
    func initializeNetIdService() {
        initializationEnabled = false
        NetIdService.sharedInstance.registerListener(self)
        let config = NetIdConfig(host: "broker.netid.de", clientId: "26e016e7-54c7-4ffd-bee0-782a9a4f87d6",
                redirectUri: "de.netid.mobile.sdk.NetIdMobileSdk:/oauth2redirect/example-provider", originUrlScheme: "netIdExample",
                claims: nil)
        NetIdService.sharedInstance.initialize(config)
    }
```

## Authorization

After the NetIDService has been initialized, subsequent calls to request authorization can be made. To initiate the authorization process, issue the following call to the NetIDService:
```swift
NetIdService.sharedInstance.getAuthorizationView(currentViewController: currentViewController, authFlow: authFlow)
```
You have to provide an instance of you app's view controller so that the SDK can display a view for the authorization process itself.
The optional parameter authFlow decides, which authorization flow to use.
If the user did decide on how to proceed with the login process (e.g. which ID provider to use), a redirect to actually execute the authorization is called automatically.

## Using the authorized service

Subsequent calls now can be made to use different aspects of the service.


```swift
NetIdService.sharedInstance.endSession()
```
Use this call to end a session. On the delegate `didEndSession` is called signalling success of the operation. All objects regarding authorization (e.g. tokens) will get discarded. However, the service itself will still be available. A new call to `getAuthorizationView` will trigger a new authorization process.

```swift
NetIdService.sharedInstance.fetchUserInfo()
```
Fetches the user information object. On success `didFetchUserInfo` is called on the delegate, returning the requested information. Otherwise `didFetchUserInfoWithError` gets called, returning a description of the error.

```swift
NetIdService.sharedInstance.fetchPermissions()
```
Fetches the permissions object. On success `didFetchPermissions` is called on the delegate, returning the requested information. Otherwise `didFetchPermissionsWithError` gets called, returning a description of the error.

```swift
NetIdService.sharedInstance.updatePermissions()
```
Updates the permissions object. On success `didUpdatePermissions` is called on the delegate, returning the requested information. Otherwise `didUpdatePermissionsWithError` gets called, returning a description of the error.

```swift
NetIdService.sharedInstance.transmitToken(token)
```
Sets the id token to be used by the SDK. When using app2web flow, it is not neccessary to set the token because the SDK itself gets a callback and can extract the id token. But in the app2app flow, the application is getting the authorization information directly. And thus, the application has to set the token for further use in the SDK.

