import class Foundation.Bundle

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("NetIdMobileSdk_NetIdMobileSdk.bundle").path
        let buildPath = "/Users/tbachmor/workspace/united/netid/netid-sdk-ios/.build/arm64-apple-macosx/debug/NetIdMobileSdk_NetIdMobileSdk.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}