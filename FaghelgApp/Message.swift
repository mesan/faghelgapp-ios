class Message {
    var content: String?
    var sender: String?
    var timestamp: String?
    
    init(content: String, sender: String, timestamp: String) {
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
    
}