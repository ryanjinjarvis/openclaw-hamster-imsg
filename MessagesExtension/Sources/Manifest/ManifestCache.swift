import Foundation

final class ManifestCache {
    private let fileManager: FileManager
    private let cacheURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let bundle: Bundle

    init(fileManager: FileManager = .default, bundle: Bundle = .main) {
        self.fileManager = fileManager
        self.bundle = bundle
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.cacheURL = cachesDirectory.appendingPathComponent("hamster_manifest_cache.json")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder
    }

    func loadCachedManifest() -> HamsterManifest? {
        guard fileManager.fileExists(atPath: cacheURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: cacheURL)
            return try decoder.decode(HamsterManifest.self, from: data)
        } catch {
            return nil
        }
    }

    func save(manifest: HamsterManifest) {
        do {
            let data = try encoder.encode(manifest)
            try data.write(to: cacheURL, options: [.atomic])
        } catch {
            Logger.log("Failed to persist manifest: \(error)")
        }
    }

    func loadBundledSeed() -> HamsterManifest? {
        guard let url = bundle.url(forResource: "Manifest/hamster_manifest_seed", withExtension: "json") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(HamsterManifest.self, from: data)
        } catch {
            Logger.log("Failed to read bundled seed: \(error)")
            return nil
        }
    }
}
