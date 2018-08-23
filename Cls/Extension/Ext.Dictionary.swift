
import Foundation

extension Dictionary {
    //MARK:- Disk utility
    
    init (fromFile: String) {
        self.init()
        do {
            let url = URL.init(string: fromFile)
            let data = try Data.init(contentsOf:url!)//
            
            let dict = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as! Dictionary<Key, Value>
            for key in dict.keys {
                self[key] = dict[key]
            }
        }
        catch let error as NSError {
            print("Error creating Dictionary: \(error.localizedDescription)")
        }
    }
    
    func saveToFile(_ file: String) -> Bool {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: self,
                                                          format: .binary,
                                                          options: 0)
            try data.write(to: URL.init(fileURLWithPath: file))
            return true
        }
        catch let error as NSError {
            fatalError("Error creating directory: \(error.localizedDescription)")
        }
        return false
    }
    
//    init (fromFile: String) {
//        self.init()
//        guard FileManager.default.fileExists(atPath: fromFile) else {
//            return
//        }
//        do {
//            let url = URL.init(fileURLWithPath: fromFile)
//            let data = try Data.init(contentsOf:url)
//            var s = String.init(data: data, encoding: .utf8)
//            s = s?.replacingOccurrences(of: "\n", with: "")
//            s = s?.replacingOccurrences(of: "\\", with: "")
//            
//            var dict = Dictionary<Key, Value>()
//            if let data = s?.data(using: .utf8) {
//                do {
//                    dict = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<Key, Value>
//                } catch {
//                    print(error.localizedDescription)
//                }
//            }
//            //            let dict = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as! Dictionary<Key, Value>
//            for key in dict.keys {
//                self[key] = dict[key]
//            }
//        }
//        catch let error as NSError {
//            print("Error creating Dictionary: \(error.localizedDescription)")
//        }
//    }

}

