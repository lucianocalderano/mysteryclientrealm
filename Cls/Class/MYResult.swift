//
//  MYResult.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

class MYResult {
    static var current = TblResult()
    
    class func createJson() -> JsonDict {
        var resultDict = JsonDict()
        var resultArray = [JsonDict]()

        let result = MYResult.current
        
        for kpiResult in result.results {
            let dict:JsonDict = [
                "kpi_id"     : kpiResult.kpi_id,
                "value"      : kpiResult.value,
                "notes"      : kpiResult.notes,
                "attachment" : kpiResult.attachment,
                ]
            resultArray.append(dict)
        }
        
        let dictPos:JsonDict = [
            "start"      : result.pos_start,
            "start_date" : result.pos_start_date,
            "start_lat"  : result.pos_start_lat,
            "start_lng"  : result.pos_start_lng,
            "end"        : result.pos_end,
            "end_date"   : result.pos_end_date,
            "end_lat"    : result.pos_end_lat,
            "end_lng"    : result.pos_end_lng,
            ]
        
        resultDict = [
            "id"                        : result.id,
            "estimate_date"             : result.estimate_date,
            "compiled"                  : result.compiled,
            "compilation_date"          : result.compilation_date,
            "updated"                   : result.updated,
            "update_date"               : result.update_date,
            "execution_date"            : result.execution_date,
            "execution_start_time"      : result.execution_start_time,
            "execution_end_time"        : result.execution_end_time,
            "store_closed"              : result.store_closed,
            "comment"                   : result.comment,
            "results"                   : resultArray,
            "positioning"               : dictPos
            ] as JsonDict
        return resultDict
    }
}

import RealmSwift

class TblResultUtil {
    
    class  func firstLoad () {
        let realm = LcRealm.shared.realm!
        do {
            try realm.write {
                MYResult.current.results.removeAll()
            }
        } catch {
            print("Could not write to database: ", error)
        }
        
        for jobKpi in MYJob.current.kpis {
            let listTblResultKpi = realm.objects(TblResultKpi.self).filter("kpi_id = \(jobKpi.result_id)")
            var tblResultKpi = TblResultKpi()
            if let tmp = listTblResultKpi.first {
                tblResultKpi = tmp
            }
            else {
                tblResultKpi.kpi_id = jobKpi.result_id
            }
            do {
                try realm.write {
                    MYResult.current.results.append(tblResultKpi)
                }
            } catch {
                print("Could not write to database: ", error)
            }
        }
    }
    
    class func removeResult (withId id: Int) {
        let realm = LcRealm.shared.realm!
        let kpiResult = realm.objects(TblResult.self).filter("id = \(id)")
        let tblResKpi = realm.objects(TblResultKpi.self).filter("jobId = \(id)")
        do {
            try realm.write {
                realm.delete(kpiResult)
                realm.delete(tblResKpi)
            }
        } catch {
            print("Could not write to database: ", error)
        }
    }
    
    class func saveResult (tblResultKpi: TblResultKpi) {
        let realm = LcRealm.shared.realm!
        do {
            try realm.write {
                realm.add(tblResultKpi, update: true)
            }
        } catch {
            print("Could not write to database: ", error)
        }
    }
    
    class func loadResult (withId id: Int) {
        let realm = LcRealm.shared.realm!
        let tblList = realm.objects(TblResult.self).filter("id = \(id)")
        if tblList.count == 0 {
            return
        }
        MYResult.current = tblList.first!
    }
    
    class func create() {
        let realm = LcRealm.shared.realm!
        let tblResultList = realm.objects(TblResult.self).filter("id = %@", MYJob.current.jobId)
        var tblResult = TblResult()
        if let tmp = tblResultList.first{
            tblResult = tmp
        }
        else {
            tblResult.id = MYJob.current.jobId
        }
        do {
            try realm.write {
                tblResult.pos_end = MYJob.current.pos_end
                tblResult.pos_end_date = MYJob.current.end_date.toString(withFormat: Config.DateFmt.DataJson)
                tblResult.pos_end_lat = MYJob.current.pos_end_lat
                tblResult.pos_end_lng = MYJob.current.pos_end_lng
                tblResult.pos_start_date = MYJob.current.start_date.toString(withFormat: Config.DateFmt.DataJson)
                tblResult.pos_start_lat = MYJob.current.pos_start_lat
                tblResult.pos_start_lng = MYJob.current.pos_start_lng
                realm.add(tblResult, update: true)
                
                for jobKpi in MYJob.current.kpis {
                    let resultKpi = TblResultKpi()
                    resultKpi.jobId = MYJob.current.jobId
                    resultKpi.kpi_id = jobKpi.result_id
                    resultKpi.value = jobKpi.result_value
                    resultKpi.notes = jobKpi.result_notes
                    resultKpi.attachment = jobKpi.result_attachment
                    tblResult.results.append(resultKpi)
                }
                MYResult.current = tblResult
            }
        } catch {
            print("Could not write to database: ", error)
        }
        
    }
}
