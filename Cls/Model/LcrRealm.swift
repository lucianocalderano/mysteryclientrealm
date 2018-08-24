//
//  LcRealm
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import RealmSwift

class Current {
    public static var job: TblJob!
    public static var result = TblResult()
}

class LcRealm {
    public static let shared = LcRealm()
    public var realm: Realm!
    init() {
        do {
            realm = try Realm()
        } catch let error as NSError {
            assertionFailure("Realm error: \(error)")
        }
    }
    
    class func begin() {
        LcRealm.shared.realm.beginWrite()
    }
    class func commit() {
        try! LcRealm.shared.realm.commitWrite()
    }
    func clearAll() {
        try! realm.write {
            realm.deleteAll()
        }
        return
    }

}

