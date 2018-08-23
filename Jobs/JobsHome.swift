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
    private var items = DB.incarichi()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MYResult.current = JobResult()
        loadJobs()
    }
    
    override func headerViewDxTapped() {
        DB.incarichiClear()
        loadJobs()
    }
    
    private func loadJobs () {
        getList(done: { (items) in
            func zipExists (id: Int) -> Bool {
                let file = MYZip.getZipFilePath(id: id)
                return FileManager.default.fileExists(atPath: file)
            }
            
            for item in items {
                if item.id > 0 {
                    if zipExists(id: item.id) {
                        DB.incarichiClear("id = \(item.id)")
                    }
                }
            }
            
            self.items = DB.incarichi()
            self.tableView.reloadData()
        })
    }
}

// MARK: - Job List

extension JobsHome {
    private func getList(done: @escaping (Results<TblJob>) -> () = { array in })  {
        if items.count > 0 {
            done (items)
            return
        }

        User.shared.getUserToken(completion: {
            loadJobList()
        }) {
            (errorCode, message) in
            self.alert(errorCode, message: message, okBlock: nil)
        }
        
        func loadJobList () {
            let param = [ "object" : "jobs_list" ]
            let request = MYHttp.init(.get, param: param)
            request.load( { (response) in
                for dict in response.array("jobs") as! [JsonDict] {
                    DB.incaricoAdd(withDict: dict)
                }
                
                func zipExists (id: Int) -> Bool {
                    let file = MYZip.getZipFilePath(id: id)
                    return FileManager.default.fileExists(atPath: file)
                }
                done (DB.incarichi())
            }) {
                (errorCode, message) in
                self.alert(errorCode, message: message, okBlock: nil)
            }
        }
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
        cell.incarico =  items[indexPath.row]
        return cell
    }
}

//MARK: - UITableViewDelegate

extension JobsHome: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedJob(job: items[indexPath.row])
    }
}

//MARK: - JobsHomeCellDelegate

extension JobsHome: JobsHomeCellDelegate {
    func mapTapped(_ sender: JobsHomeCell, incarico: TblJob) {
        if let store = incarico.store.first {
        _ = Maps.init(lat: store.latitude,
                      lon: store.longitude,
                      name: store.name)
        }
    }
}

// MARK: - Selected job

extension JobsHome {
    private func selectedJob (job: TblJob) {
        wheel.start(self.view)
        MYJob.updateCurrent(job, delegate: self)
    }
}

extension JobsHome: MYJobDelegate {
    func currentIncaricoSuccess(_ loadJob: MYJob) {
        wheel.stop()
        let vc = JobDetail.Instance()
        self.navigationController?.show(vc, sender: self)
    }

    func currentIncaricoError(_ loadJob: MYJob, errorCode: String, message: String) {
        wheel.stop()
        self.alert(errorCode, message: message, okBlock: nil)
    }
}


