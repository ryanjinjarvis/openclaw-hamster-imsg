import Foundation

final class ManifestRepository {
    private let session: URLSession
    private let validator: ManifestValidating
    private let cache: ManifestCache
    private let remoteURL: URL
    private let decoder: JSONDecoder

    init(remoteURL: URL = AppConfiguration.remoteManifestURL,
         session: URLSession = .shared,
         validator: ManifestValidating = ManifestValidator(),
         cache: ManifestCache = ManifestCache()) {
        self.session = session
        self.validator = validator
        self.cache = cache
        self.remoteURL = remoteURL
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func bootstrapManifest() -> HamsterManifest? {
        if let cached = cache.loadCachedManifest() {
            return cached.sortedByPopularity()
        }
        return cache.loadBundledSeed()?.sortedByPopularity()
    }

    func refreshManifest(completion: @escaping (Result<HamsterManifest, ManifestError>) -> Void) {
        var request = URLRequest(url: remoteURL)
        request.timeoutInterval = AppConfiguration.manifestRequestTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.notFound))
                }
                return
            }
            do {
                guard let self else { return }
                let manifest = try self.decoder.decode(HamsterManifest.self, from: data)
                try self.validator.validate(manifest)
                let sorted = manifest.sortedByPopularity()
                self.cache.save(manifest: sorted)
                DispatchQueue.main.async {
                    completion(.success(sorted))
                }
            } catch let error as ManifestError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed))
                }
            }
        }
        task.resume()
    }
}
