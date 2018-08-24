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
        alert("Descrizione compenso", message: Current.job.fee_desc)
    }
    
    @IBAction func mapsTapped () {
        Maps.show(lat: Current.job.store_latitude, lon: Current.job.store_longitude, name: Current.job.store_name)
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
        openWeb(type: .bookingRemove, id: Current.job.jobId)
    }
    @IBAction func dateTapped () {
        openWeb(type: .bookingMove, id: Current.job.jobId)
    }
    
    @IBAction func contTapped () {
        if Current.result.execution_date.isEmpty {
            guard Current.job.learning_done else {
                openWeb(type: .none, urlPage:  Current.job.learning_url)
                Current.job.learning_done = true
                loadAndShowResult()
                return
            }
            LcRealm.begin()
            Current.result.estimate_date = Date().toString(withFormat: Config.DateFmt.DataJson)
            LcRealm.commit()
        }
        let wheel = MYWheel()
        wheel.start(view)
        
        let ctrl = KpiMain.Instance()
        navigationController?.show(ctrl, sender: self)
        wheel.stop()
    }
    
    @IBAction func tickTapped () {
        openWeb(type: .ticketView, id: Current.job.jobId)
    }
    
    @IBAction func strtTapped () {
        MYGps.shared.start()
        LcRealm.begin()
        Current.result.pos_start = true
        LcRealm.commit()
        executionTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            LcRealm.begin()
            Current.result.pos_start_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
            Current.result.pos_start_lat = MYGps.shared.currentGps.latitude
            Current.result.pos_start_lng = MYGps.shared.currentGps.longitude
            LcRealm.commit()
        }
    }
    @IBAction func stopTapped () {
        MYGps.shared.start()
        LcRealm.begin()
        Current.result.pos_end = true
        LcRealm.commit()
        executionTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            LcRealm.begin()
            Current.result.pos_end_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
            Current.result.pos_end_lat = MYGps.shared.currentGps.latitude
            Current.result.pos_end_lng = MYGps.shared.currentGps.longitude
            if Current.result.execution_end_time.isEmpty {
                Current.result.execution_end_time = Date().toString(withFormat: Config.DateFmt.Ora)
            }
            LcRealm.commit()
        }
    }
    
    // MARK: - private
    
    private func showData () {
        header?.header.titleLabel.text = Current.job.store_name
        infoLabel.text =
            Lng("rifNum") + ": \(Current.job.reference)\n" +
            Lng("verIni") + ": \(Current.job.start_date.toString(withFormat: Config.DateFmt.Data))\n" +
            Lng("verEnd") + ": \(Current.job.end_date.toString(withFormat: Config.DateFmt.Data))\n"
        nameLabel.text = Current.job.store_name
        addrLabel.text = Current.job.store_address
    }
    
    private func loadAndShowResult () {
        executionTime()
        var title = ""
        if  Current.result.execution_date.isEmpty == false {
            title = "kpiCont"
        } else if Current.job.irregular == true {
            title = "kpiIrre"
        } else if Current.job.learning_done == false {
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

        if Current.result.pos_start == false {
            strtBtn.isEnabled = true
            strtBtn.backgroundColor = UIColor.red
            strtBtn.setTitleColor(UIColor.white, for: .normal);
        } else if Current.result.pos_end == false {
            stopBtn.isEnabled = true
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
    }
}

// MARK: - Attachment delegate

extension JobDetail: JobDetailAtchDelegate {
    func openFileFromUrlWithString(_ page: String) {
        openWeb(type: .none, urlPage: page)
    }
}
