//
//  JobStruct.swift
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
    
    func jobs(withId id: Int = 0) -> Results<TblJob>! {
        let filter = (id > 0) ? "jobId = \(id)" : "jobId > 0"
        return realm.objects(TblJob.self).filter(filter)
    }

//    func write(_ obj: Object){
//        do {
//            try realm.write {
//                realm.add(obj, update: true)
//            }
//        } catch {
//            print("Could not write to database: ", error)
//        }
//    }
    
    func jobClear(_ id: Int = 0) {
        let filter = (id > 0) ? "jobId = \(id)" : "jobId > 0"
        
        let tblJob = realm.objects(TblJob.self).filter(filter)
        let tblJobSto = realm.objects(TblJobStore.self).filter(filter)
        let tblJobAtt = realm.objects(TblJobAttachment.self).filter(filter)
        let tblJobDep = realm.objects(TblJobKpiValDependency.self).filter(filter)
        let tblJobKpi = realm.objects(TblJobKpi.self).filter(filter)
        let tblJobKpiRes = realm.objects(TblJobKpiResult.self).filter(filter)
        let tblJobKpiVal = realm.objects(TblJobKpiValuation.self).filter(filter)
        let tblJobKpiValDep = realm.objects(TblJobKpiValDependency.self).filter(filter)
        
        do {
            try realm.write {
                realm.delete(tblJob)
                realm.delete(tblJobAtt)
                realm.delete(tblJobDep)
                realm.delete(tblJobSto)
                realm.delete(tblJobKpi)
                realm.delete(tblJobKpiRes)
                realm.delete(tblJobKpiVal)
                realm.delete(tblJobKpiValDep)
            }
        } catch {
            print("Could not write to database: ", error)
        }
    }
    
    func kpisReset() {
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
        let incStore = TblJobStore()
        incStore.jobId = tblJpb.jobId
        incStore.name = store.string("name")
        incStore.type = store.string("type")
        incStore.address = store.string("address")
        incStore.latitude = store.double("latitude")
        incStore.longitude = store.double("longitude")
        tblJpb.store.append(incStore)
        
        let positioning = dict.dictionary("positioning")
        let incPositioning = TblJobPositioning()
        incPositioning.jobId = tblJpb.jobId
        incPositioning.required = positioning.bool("required") // Boolean [0/1]
        incPositioning.start = positioning.bool("start") // Boolean [0/1]
        incPositioning.start_date = positioning.string("start_date") // [aaaa-mm-dd hh:mm:ss]
        incPositioning.start_lat = positioning.double("start_lat")
        incPositioning.start_lng = positioning.double("start_lng")
        incPositioning.end = positioning.bool("required") // Boolean [0/1]
        incPositioning.end_date = positioning.string("end_date") // [aaaa-mm-dd hh:mm:ss]
        incPositioning.end_lat = positioning.double("end_lat")
        incPositioning.end_lng = positioning.double("end_lng")
        tblJpb.positioning.append(incPositioning)
        
        for attachment in dict.array("attachments") as! [JsonDict] {
            let att = TblJobAttachment()
            att.jobId = tblJpb.jobId
            att.id = attachment.int("id")
            att.name = attachment.string("name")
            att.filename = attachment.string("filename")
            att.url = attachment.string("url")
            tblJpb.attachments.append(att)
        }
        
        func updateKpisWithDict (_ dict: JsonDict) -> List<TblJobKpi> {
            let array = List<TblJobKpi>()
            let kpis = dict.array("kpis") as! [JsonDict]
            for kpiDict in kpis {
                let incKpi = TblJobKpi()
                incKpi.jobId = tblJpb.jobId
                incKpi.id = kpiDict.int("id")
                incKpi.name = kpiDict.string("name")
                incKpi.section = kpiDict.int("section") //  Boolean [0/1]
                incKpi.note = kpiDict.string("note")
                incKpi.section_id = kpiDict.int("section_id")
                incKpi.required = kpiDict.bool("required") // Boolean [0/1]
                incKpi.note_required = kpiDict.bool("note_required") // Boolean [0/1]
                incKpi.note_error_message = kpiDict.string("note_error_message")
                incKpi.attachment = kpiDict.bool("attachment") // Boolean [0/1]
                incKpi.attachment_required = kpiDict.bool("attachment_required") // Boolean [0/1]
                incKpi.attachment_error_message = kpiDict.string("attachment_error_message")
                incKpi.type = kpiDict.string("type")
                incKpi.order = kpiDict.int("order")
                incKpi.factor = kpiDict.string("factor")
                incKpi.service = kpiDict.string("service")
                incKpi.standard = kpiDict.string("standard")
                incKpi.instructions = kpiDict.string("instructions")
                
                for valutation in kpiDict.array("valuations") as! [JsonDict] {
                    let val = TblJobKpiValuation()
                    val.jobId = tblJpb.jobId
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
                    val.key = "\(tblJpb.jobId).\(incKpi.id).\(val.id)"
                    incKpi.valuations.append(val)
                }
                
                let result = kpiDict.dictionary("result")
                let incResult = TblJobKpiResult();
                incResult.id = result.int("id")
                incResult.value = result.string("value")
                incResult.notes = result.string("notes")
                incResult.attachment = result.string("attachment")
                incResult.url = result.string("url")
                incResult.irregular = result.bool("irregular")
                incResult.irregular_note = result.string("irregular_note")
                incKpi.result.append((incResult))
                array.append(incKpi)
            }
            return array
        }
        
        tblJpb.kpis = updateKpisWithDict(dict)
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

