
import Foundation

public extension Dictionary {
    func getVal(_ keys: String) -> Any? {
        let array = keys.components(separatedBy: ".")

        var dic = self as Dictionary<Key, Value>
        for key in array.dropLast() {
            guard let next = dic[key as! Key] else {
                return nil
            }
            guard next is Dictionary<Key, Value> else {
                return nil
            }
            
            dic = next as! Dictionary<Key, Value>
        }
        
        guard let value = dic[array.last! as! Key] else {
            return nil
        }
        
        if value is String {
            return value as! String
        }
        if value is Array<Any> {
            return value as! Array<Any>
        }
        if value is Dictionary {
            return value as! Dictionary
        }
        if value is Double {
            return String (describing: value)
        }
        if value is Bool {
            return String (describing: value)
        }
        return nil
    }

    func double (_ key: String) -> Double {
        guard let ret = self.getVal(key) as? String else {
            return 0
        }
        if ret.count == 0 {
            return 0
        }
        return Double(ret)!
    }

    func int (_ key: String) -> Int {
        guard let ret = self.getVal(key) as? String else {
            return 0
        }
        if ret.count == 0 {
            return 0
        }
        return Int(ret)!
    }
    
    func string (_ key: String) -> String {
        guard let ret = self.getVal(key) as? String else {
            return ""
        }
        return ret
    }
    
    func dictionary(_ key: String) -> Dictionary<Key, Value> {
        guard let ret = self.getVal(key) as? Dictionary<Key, Value> else {
            return [:]
        }
        return ret
    }
    
    func array(_ key: String) -> Array<Any> {
        guard let ret = self.getVal(key) as? Array<Any> else {
            return []
        }
        return ret
    }
    
    func bool (_ key: String) -> Bool {
        guard let ret = self.getVal(key) as? String else {
            return false
        }
        return ret == "1"
    }
    
    func date (_ key: String, fmt: String) -> Date? {
        guard let ret = self.getVal(key) as? String else {
            return Date.init(timeIntervalSince1970: 0)
        }
        if ret.isEmpty {
            return nil
        }
        let d = ret.toDate(withFormat: fmt)
        return d
    }
}

