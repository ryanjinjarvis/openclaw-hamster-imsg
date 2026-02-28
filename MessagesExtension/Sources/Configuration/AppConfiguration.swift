import Foundation

enum AppConfiguration {
    static let remoteManifestURL = URL(string: "https://cdn.jsdelivr.net/gh/ryanjinjarvis/openclaw-hamster-imsg@main/remote_assets/manifest_v1.json")!
    static let manifestRequestTimeout: TimeInterval = 10
    static let telemetryEnabled = false
}
