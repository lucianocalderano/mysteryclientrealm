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
    func currentIncaricoSuccess(_ loadJob: MYJob)
    func currentIncaricoError(_ loadJob: MYJob, errorCode: String, message: String)
}

class MYJob {
    public static var current: TblJob!
    public static var JobPath = ""

    public static var KpiKeyList = [Int]() // Di comodo per evitare la ricerca del kpi.id nell'array dei kpi
    
    class func removeJobWithId (_ id: Int) {
        DB.incarichiClear("id = \(id)")
    }
    
    class func updateCurrent (_ current: TblJob, delegate: MYJobDelegate?) {
        let me = MYJob()
        me.updateCurrent(current, delegate: delegate)
    }
    
    private var delegate: MYJobDelegate?
    private let fm = FileManager.default
    
    func updateCurrent (_ incarico: TblJob, delegate: MYJobDelegate?) {
        self.delegate = delegate
        MYJob.current = incarico
        MYJob.JobPath = Config.Path.docs + "\(MYJob.current.id)" + "/"
        MYResult.current = MYResult.shared.loadResult (jobId: MYJob.current.id)
        
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
            self.delegate?.currentIncaricoError(self, errorCode: "Unable to create directory", message: error.debugDescription)
            return true
        }
        return false
    }
    
    private func getDetail () {
        User.shared.getUserToken(completion: {
            self.loadJobDetail()
        }) {
            (errorCode, message) in
            self.delegate?.currentIncaricoError(self, errorCode: errorCode, message: message)
        }
    }
    
    private func loadJobDetail () {
        let param = [ "object" : "job", "object_id":  MYJob.current.id ] as JsonDict
        let request = MYHttp.init(.get, param: param)
        
        request.load( { (response) in
            let dict = response.dictionary("job")
            DB.incaricoAdd(withDict: dict)
            MYJob.current = DB.incarichi("id = \(MYJob.current.id)").first
            
            if MYJob.current.irregular == true {
                self.downloadResult()
            } else {
                self.openJobDetail()
            }
            
        }) {
            (errorCode, message) in
            self.delegate?.currentIncaricoError(self, errorCode: errorCode, message: message)
        }
    }
    
    private func openJobDetail () {
        MYJob.KpiKeyList.removeAll()
        DB.kpisReset()
        for kpi in MYJob.current.kpis {
            MYJob.KpiKeyList.append(kpi.id)
        }
        
        self.delegate?.currentIncaricoSuccess(self)
    }
    
    //MARK:- Irregular = true
    
    private func downloadResult () {
        MYResult.current.results.removeAll()
        for kpi in MYJob.current.kpis {
            let kpiResult = kpi.result.first!
            let result = JobResult.KpiResult()
            result.kpi_id = kpiResult.id
            result.value = kpiResult.value
            result.notes = kpiResult.notes
            result.attachment = kpiResult.attachment
            MYResult.current.results.append(result)
            if kpiResult.url.isEmpty == false {
                downloadAtch(url: kpiResult.url, kpiId: kpi.id)
            }
        }
        openJobDetail()
    }
    
    private func downloadAtch (url urlString: String, kpiId: Int) {
        let param = [
            "object" : "job",
            "result_attachment":  MYJob.current.id
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
