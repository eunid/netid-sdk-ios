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
- host: the name of the broker for the SSO service. This Parameter is optional. If ommited, this is set to the default broker broker.netid.de
- clientId: the client id of your application. You can retrieve it from the netID Developer portal. This parameter is mandatory.
- redirectUri: an URI that is used by your application to catch callbacks when using the wep2app flow. This parameter is mandatory.
- originUrlScheme: used for creating deep links, not in use anymore (will be removed)
- claims: an array of strings, denoting additional claims that should be set during authorization. Can be nil.

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




