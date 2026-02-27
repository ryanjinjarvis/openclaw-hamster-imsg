import Foundation

enum AppConfiguration {
    static let remoteManifestURL = URL(string: "https://static.openclaw.dev/hamster-pack/v1/manifest.json")!
    static let manifestRequestTimeout: TimeInterval = 10
    static let telemetryEnabled = false
}
