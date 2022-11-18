# netID MobileSDK for iOS

## About

## Initialize NetIDService

The `NetIdService` is the main interface to communicate with the netID SDK. It handles all the communication with the backend services and provides ui elements for the autherization flow.

First you need to assign a delegate of type 'NetIdServiceDelegate' for recieving all callbacks made by the `NetIdService`.
```swift
NetIdService.sharedInstance.registerListener(self)
```

Then, construct a configuration object for the NetIDService:
```swift
var claims = Dictionary<String, String>()
claims["claims"] = "{\"userinfo\":{\"email\": {\"essential\": true}, \"email_verified\": {\"essential\": true}}}"
let config = NetIdConfig(
                clientId: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
                redirectUri: "https://netid-sdk-web.letsdev.de/redirect",
                claims: claims
                loginLayerConfig: nil
                permissionLayerConfig: nil)
```

The parameters have the following meaning:
| Parameter | Description |
| :---        |    :---   |
| clientId | The client id of your application. You can retrieve it from the netID Developer portal. This parameter is mandatory. |
| redirectUri | An URI that is used by your application to catch callbacks. You can retrieve it from the netID Developer portal. This parameter is mandatory. |
| claims | An array of strings, denoting additional claims that should be set during authorization. Can be nil. |
| loginLayerConfig | A set of strings, that can be used to customize the appearance of the layer for the login flow. Can be nil. |
| permissionLayerConfig | A set of strings, that can be used to customize the appearance of the layer for the permission flow. Can be nil. |

As stated above, it is possible to customize certain aspects of the dialog presented for authorization. For example:
```swift
    let loginLayerConfig = LoginLayerConfig(headlineText: "Headline text", loginText: "Login with app %s", continueText: "Continue text")
``` 

Finally, initialize the NetIdService itself with the aforementioned condfiguration.
```swift
NetIdService.sharedInstance.initialize(config)
```
It makes sense to sum this up into one function like e.g.:
```swift
    func initializeNetIdService() {
        initializationEnabled = false
        NetIdService.sharedInstance.registerListener(self)
        let config = NetIdConfig(clientId: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
                redirectUri: "https://netid-sdk-web.letsdev.de/redirect"
                claims: nil,
                loginLayerConfig: nil,
                permissionLayerConfig: nil)
        NetIdService.sharedInstance.initialize(config)
    }
```

## Authorization

After the NetIDService has been initialized, subsequent calls to request authorization can be made. In the example app, you are presented with three choices as can be seen in this screenhsot.

<img src="images/netID_choose_authFlow.png" alt="netID SDK example app - chosse authFlow" style="width:200px;"/>

In your own app, you most likely will decide which flow to take without an user interaction. To initiate the authorization process, issue the following call to the NetIDService:
```swift
NetIdService.sharedInstance.getAuthorizationView(currentViewController: currentViewController, authFlow: authFlow)
```

| Parameter | Description |
| :---        |    :---   |
| currentViewController | Currently used view controller. |
| authFlow | Type of flow to use, can be either ``NetIdAuthFlow.Permission``, ``NetIdAuthFlow.Login`` or ``NetIdAuthFlow.LoginPermission``. This parameter is mandatory. |
| forceApp2App | If set to true, will yield an ``NetIdError`` if the are no ID apps installed. Otherwise, will use app2web flow automatically. Defaults to ``false``. |

You have to provide an instance of you app's activity so that the SDK can display a view for the authorization process itself.
With the parameter `authFlow`you decide, if you want to use `Permission`, `Login` or `Login + Permission` as authorization flow.
The optional parameter `forceApp2App` decides, if your app wants to use app2app only. If let alone, this parameter defaults to `false` meaning that if no ID provider apps are installed, the SDK will automatically fall back to app2web flow. If set to `true` and no ID provider apps are installed, this call will fail with an error.

Depending on the chosen flow, different views are presented to the user to decide on how to proceed with the authorization process.

<img src="images/netID_login_options.png" alt="netID SDK example app - chosse id app" style="width:200px;"/>
<img src="images/netID_permission_app_options.png" alt="netID SDK example app - chosse id app" style="width:200px;"/>

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

## SDK configuration for ID provider apps

It is possible to configure the SDK to make use of the apps of different ID providers. Right now, two of them are supported.
The configuration resides in the file `netIdAppIdentifiers.json` inside the SDK. As this is an internal part of the SDK, it is not meant to be set via an interface nor API.

```json
{
  "netIdAppIdentifiers": [
    {
      "id": 1,
      "name": "GMX",
      "icon": "logo_gmx",
      "typeFaceIcon": "typeface_gmx",
      "backgroundColor": "#FF1E50A0",
      "foregroundColor": "#FFFFFFFF",
      "iOS": {
        "bundleIdentifier": "de.gmx.mobile.ios.mail",
        "scheme": "gmxmail",
        "universalLink": "https://sso.gmx.net/authorize-app2app"
      },
      "android": {
        "applicationId": "de.gmx.mobile.android.mail",
        "verifiedAppLink": "https://sso.gmx.net/authorize-app2app"
      }
    },
    {
      "id": 2,
      "name": "WEB.DE",
      "icon": "logo_web_de",
      "typeFaceIcon": "typeface_webde",
      "backgroundColor": "#FFFFD800",
      "foregroundColor": "#FF333333",
      "iOS": {
        "bundleIdentifier": "de.web.mobile.ios.mail",
        "scheme": "webdemail",
        "universalLink": "https://sso.web.de/authorize-app2app"
      },
      "android": {
        "applicationId": "de.web.mobile.android.mail",
        "verifiedAppLink": "https://sso.web.de/authorize-app2app"
      }
    }
  ]
}
````
