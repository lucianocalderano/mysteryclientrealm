//
//  MYResult.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

class MYResult {
    static let shared = MYResult()
    static var current = JobResult()
    
    var resultDict = JsonDict()
    
    func getFileName (withId id: Int) -> String {
        return Config.Path.result + "\(id)." + Config.File.plist
    }
    
    func loadResult (jobId id: Int) -> JobResult {
        var result = JobResult()
        for kpi in MYJob.current.kpis {
            let kpiResult = JobResult.KpiResult();
            if let jobResult = kpi.result.first {
                kpiResult.kpi_id = jobResult.id
                kpiResult.attachment = jobResult.attachment
                kpiResult.notes = jobResult.notes
                kpiResult.value = jobResult.value
            }
            result.results.append(kpiResult)
        }
        let dict = JsonDict.init(fromFile: Config.File.urlPrefix + getFileName(withId: id))
        if dict.isEmpty {
            result.id = id
            return result
        }
        return resultWithDict(dict)
    }
    
    func resultWithDict(_ dict: JsonDict) -> JobResult {
        var result = JobResult()
        result.id                     = dict.int("id")
        result.estimate_date          = dict.string("estimate_date")
        result.compiled               = dict.int("compiled")
        result.compilation_date       = dict.string("compilation_date")
        result.updated                = dict.int("updated")
        result.update_date            = dict.string("update_date")
        result.execution_date         = dict.string("execution_date")
        result.execution_start_time   = dict.string("execution_start_time")
        result.execution_end_time     = dict.string("execution_end_time")
        result.store_closed           = dict.int("store_closed")
        result.comment                = dict.string("comment")
        
        let pos = dict.dictionary("positioning")
        result.positioning.start      = pos.bool("start")
        result.positioning.start_date = pos.string("start_date")
        result.positioning.start_lat  = pos.double("start_lat")
        result.positioning.start_lng  = pos.double("start_lng")
        result.positioning.end        = pos.bool("end")
        result.positioning.end_date   = pos.string("end_date")
        result.positioning.end_lat    = pos.double("end_lat")
        result.positioning.end_lng    = pos.double("end_lng")
        
        for kpiDict in dict.array("results") as! [JsonDict] {
            let kpiResult = JobResult.KpiResult()
            kpiResult.kpi_id        = kpiDict.int("kpi_id")
            kpiResult.value         = kpiDict.string("value")
            kpiResult.notes         = kpiDict.string("notes")
            kpiResult.attachment    = kpiDict.string("attachment")
            result.results.append(kpiResult)
        }
        return result
    }
    
    func saveResult () {
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
            "start"      : result.positioning.start,
            "start_date" : result.positioning.start_date,
            "start_lat"  : result.positioning.start_lat,
            "start_lng"  : result.positioning.start_lng,
            "end"        : result.positioning.end,
            "end_date"   : result.positioning.end_date,
            "end_lat"    : result.positioning.end_lat,
            "end_lng"    : result.positioning.end_lng,
            ]
        
        self.resultDict = [
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
        _ = self.resultDict.saveToFile(self.getFileName(withId: result.id))
        TblResultUtil.saveDB()
    }
    
    func removeResultWithId (_ id: Int) {
        do {
            try? FileManager.default.removeItem(atPath: self.getFileName(withId: id))
        }
    }
    
}

import RealmSwift

class TblResultUtil {
    class func saveDB () {
        let result = MYResult.current
        let realm = LcRealm.shared.realm!
        var tbl = TblResult()
        let tblList = realm.objects(TblResult.self).filter("id = \(result.id)")
        if tblList.count > 0 {
            tbl = tblList.first!
        }
        else {
            tbl.id                        = result.id
        }
        do {
            try realm.write {
            tbl.estimate_date             = result.estimate_date
            tbl.compiled                  = result.compiled == 1
            tbl.compilation_date          = result.compilation_date
            tbl.updated                   = result.updated == 1
            tbl.update_date               = result.update_date
            tbl.execution_date            = result.execution_date
            tbl.execution_start_time      = result.execution_start_time
            tbl.execution_end_time        = result.execution_end_time
            tbl.store_closed              = result.store_closed == 1
            tbl.comment                   = result.comment
            
            realm.add(tbl, update: true)
            }
        } catch {
            print("Could not write to database: ", error)
        }

        for r in result.results {
            let tblList = realm.objects(TblResultKpi.self).filter("kpi_id = \(r.kpi_id)")

            var kpiResult = TblResultKpi()
            if tblList.count > 0 {
                kpiResult = tblList.first!
            }
            else {
                kpiResult.kpi_id =  r.kpi_id
            }
            do {
                try realm.write {
                    kpiResult.value =  r.value
                    kpiResult.notes =  r.notes
                    kpiResult.attachment =  r.attachment
                    realm.add(kpiResult, update: true)
                }
            } catch {
                print("Could not write to database: ", error)
            }
        }
    }
}
