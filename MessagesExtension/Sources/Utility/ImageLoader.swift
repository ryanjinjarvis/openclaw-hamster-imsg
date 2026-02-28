import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    private let queue = DispatchQueue(label: "dev.openclaw.hamsterim.imageloader", qos: .userInitiated)
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func load(url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return
        }

        if url.scheme == "asset", let host = url.host, let image = UIImage(named: host) {
            cache.setObject(image, forKey: url as NSURL)
            completion(image)
            return
        }

        queue.async {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
            let task = self.session.dataTask(with: request) { data, _, error in
                guard error == nil, let data = data, let image = UIImage(data: data) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                self.cache.setObject(image, forKey: url as NSURL)
                DispatchQueue.main.async { completion(image) }
            }
            task.resume()
        }
    }
}
