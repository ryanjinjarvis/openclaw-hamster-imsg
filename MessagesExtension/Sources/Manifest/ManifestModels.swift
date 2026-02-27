import Foundation

struct HamsterManifest: Codable {
    let version: String
    let generatedAt: Date
    let items: [HamsterItem]

    func sortedByPopularity() -> HamsterManifest {
        let sortedItems = items.sorted { lhs, rhs in
            if lhs.popularity == rhs.popularity {
                return lhs.createdAt > rhs.createdAt
            }
            return lhs.popularity > rhs.popularity
        }
        return HamsterManifest(version: version, generatedAt: generatedAt, items: sortedItems)
    }
}

struct HamsterItem: Codable, Hashable {
    let id: String
    let imageUrl: URL
    let thumbnailUrl: URL
    let tags: [String]
    let popularity: Int
    let createdAt: Date
    let source: HamsterSource

    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let lowercased = query.lowercased()
        if id.lowercased().contains(lowercased) { return true }
        if tags.contains(where: { $0.lowercased().contains(lowercased) }) { return true }
        if source.account.lowercased().contains(lowercased) { return true }
        if source.platform.lowercased().contains(lowercased) { return true }
        return false
    }
}

struct HamsterSource: Codable, Hashable {
    let platform: String
    let account: String
    let postId: String
}

enum ManifestError: Error {
    case decodingFailed
    case validationFailed(String)
    case networkError(Error)
    case notFound
}
