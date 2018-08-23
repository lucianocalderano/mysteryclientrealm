//
//  JobDetail.swift
//  MysteryClient
//
//  Created by mac on 27/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import CoreLocation

class JobDetail: MYViewController {
    class func Instance() -> JobDetail {
        return Instance(sbName: "Jobs", "JobDetail") as! JobDetail
    }
    
    @IBOutlet var infoLabel: MYLabel!
    @IBOutlet var nameLabel: MYLabel!
    @IBOutlet var addrLabel: MYLabel!
    
    @IBOutlet var descBtn: MYButton!
    @IBOutlet var alleBtn: MYButton!
    @IBOutlet var spreBtn: MYButton!
    @IBOutlet var dateBtn: MYButton!
    @IBOutlet var euroBtn: UIButton!

    @IBOutlet var contBtn: MYButton!
    @IBOutlet var tickBtn: MYButton!
    @IBOutlet var strtBtn: MYButton!
    @IBOutlet var stopBtn: MYButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()

        MYGps.shared.start()
        
        for btn in [contBtn, tickBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(16)
            btn.setImage(ico, for: .normal)
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
            btn.layer.shadowColor = UIColor.darkGray.cgColor
            btn.layer.shadowOffset = CGSize.init(width: 0, height: 5)
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.layer.borderWidth = 0.5
            btn.layer.shadowOpacity = 0.2
            btn.layer.masksToBounds = false
        }
        
        for btn in [strtBtn, stopBtn] as! [MYButton] {
            btn.titleLabel?.lineBreakMode = .byWordWrapping;
            btn.titleLabel?.textAlignment = .center;
        }
        showData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAndShowResult()
    }
    
    // MARK: - actions
    @IBAction func euroTapped () {
        alert("Descrizione compenso", message: MYJob.current.fee_desc)
    }
    
    @IBAction func mapsTapped () {
        let store = MYJob.current.store.first!
        _ = Maps.init(lat: store.latitude,
                      lon: store.longitude,
                      name: store.name)
    }
    
    @IBAction func descTapped () {
        let subView = JobDetailDesc.Instance()
        subView.frame = view.frame
        view.addSubview(subView)
    }
    
    @IBAction func atchTapped () {
        let subView = JobDetailAtch.Instance()
        subView.frame = view.frame
        subView.delegate = self
        view.addSubview(subView)
    }
    
    @IBAction func spreTapped () {
        openWeb(type: .bookingRemove, id: MYJob.current.jobId)
    }
    @IBAction func dateTapped () {
        openWeb(type: .bookingMove, id: MYJob.current.jobId)
    }
    
    @IBAction func contTapped () {
        if MYResult.current.execution_date.isEmpty {
            guard MYJob.current.learning_done else {
                openWeb(type: .none, urlPage:  MYJob.current.learning_url)
                MYJob.current.learning_done = true
                loadAndShowResult()
                return
            }
            MYResult.current.estimate_date = Date().toString(withFormat: Config.DateFmt.DataJson)
            MYResult.shared.saveResult()
        }
        let wheel = MYWheel()
        wheel.start(view)
        
        let ctrl = KpiMain.Instance()
        navigationController?.show(ctrl, sender: self)
        wheel.stop()
    }
    
    @IBAction func tickTapped () {
        openWeb(type: .ticketView, id: MYJob.current.jobId)
    }
    
    @IBAction func strtTapped () {
        MYGps.shared.start()
        MYResult.current.positioning.start = true
        executionTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            MYResult.current.positioning.start_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
            MYResult.current.positioning.start_lat = MYGps.shared.currentGps.latitude
            MYResult.current.positioning.start_lng = MYGps.shared.currentGps.longitude
            MYResult.shared.saveResult()
        }
    }
    @IBAction func stopTapped () {
        MYGps.shared.start()
        MYResult.current.positioning.end = true
        executionTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            MYResult.current.positioning.end_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
            MYResult.current.positioning.end_lat = MYGps.shared.currentGps.latitude
            MYResult.current.positioning.end_lng = MYGps.shared.currentGps.longitude
            if MYResult.current.execution_end_time.isEmpty {
                MYResult.current.execution_end_time = Date().toString(withFormat: Config.DateFmt.Ora)
            }
            MYResult.shared.saveResult()
        }
    }
    
    // MARK: - private
    
    private func initialize () {
        let path = "\(Config.Path.docs)/\(MYJob.current.jobId)"
        let fm = FileManager.default
        if fm.fileExists(atPath: path) == false {
            do {
                try fm.createDirectory(atPath: path,
                                       withIntermediateDirectories: true,
                                       attributes: nil)
            } catch let error as NSError {
                print("Unable to create directory \(error.debugDescription)")
            }
        }
    }
    
    private func showData () {
        header?.header.titleLabel.text = MYJob.current.store.first!.name
        infoLabel.text =
            Lng("rifNum") + ": \(MYJob.current.reference)\n" +
            Lng("verIni") + ": \(MYJob.current.start_date.toString(withFormat: Config.DateFmt.Data))\n" +
            Lng("verEnd") + ": \(MYJob.current.end_date.toString(withFormat: Config.DateFmt.Data))\n"
        nameLabel.text = MYJob.current.store.first!.name
        addrLabel.text = MYJob.current.store.first!.address
    }
    
    private func loadAndShowResult () {
        executionTime()
        var title = ""
        if  MYResult.current.execution_date.isEmpty == false {
            title = "kpiCont"
        } else if MYJob.current.irregular == true {
            title = "kpiIrre"
        } else if MYJob.current.learning_done == false {
            title = "learning"
        } else {
            title = "kpiInit"
        }
        contBtn.setTitle(Lng(title), for: .normal)
    }
    
    private func executionTime () {
        strtBtn.isEnabled = false
        stopBtn.isEnabled = false
        strtBtn.backgroundColor = .lightGray
        strtBtn.setTitleColor(UIColor.black, for: .normal);
        stopBtn.backgroundColor = .lightGray
        stopBtn.setTitleColor(UIColor.black, for: .normal);

        if MYResult.current.positioning.start == false {
            strtBtn.isEnabled = true
            strtBtn.backgroundColor = UIColor.red
            strtBtn.setTitleColor(UIColor.white, for: .normal);
        } else if MYResult.current.positioning.end == false {
            stopBtn.isEnabled = true
//            stopBtn.backgroundColor = UIColor.white
        }
    }
}

extension JobDetail {
    private func openWeb (type: WebPage.WebPageEnum, id: Int = 0, urlPage: String = "") {
        let ctrl = WebPage.Instance(type: type, id: id)
        if urlPage.isEmpty == false {
            ctrl.page = urlPage
        }
        navigationController?.show(ctrl, sender: self)        
        //        var page = urlPage
        //        if page.isEmpty {
        //            page = Config.Url.home + type.rawValue
        //            if id > 0 {
        //                page += String(id)
        //            }
        //        }
        //        UIApplication.shared.openURL(URL.init(string: page)!)
    }
}

// MARK: - Attachment delegate

extension JobDetail: JobDetailAtchDelegate {
    func openFileFromUrlWithString(_ page: String) {
        openWeb(type: .none, urlPage: page)
    }
}
