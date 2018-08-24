//
//  Profile.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import RealmSwift

class JobsHome: MYViewController {
    class func Instance() -> JobsHome {
        return Instance(sbName: "Jobs", isInitial: true) as! JobsHome
    }
    
    @IBOutlet private var tableView: UITableView!
    private let wheel = MYWheel()
    private var items = TblJobUtil.getJobs()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Current.result = TblResult()
        loadJobs()
    }
    
    override func headerViewDxTapped() {
        LcRealm.shared.clearAll()
        loadJobs()
    }
    
    private func loadJobs () {
        if items.count > 0 {
            return
        }
        User.shared.getUserToken(completion: {
            self.loadJobList()
        }) { (errorCode, message) in
            self.alert(errorCode, message: message, okBlock: nil)
        }
    }
    
    private func loadJobList () {
        let param = [ "object" : "jobs_list" ]
        let request = MYHttp.init(.get, param: param)
        request.load( { (response) in
            self.updateJob(jobsArray: response.array("jobs") as! [JsonDict])
        }) { (errorCode, message) in
            self.alert(errorCode, message: message, okBlock: nil)
        }
    }
    
    private func updateJob (jobsArray: [JsonDict]) {
        for dict in jobsArray {
            _ = TblJobUtil.addJob(withDict: dict)
        }
        
        for item in TblJobUtil.getJobs() {
            if item.jobId == 0 {
                continue
            }
            let file = MYZip.getZipFilePath(id: item.jobId)
            if  FileManager.default.fileExists(atPath: file) {
                TblJobUtil.removeJob(WithId: item.jobId)
            }
        }
        
        self.items = TblJobUtil.getJobs()
        self.tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource

extension JobsHome: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = JobsHomeCell.dequeue(tableView, indexPath)
        cell.delegate = self
        cell.job = items[indexPath.row]
        return cell
    }
}

//MARK: - UITableViewDelegate

extension JobsHome: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedJob(items[indexPath.row])
    }
}

//MARK: - JobsHomeCellDelegate

extension JobsHome: JobsHomeCellDelegate {
    func mapTapped(_ sender: JobsHomeCell, tblJob: TblJob) {
       Maps.show(lat: Current.job.store_latitude, lon: Current.job.store_longitude, name: Current.job.store_name)
    }
}

// MARK: - Selected job

extension JobsHome {
    private func selectedJob (_ job: TblJob) {
        wheel.start(self.view)
        TblJobUtil.updateCurrent(job, delegate: self)
    }
}

extension JobsHome: MYJobDelegate {
    func updateCurrentJobSuccess() {
        wheel.stop()
        let vc = JobDetail.Instance()
        self.navigationController?.show(vc, sender: self)
    }
    
    func updateCurrentJobError(_ errorCode: String, message: String) {
        wheel.stop()
        self.alert(errorCode, message: message, okBlock: nil)
    }
}


