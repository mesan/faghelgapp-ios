class TokenUtil {
    
    class func getUsernameFromToken(token: String) -> String? {
        
        //splitting JWT to extract payload
        let arr = split(token) {$0 == "."}

        var base64String = arr[1] as String
        if countElements(base64String) % 4 != 0 {
            let padlen = 4 - countElements(base64String) % 4
            base64String += String(count: padlen, repeatedValue: Character("="))
        }
        
        if let data = NSData(base64EncodedString: base64String, options: nil) {
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)!
            
            var error : NSError?
            let JSONData = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            let JSONDictionary: Dictionary = NSJSONSerialization.JSONObjectWithData(JSONData!, options: nil, error: &error) as NSDictionary

            var unique_name = JSONDictionary["unique_name"] as String
            var username = split(unique_name) {$0 == "@"}[0]
            
            return username
        }
        
        return nil
        
    }
}
