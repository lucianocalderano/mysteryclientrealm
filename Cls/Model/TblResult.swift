//
//  ResultStruct.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import RealmSwift

class TblResult: Object {
    override class func primaryKey() -> String? {
        return "id"
    }

    @objc dynamic var id = 0
    @objc dynamic var estimate_date = ""              // [aaaa-mm-dd]
    @objc dynamic var compiled = false                // Boolean [0/1]
    @objc dynamic var compilation_date = ""           // [aaaa-mm-dd hh:mm:ss]
    @objc dynamic var updated = false                 // Boolean [0/1]
    @objc dynamic var update_date = ""                // [aaaa-mm-dd hh:mm:ss]
    @objc dynamic var execution_date = ""             // [aaaa-mm-dd]
    @objc dynamic var execution_start_time = ""       // [hh:mm]
    @objc dynamic var execution_end_time = ""         // [hh:mm]
    @objc dynamic var store_closed = false            // Boolean [0/1]
    @objc dynamic var comment = ""
    let results = List<TblResultKpi>()
    let positioning = List<TblResultPos>()
}

class TblResultKpi: Object {
    override class func primaryKey() -> String? {
        return "kpi_id"
    }
    @objc dynamic var kpi_id = 0
    @objc dynamic var value = ""
    @objc dynamic var notes = ""
    @objc dynamic var attachment = ""
}

class TblResultPos: Object  {
    @objc dynamic var key = 0
    override class func primaryKey() -> String? {
        return "key"
    }
    @objc dynamic var start = false
    @objc dynamic var start_date = ""     // [aaaa-mm-dd hh:mm:ss]
    @objc dynamic var start_lat:Double = 0
    @objc dynamic var start_lng:Double = 0
    @objc dynamic var end = false
    @objc dynamic var end_date = ""       // [aaaa-mm-dd hh:mm:ss]
    @objc dynamic var end_lat:Double = 0
    @objc dynamic var end_lng:Double = 0
}

