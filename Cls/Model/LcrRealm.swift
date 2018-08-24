//
//  LcRealm
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import RealmSwift

let DB = LcRealm.shared

class LcRealm {
    public static let shared = LcRealm()
    public var realm: Realm!
    init() {
        do {
            realm = try Realm()
        } catch let error as NSError {
            print(error)
        }
    }
    
    class func begin() {
        LcRealm.shared.realm.beginWrite()
    }
    class func commit() {
        try! LcRealm.shared.realm.commitWrite()
    }

    
    func jobs(withId id: Int = 0) -> Results<TblJob>! {
        let filter = (id > 0) ? "jobId = \(id)" : "jobId > 0"
        return realm.objects(TblJob.self).filter(filter)
    }

    func clearAll() {
        try! realm.write {
            realm.deleteAll()
        }
        return
    }

    func setKpiToValid() {
        let kpis = realm.objects(TblJobKpi.self).filter("isValid = %@", false)
        if kpis.count == 0 {
            return
        }
        do {
            try realm.write {
                let kpi = kpis.first!
                kpi.isValid = true
                realm.add(kpi, update: true)
            }
        } catch {
            print("Could not write to database: ", error)
        }
    }
    
    func addJob(withDict dict: JsonDict) {
        let tblJpb = TblJob()
        
        tblJpb.jobId = dict.int("id")
        tblJpb.reference = dict.string("reference")
        if tblJpb.reference.isEmpty {
            tblJpb.reference = dict.string("id")
        }
        tblJpb.irregular = dict.bool("irregular")  // Boolean [0/1]
        
        tblJpb._description = dict.string("description")
        tblJpb.additional_description = dict.string("additional_description")
        tblJpb.details = dict.string("details")
        tblJpb.start_date = dict.date("start_date", fmt: Config.DateFmt.DataJson)
        tblJpb.end_date = dict.date("end_date", fmt: Config.DateFmt.DataJson)
        tblJpb.estimate_date = dict.date("estimate_date", fmt: Config.DateFmt.DataJson)
        
        tblJpb.fee_desc = dict.string("fee_desc")
        tblJpb.status = dict.string("status")
        tblJpb.booking_date = dict.date("booking_date", fmt: Config.DateFmt.DataOraJson)
        tblJpb.notes = dict.string("notes")
        tblJpb.execution_date = dict.date("execution_date", fmt: Config.DateFmt.DataJson)
        tblJpb.execution_start_time = dict.string("execution_start_time") // Time [hh:mm]
        tblJpb.execution_end_time = dict.string("execution_end_time") // Time [hh:mm]
        tblJpb.comment = dict.string("comment")
        tblJpb.comment_min = dict.int("comment_min")
        tblJpb.comment_max = dict.int("comment_max")
        tblJpb.learning_done = dict.bool("learning_done") // Boolean [0/1]
        tblJpb.learning_url = dict.string("learning_url")
        tblJpb.store_closed = dict.bool("store_closed") // Boolean [0/1]
        
        let store = dict.dictionary("store")
        tblJpb.store_name = store.string("name")
        tblJpb.store_type = store.string("type")
        tblJpb.store_address = store.string("address")
        tblJpb.store_latitude = store.double("latitude")
        tblJpb.store_longitude = store.double("longitude")
        
        let positioning = dict.dictionary("positioning")
        tblJpb.pos_required = positioning.bool("required") // Boolean [0/1]
        tblJpb.pos_start = positioning.bool("start") // Boolean [0/1]
        tblJpb.pos_start_date = positioning.string("start_date") // [aaaa-mm-dd hh:mm:ss]
        tblJpb.pos_start_lat = positioning.double("start_lat")
        tblJpb.pos_start_lng = positioning.double("start_lng")
        tblJpb.pos_end = positioning.bool("required") // Boolean [0/1]
        tblJpb.pos_end_date = positioning.string("end_date") // [aaaa-mm-dd hh:mm:ss]
        tblJpb.pos_end_lat = positioning.double("end_lat")
        tblJpb.pos_end_lng = positioning.double("end_lng")
        
        for attachment in dict.array("attachments") as! [JsonDict] {
            let att = TblJobAttachment()
            att.jobId = tblJpb.jobId
            att.id = attachment.int("id")
            att.name = attachment.string("name")
            att.filename = attachment.string("filename")
            att.url = attachment.string("url")
            tblJpb.attachments.append(att)
        }
        
        func kpiWithDict (_ dict: JsonDict) -> TblJobKpi {
            let jobKpi = TblJobKpi()
            jobKpi.jobId = tblJpb.jobId
            jobKpi.id = dict.int("id")
            jobKpi.name = dict.string("name")
            jobKpi.section = dict.int("section") //  Boolean [0/1]
            jobKpi.note = dict.string("note")
            jobKpi.section_id = dict.int("section_id")
            jobKpi.required = dict.bool("required") // Boolean [0/1]
            jobKpi.note_required = dict.bool("note_required") // Boolean [0/1]
            jobKpi.note_error_message = dict.string("note_error_message")
            jobKpi.attachment = dict.bool("attachment") // Boolean [0/1]
            jobKpi.attachment_required = dict.bool("attachment_required") // Boolean [0/1]
            jobKpi.attachment_error_message = dict.string("attachment_error_message")
            jobKpi.type = dict.string("type")
            jobKpi.order = dict.int("order")
            jobKpi.factor = dict.string("factor")
            jobKpi.service = dict.string("service")
            jobKpi.standard = dict.string("standard")
            jobKpi.instructions = dict.string("instructions")
            
            let result = dict.dictionary("result")
            jobKpi.result_id = result.int("id")
            jobKpi.result_value = result.string("value")
            jobKpi.result_notes = result.string("notes")
            jobKpi.result_attachment = result.string("attachment")
            jobKpi.result_url = result.string("url")
            jobKpi.result_irregular = result.bool("irregular")
            jobKpi.result_irregular_note = result.string("irregular_note")

            for valutation in dict.array("valuations") as! [JsonDict] {
                let val = TblJobKpiValuation()
                val.id = valutation.int("id")
                val.name = valutation.string("name")
                val.order = valutation.int("order")
                val.positive = valutation.bool("positive") // Boolean [0/1]
                val.note_required = valutation.bool("note_required") // Boolean [0/1]
                val.attachment_required = valutation.bool("attachment_required") // Boolean [0/1]
                
                for dependency in valutation.array("dependencies") as! [JsonDict] {
                    let dep = TblJobKpiValDependency()
                    dep.jobId = tblJpb.jobId
                    dep.key = dependency.int("key")
                    dep.value = dependency.string("value")
                    dep.notes = dependency.string("notes")
                    val.dependencies.append(dep)
                }
                val.jobId = tblJpb.jobId
                val.key = "\(jobKpi.result_id ).\(val.id)"
                jobKpi.valuations.append(val)
            }
            return jobKpi
        }
        
        for kpi in dict.array("kpis") as! [JsonDict] {
            tblJpb.kpis.append(kpiWithDict(kpi))
        }

        do {
            try realm.write {
                realm.add(tblJpb, update: true)
            }
        } catch {
            print("Could not write to database: ", error)
        }

        MYJob.current = tblJpb
    }
}

