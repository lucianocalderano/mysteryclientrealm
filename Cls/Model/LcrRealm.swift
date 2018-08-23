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
    
    func incarichi(_ filter: String = "") -> Results<TblJob>! {
        if filter.isEmpty {
            return realm.objects(TblJob.self)
        }
        else {
            return realm.objects(TblJob.self).filter(filter)
        }
    }

    func write(_ obj: Object){
        try! realm.write {
            realm.add(obj, update: true)
        }
    }
    
    func incarichiClear(_ filter: String = "") {
        let result = incarichi(filter)!
        try! realm!.write {
            realm!.delete(result)
        }
    }
    
    func kpisReset() {
        let kpis = realm.objects(TblJobKpi.self).filter("isValid = %@", false)
        if kpis.count > 0 {
            try! realm.write {
                kpis.first!.isValid = true
            }
        }
    }
    
    func incaricoAdd(withDict dict: JsonDict) {
        let incarico = TblJob()
        
        incarico.id = dict.int("id")
        incarico.reference = dict.string("reference")
        if incarico.reference.isEmpty {
            incarico.reference = dict.string("id")
        }
        incarico.irregular = dict.bool("irregular")  // Boolean [0/1]
        
        incarico._description = dict.string("description")
        incarico.additional_description = dict.string("additional_description")
        incarico.details = dict.string("details")
        incarico.start_date = dict.date("start_date", fmt: Config.DateFmt.DataJson)
        incarico.end_date = dict.date("end_date", fmt: Config.DateFmt.DataJson)
        incarico.estimate_date = dict.date("estimate_date", fmt: Config.DateFmt.DataJson)
        
        incarico.fee_desc = dict.string("fee_desc")
        incarico.status = dict.string("status")
        incarico.booking_date = dict.date("booking_date", fmt: Config.DateFmt.DataOraJson)
        incarico.notes = dict.string("notes")
        incarico.execution_date = dict.date("execution_date", fmt: Config.DateFmt.DataJson)
        incarico.execution_start_time = dict.string("execution_start_time") // Time [hh:mm]
        incarico.execution_end_time = dict.string("execution_end_time") // Time [hh:mm]
        incarico.comment = dict.string("comment")
        incarico.comment_min = dict.int("comment_min")
        incarico.comment_max = dict.int("comment_max")
        incarico.learning_done = dict.bool("learning_done") // Boolean [0/1]
        incarico.learning_url = dict.string("learning_url")
        incarico.store_closed = dict.bool("store_closed") // Boolean [0/1]
        
        let store = dict.dictionary("store")
        let incStore = TblJobStore()
        incStore.key = incarico.id
        incStore.name = store.string("name")
        incStore.type = store.string("type")
        incStore.address = store.string("address")
        incStore.latitude = store.double("latitude")
        incStore.longitude = store.double("longitude")
        incarico.store.append(incStore)
        
        let positioning = dict.dictionary("positioning")
        let incPositioning = TblJobPositioning()
        incPositioning.key = incarico.id
        incPositioning.required = positioning.bool("required") // Boolean [0/1]
        incPositioning.start = positioning.bool("start") // Boolean [0/1]
        incPositioning.start_date = positioning.string("start_date") // [aaaa-mm-dd hh:mm:ss]
        incPositioning.start_lat = positioning.double("start_lat")
        incPositioning.start_lng = positioning.double("start_lng")
        incPositioning.end = positioning.bool("required") // Boolean [0/1]
        incPositioning.end_date = positioning.string("end_date") // [aaaa-mm-dd hh:mm:ss]
        incPositioning.end_lat = positioning.double("end_lat")
        incPositioning.end_lng = positioning.double("end_lng")
        incarico.positioning.append(incPositioning)
        
        for attachment in dict.array("attachments") as! [JsonDict] {
            let att = TblJobAttachment()
            att.id = attachment.int("id")
            att.name = attachment.string("name")
            att.filename = attachment.string("filename")
            att.url = attachment.string("url")
            incarico.attachments.append(att)
        }
        
        func updateKpisWithDict (_ dict: JsonDict) -> List<TblJobKpi> {
            let array = List<TblJobKpi>()
            let kpis = dict.array("kpis") as! [JsonDict]
            for kpiDict in kpis {
                let incKpi = TblJobKpi()
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
                    val.id = valutation.int("id")
                    val.name = valutation.string("name")
                    val.order = valutation.int("order")
                    val.positive = valutation.bool("positive") // Boolean [0/1]
                    val.note_required = valutation.bool("note_required") // Boolean [0/1]
                    val.attachment_required = valutation.bool("attachment_required") // Boolean [0/1]

                    for dependency in valutation.array("dependencies") as! [JsonDict] {
                        let dep = TblJobKpiValDependency()
                        dep.key = dependency.int("key")
                        dep.value = dependency.string("value")
                        dep.notes = dependency.string("notes")
                        val.dependencies.append(dep)
                    }
                    val.key = "\(incarico.id).\(incKpi.id).\(val.id)"
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
        
        incarico.kpis = updateKpisWithDict(dict)
        DB.write(incarico)
//        let incarichi = Db.incarichi()
        
        MYJob.current = incarico
    }
}

