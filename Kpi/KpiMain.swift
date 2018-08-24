//
//  KpiMain.swift
//  MysteryClient
//
//  Created by mac on 05/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import Zip

class KpiMain: MYViewController {
    class func Instance() -> KpiMain {
        return Instance(sbName: "Kpi", "KpiMain") as! KpiMain
    }
    
    @IBOutlet private var container: UIView!
    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    @IBOutlet private var warnBtn: UIButton!

    private var kpiView: KpiBaseView!
    
    var currentIndex = -1
    var myKeyboard: MYKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let idx = Current.job.kpis.count
        
        warnBtn.isHidden = true
        self.view.bringSubview(toFront: warnBtn)
        switch currentIndex {
        case -1:
            kpiView = KpiInitView.Instance()
        case idx:
            kpiView = KpiLastView.Instance()
            nextBtn.setTitle(Lng("lastPage"), for: .normal)
        default:
            kpiView = KpiQuestView.Instance()
            kpiView.kpiIndex = currentIndex
            scroll.backgroundColor = UIColor.white
            let kpi = Current.job.kpis[currentIndex]
            warnBtn.isHidden = (kpi.result_irregular == false)
        }
        kpiView.mainVC = self
        kpiView.delegate = self
        scroll.addSubview(kpiView)
        showPageNum()
        
        myKeyboard = MYKeyboard(vc: self, scroll: scroll)
        
        headerTitle = Current.job.store_name
        
        for btn in [backBtn, nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)
        }
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        nextBtn.semanticContentAttribute = .forceRightToLeft
        nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    override func headerViewSxTapped() {
       self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var rect = kpiView.frame
        rect.size.height = kpiView.getHeight()
        rect.size.width = scroll.frame.size.width
        kpiView.frame = rect
        scroll.contentSize = rect.size
    }
    
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        kpiView.checkData { (response) in
            self.validateResponse(response)
        }
    }
    
    @IBAction func prevTapped () {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func warnTapped () {
        let kpi = Current.job.kpis[currentIndex]
        self.alert("Irregolare", message: kpi.result_irregular_note)
    }
    
    //MARK: - Private
    
    private func validateResponse (_ response: KpiResultType) {
        switch response {
        case .next:
            nextKpi()
        case .last:
            sendKpiResult()
        case .errComment:
            let max = Current.job.comment_max > 0 ? Current.job.comment_max : 999
            let s = "La lunghezza dell commento deve essere tra \(Current.job.comment_min) e \(max) caratteri"
            alert(Lng("error"), message: s)
        case .errValue:
            alert(Lng("error"), message: Lng("noValue"))
        case .errNotes:
            alert(Lng("error"), message: Lng("noNotes"))
        case .errAttch:
//            alert(Lng("error"), message: Lng("noAttch"))
            break
        case .err:
            break
        }
    }
    
    private func showPageNum() {
        if let label = header?.header.kpiLabel {
            label.isHidden = false
            label.text = "\(currentIndex + 2)/\(Current.job.kpis.count + 2)"
        }
    }
    
    private func nextKpi () {
        let lastKpi = Current.job.kpis.count - 1
        let loadCtrlWithIndex: (Int) -> () = { index in
            let vc = KpiMain.Instance()
            vc.currentIndex = index
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if currentIndex == lastKpi {
            loadCtrlWithIndex (Current.job.kpis.count)
            return
        }
        for index in currentIndex + 1...lastKpi {
            let kpi = Current.job.kpis[index]            
            if kpi.isValid == true {
                loadCtrlWithIndex(index)
                return
            }
        }
    }
}

//MARK:- KpiDelegate

extension KpiMain: KpiDelegate {
    func kpiEndEditing() {
        myKeyboard.endEditing()
    }
    
    func kpiStartEditingAtPosY(_ y: CGFloat) {
        myKeyboard.startEditing(y: y)
    }
}

//MARK:- sendKpiResult

extension KpiMain {
    private func sendKpiResult () {
        let sendJob = SendJob()
        let dict = MYResult.createJson()
        let result = sendJob.createZipFileWithDict(dict)
        
        guard result.isEmpty else {
            alert ("Errore zip", message: result, okBlock: nil)
            return
        }
        
        alert (Lng("readyToSend"), message: "", okBlock: {
            (ready) in
            self.navigationController!.popToRootViewController(animated: true)
        })
    }
}
