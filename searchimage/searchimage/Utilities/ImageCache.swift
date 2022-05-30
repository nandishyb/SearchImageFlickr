//
//  ImageCache.swift
//  searchimage
//
//  Created by Nandish Bellad on 30/05/2022.
//

import Foundation
import UIKit.UIImage
import Combine
import UIKit

public protocol ImageCacheType : AnyObject {
    func image(for url : URL) -> UIImage?
    func insertImage(_ image: UIImage?, for url : URL)
    func removeImage(for url : URL)
    func removeAllImages()
    subscript(_ url : URL) -> UIImage? { get set }
}

public final class ImageCache : ImageCacheType {
    
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject,AnyObject>()
        cache.totalCostLimit = config.memoryLimit
        return cache
    }()
    
    private let lock = NSLock()
    private let config: Config
    
    public struct Config {
        public let countLimit: Int
        public let memoryLimit: Int
        
        public static let defaultConfig = Config(countLimit: 30, memoryLimit: 1024 * 1024 * 100) // 100 MB
    }
    
    public init(config: Config = Config.defaultConfig) {
        self.config = config
    }
    
    public func image(for url: URL) -> UIImage? {
        lock.lock(); defer { lock.unlock() }
        //Search for image data
        if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
            return image
        }
        return nil
    }
    
    public func insertImage(_ image: UIImage?, for url: URL) {
        guard let image = image else {
            return removeImage(for: url)
        }
        lock.lock(); defer { lock.unlock() }
        imageCache.setObject(image, forKey: url as AnyObject, cost: 1)
    }
    
    public func removeImage(for url: URL) {
        lock.lock(); defer { lock.unlock() }
        imageCache.removeObject(forKey: url as AnyObject)
    }
    
    public func removeAllImages() {
        lock.lock(); defer { lock.unlock() }
        imageCache.removeAllObjects()
    }
    
    public subscript(url: URL) -> UIImage? {
        get {
            return image(for: url)
        }
        set {
            return insertImage(newValue, for: url)
        }
    }
}

public final class ImageLoader {
    public static let shared = ImageLoader()
    
    private let cache:ImageCacheType
    private lazy var backgroundQueue : OperationQueue = {
       let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
    
    public init(cache: ImageCacheType = ImageCache()) {
        self.cache = cache
    }
    
    public func loadImage(from url : URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cache[url] {
            return Just(image).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data , response) -> UIImage? in return UIImage(data: data)?.imageResized(to: CGSize(width: 200, height: 200)) }
            .catch { error in return Just(nil) }
            .handleEvents(receiveOutput: {[unowned self] image in
                guard let image = image else { return }
                self.cache[url] = image
            })
            .print("Image loading \(url):")
            .subscribe(on: backgroundQueue)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
