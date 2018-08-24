//
//  MYResult.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

class MYResult {
    class func createJson() -> JsonDict {
        var resultDict = JsonDict()
        var resultArray = [JsonDict]()
        let result = Current.result
        
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
    class func firstLoad () {
        let realm = LcRealm.shared.realm!
        do {
            try realm.write {
                Current.result.results.removeAll()
            }
        } catch {
            print("Could not write to database: ", error)
        }
        
        for jobKpi in Current.job.kpis {
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
                    Current.result.results.append(tblResultKpi)
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
    
    class func loadCurrent () -> TblResult {
        let realm = LcRealm.shared.realm!
        let tblList = realm.objects(TblResult.self).filter("id = \(Current.job.jobId)")
        if tblList.count == 0 {
            return TblResult()
        }
        return tblList.first!
    }
    
    class func createCurrent() -> TblResult {
        let realm = LcRealm.shared.realm!
        let tblResultList = realm.objects(TblResult.self).filter("id = %@", Current.job.jobId)
        var tblResult = TblResult()
        if let tmp = tblResultList.first{
            tblResult = tmp
        }
        else {
            tblResult.id = Current.job.jobId
        }
        do {
            try realm.write {
                tblResult.pos_end = Current.job.pos_end
                tblResult.pos_end_date = Current.job.end_date.toString(withFormat: Config.DateFmt.DataJson)
                tblResult.pos_end_lat = Current.job.pos_end_lat
                tblResult.pos_end_lng = Current.job.pos_end_lng
                tblResult.pos_start_date = Current.job.start_date.toString(withFormat: Config.DateFmt.DataJson)
                tblResult.pos_start_lat = Current.job.pos_start_lat
                tblResult.pos_start_lng = Current.job.pos_start_lng
                realm.add(tblResult, update: true)
                
                for jobKpi in Current.job.kpis {
                    let resultKpi = TblResultKpi()
                    resultKpi.jobId = Current.job.jobId
                    resultKpi.kpi_id = jobKpi.result_id
                    resultKpi.value = jobKpi.result_value
                    resultKpi.notes = jobKpi.result_notes
                    resultKpi.attachment = jobKpi.result_attachment
                    tblResult.results.append(resultKpi)
                }
                Current.result = tblResult
            }
        } catch {
            print("Could not write to database: ", error)
        }
        return tblResult
    }
}
