Pod::Spec.new do |spec|

  spec.name         = "NetIdMobileSdk"
  spec.version      = "1.0.0"
  spec.summary      = "An SDK for interfacing with netID authorization and privacy management services."

  spec.description  = <<-DESC

  The netID MobileSDK facilitates the use of the [netID](https://netid.de) authorization and privacy management services. 
  Alongside the SDK, this repository hosts two sample apps, demonstarting the usage of the SDK. 
  The first one is more complete as it demonstrates complete workflows including fetching/setting of additional values and/or user information. 
  The second one is less complex and only demonstrates the basic workflow, if you want to add the different buttons for interacting with the SDK in a more direct way.

                   DESC

  spec.homepage      = "https://github.com/eunid/netid-sdk-ios"
  spec.license       = "Apache License, Version 2.0"
  spec.author        = { "European netID Foundation" => ""}

  spec.platform      = :ios, "14.0"
  spec.swift_version = '5'
  spec.source        = { :git => "https://github.com/eunid/netid-sdk-ios.git", :tag => spec.version }
  spec.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'de.netid.mobile.sdk.NetIdMobileSdk' }
  spec.resource_bundles    = { 'NetIdMobileSdk' => ['Sources/NetIdMobileSdk/UI/*{xcassets}', 'Sources/NetIdMobileSdk/assets/*json', 'Sources/NetIdMobileSdk/SupportingFiles/*/*'] }

  spec.ios.source_files      = "Sources/NetIdMobileSdk/**/*.swift"
  spec.ios.dependency "AppAuth", "~> 1.5"

end
