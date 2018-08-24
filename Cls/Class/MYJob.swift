//
//  JobStruct.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import RealmSwift

protocol MYJobDelegate {
    func currentJobSuccess(_ loadJob: MYJob)
    func currentJobError(_ loadJob: MYJob, errorCode: String, message: String)
}

class MYJob {
    public static var current: TblJob!
    public static var JobPath = ""
    public static var KpiKeyList = [Int]() // Di comodo per evitare la ricerca del kpi.id nell'array dei kpi
    
    class func removeJobWithId (_ id: Int) {
        let realm = LcRealm.shared.realm!
        let filter = "jobId = \(id)"
        
        let tblJob = realm.objects(TblJob.self).filter(filter)
        let tblJobAtt = realm.objects(TblJobAttachment.self).filter(filter)
        let tblJobKpi = realm.objects(TblJobKpi.self).filter(filter)
        let tblJobKpiVal = realm.objects(TblJobKpiValuation.self).filter(filter)
        let tblJobKpiValDep = realm.objects(TblJobKpiValDependency.self).filter(filter)
        
        do {
            try realm.write {
                realm.delete(tblJob)
                realm.delete(tblJobAtt)
                realm.delete(tblJobKpi)
                realm.delete(tblJobKpiVal)
                realm.delete(tblJobKpiValDep)
            }
        } catch {
            print("Could not write to database: ", error)
        }
    }
    
    class func updateCurrentJob (_ job: TblJob, delegate: MYJobDelegate?) {
        MYJob.current = job
        MYJob.JobPath = Config.Path.docs + "\(MYJob.current.jobId)" + "/"
//        MYResult.current = MYResult.shared.loadResult (jobId: MYJob.current.jobId)

        let me = MYJob()
        me.updateCurrentJob(delegate: delegate)
    }
    
    private var delegate: MYJobDelegate?
    private let fm = FileManager.default
    
    func updateCurrentJob (delegate: MYJobDelegate?) {
        self.delegate = delegate
        
        if errorOnCraateWorkingPath() {
            return
        }
        
        if MYJob.current.kpis.count == 0 {
            getDetail ()
        } else {
            openJobDetail()
        }
    }
    
    private func errorOnCraateWorkingPath() -> Bool {
        if fm.fileExists(atPath: MYJob.JobPath) {
            return false
        }
        do {
            try fm.createDirectory(atPath: MYJob.JobPath,
                                   withIntermediateDirectories: true,
                                   attributes: nil)
        } catch let error as NSError {
            self.delegate?.currentJobError(self, errorCode: "Unable to create directory", message: error.debugDescription)
            return true
        }
        return false
    }
    
    private func getDetail () {
        User.shared.getUserToken(completion: {
            self.loadJobDetail()
        }) {
            (errorCode, message) in
            self.delegate?.currentJobError(self, errorCode: errorCode, message: message)
        }
    }
    
    private func loadJobDetail () {
        let param = [ "object" : "job", "object_id":  MYJob.current.jobId ] as JsonDict
        let request = MYHttp.init(.get, param: param)
        
        request.load( { (response) in
            let dict = response.dictionary("job")
            DB.addJob(withDict: dict)
            MYJob.current = DB.jobs(withId: MYJob.current.jobId).first

            if MYJob.current.irregular == true {
                self.downloadResult()
            } else {
                self.openJobDetail()
            }
            
        }) {
            (errorCode, message) in
            self.delegate?.currentJobError(self, errorCode: errorCode, message: message)
        }
    }
    
    private func openJobDetail () {
        TblResultUtil.loadResult(withId: MYJob.current.jobId)
        
        MYJob.KpiKeyList.removeAll()
        DB.setKpiToValid()
        for kpi in MYJob.current.kpis {
            MYJob.KpiKeyList.append(kpi.id)
        }
        
        self.delegate?.currentJobSuccess(self)
    }
    
    //MARK:- Irregular = true
    
    private func downloadResult () {
        TblResultUtil.create()
//        LcRealm.begin()
//        MYResult.current.results.removeAll()
//        LcRealm.commit()
//        for jobKpi in MYJob.current.kpis {
//            let result = TblResultKpi()
//            result.kpi_id = jobKpi.result_id
//            result.value = jobKpi.result_value
//            result.notes = jobKpi.result_notes
//            result.attachment = jobKpi.result_attachment
//            LcRealm.begin()
//            MYResult.current.results.append(result)
//            LcRealm.commit()
//            if jobKpi.result_url.isEmpty == false {
//                downloadAtch(url: jobKpi.result_url, kpiId: jobKpi.id)
//            }
//        }
        openJobDetail()
    }
    
    private func downloadAtch (url urlString: String, kpiId: Int) {
        let param = [
            "object" : "job",
            "result_attachment":  MYJob.current.jobId
            ] as JsonDict
        let request = MYHttp.init(.get, param: param, showWheel: false)
        
        request.loadAtch(url: urlString, { (response) in
            do {
                let dict = try JSONSerialization.jsonObject(with: response, options: []) as! JsonDict
                print(dict)
            } catch {
                let suffix = UIImage.init(data: response) == nil ? "pdf" : "jpg"
                let dest = MYJob.JobPath + "\(MYJob.current.reference).\(kpiId)." + suffix
                print(dest)
                
                do {
                    try response.write(to: URL.init(string: Config.File.urlPrefix + dest)!)
                } catch {
                    print("Unable to load data: \(error)")
                }
            }
        })
    }
    
}
