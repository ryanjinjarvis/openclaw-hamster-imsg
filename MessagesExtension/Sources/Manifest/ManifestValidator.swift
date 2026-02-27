import Foundation

protocol ManifestValidating {
    func validate(_ manifest: HamsterManifest) throws
}

final class ManifestValidator: ManifestValidating {
    private let expectedVersion = "v1"

    func validate(_ manifest: HamsterManifest) throws {
        guard manifest.version == expectedVersion else {
            throw ManifestError.validationFailed("Expected manifest version \(expectedVersion), got \(manifest.version)")
        }
        guard !manifest.items.isEmpty else {
            throw ManifestError.validationFailed("Manifest contains no items")
        }

        for (index, item) in manifest.items.enumerated() {
            guard !item.id.isEmpty else {
                throw ManifestError.validationFailed("Item at index \(index) has no id")
            }
            guard item.imageUrl.scheme?.hasPrefix("http") == true else {
                throw ManifestError.validationFailed("Item \(item.id) imageUrl must be remote HTTP/HTTPS")
            }
            guard item.thumbnailUrl.scheme?.hasPrefix("http") == true else {
                throw ManifestError.validationFailed("Item \(item.id) thumbnailUrl must be remote HTTP/HTTPS")
            }
            guard item.popularity >= 0 else {
                throw ManifestError.validationFailed("Item \(item.id) popularity must be >= 0")
            }
            guard !item.source.platform.isEmpty,
                  !item.source.account.isEmpty,
                  !item.source.postId.isEmpty else {
                throw ManifestError.validationFailed("Item \(item.id) has incomplete source metadata")
            }
        }
    }
}
