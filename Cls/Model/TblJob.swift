//
//  JobStruct.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import RealmSwift

class TblJob: Object {
    override static func primaryKey() -> String? {
        return "jobId"
    }
    @objc dynamic var jobId = 0
    @objc dynamic var reference = ""
    @objc dynamic var _description = ""
    @objc dynamic var additional_description = ""
    @objc dynamic var details = ""
    @objc dynamic var start_date: Date!     // Date [aaaa-mm-dd]
    @objc dynamic var end_date: Date!       // Date [aaaa-mm-dd]
    @objc dynamic var estimate_date: Date!  // Date [aaaa-mm-dd]
    @objc dynamic var fee_desc = ""
    @objc dynamic var status = ""
    @objc dynamic var booking_date: Date!   // Date and Time [aaaa-mm-dd hh:mm:ss]
    @objc dynamic var irregular = false
    @objc dynamic var notes = ""
    @objc dynamic var execution_date: Date?         // Date [aaaa-mm-dd]
    @objc dynamic var execution_start_time = ""     // Time [hh:mm]
    @objc dynamic var execution_end_time = ""       // Time [hh:mm]
    @objc dynamic var comment = ""
    @objc dynamic var comment_min = 0
    @objc dynamic var comment_max = 0
    @objc dynamic var learning_done = false
    @objc dynamic var learning_url = ""
    @objc dynamic var store_closed = false

    @objc dynamic var store_name = ""
    @objc dynamic var store_type = ""
    @objc dynamic var store_address = ""
    @objc dynamic var store_latitude: Double = 0
    @objc dynamic var store_longitude: Double = 0
    
    @objc dynamic var pos_required = false
    @objc dynamic var pos_start = false
    @objc dynamic var pos_start_date = ""   // [aaaa-mm-dd hh:mm:ss]
    @objc dynamic var pos_start_lat:Double = 0
    @objc dynamic var pos_start_lng:Double = 0
    @objc dynamic var pos_end = false
    @objc dynamic var pos_end_date = ""     // [aaaa-mm-dd hh:mm:ss]
    @objc dynamic var pos_end_lat:Double = 0
    @objc dynamic var pos_end_lng:Double = 0

    let attachments = List<TblJobAttachment>()
    let kpis = List<TblJobKpi>()
}

//MARK: -

class TblJobAttachment: Object  {
    @objc dynamic var jobId = 0
    override class func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var filename = ""
    @objc dynamic var name = ""
    @objc dynamic var url = ""
}

//MARK: -

class TblJobKpi: Object {
    @objc dynamic var jobId = 0
    @objc dynamic var isValid = true
    override class func primaryKey() -> String? {
        return "id"
    }

    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var section = 0
    @objc dynamic var section_id = 0
    @objc dynamic var required = false
    @objc dynamic var note = ""
    @objc dynamic var note_required = false
    @objc dynamic var note_error_message = ""
    @objc dynamic var attachment = false
    @objc dynamic var attachment_required = false
    @objc dynamic var attachment_error_message = ""
    @objc dynamic var type = ""
    @objc dynamic var order = 0
    @objc dynamic var factor = ""
    @objc dynamic var service = ""
    @objc dynamic var standard = ""
    @objc dynamic var instructions = ""
    let valuations = List<TblJobKpiValuation>()
    let result = List<TblJobKpiResult>()
}
class TblJobKpiValuation: Object {
    @objc dynamic var jobId = 0
    @objc dynamic var key = ""
    override class func primaryKey() -> String? {
        return "key"
    }
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var order = 0
    @objc dynamic var positive = false
    @objc dynamic var note_required = false
    @objc dynamic var attachment_required = false
    let dependencies = List<TblJobKpiValDependency>()
}
class TblJobKpiValDependency: Object {
    @objc dynamic var jobId = 0
    override class func primaryKey() -> String? {
        return "key"
    }

    @objc dynamic var key = 0
    @objc dynamic var value = ""
    @objc dynamic var notes = ""
}
class TblJobKpiResult: Object {
    @objc dynamic var jobId = 0
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id = 0
    @objc dynamic var value = ""
    @objc dynamic var notes = ""
    @objc dynamic var attachment = ""
    @objc dynamic var url = ""
    @objc dynamic var irregular = false
    @objc dynamic var irregular_note = ""
}
