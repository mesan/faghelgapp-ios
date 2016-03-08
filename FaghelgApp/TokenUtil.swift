class TokenUtil {
    
    class func getUsernameFromToken(token: String) -> String? {
        
        //splitting JWT to extract payload
        let arr = token.characters.split {$0 == "."}.map { String($0) }

        var base64String = arr[1] as String
        if base64String.characters.count % 4 != 0 {
            let padlen = 4 - base64String.characters.count % 4
            base64String += String(count: padlen, repeatedValue: Character("="))
        }
        
        if let data = NSData(base64EncodedString: base64String, options: []) {
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)!
            
            var error : NSError?
            let JSONData = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            let JSONDictionary: Dictionary = (try! NSJSONSerialization.JSONObjectWithData(JSONData!, options: [])) as! [String: AnyObject]

            let unique_name = JSONDictionary["unique_name"] as! String
            let username = unique_name.characters.split {$0 == "@"}.map { String($0) }[0]
            
            return username
        }
        
        return nil
        
    }
}
