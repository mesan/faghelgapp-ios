class Message {
    var title: String?
    var content: String?
    var sender: String?
    var timestamp: String?
    
    init(title: String, content: String, sender: String, timestamp: String) {
        self.title = title
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}