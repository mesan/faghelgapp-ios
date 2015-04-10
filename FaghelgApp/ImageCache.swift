class ImageCache {
    static let sharedInstance = ImageCache()
    
    var images = [String: UIImage]()
}
