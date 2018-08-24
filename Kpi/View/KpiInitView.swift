//
//  SubText
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiInitView: KpiBaseView {
    class func Instance() -> KpiInitView {
        return InstanceView() as! KpiInitView
    }

    @IBOutlet private var undoneView: UIView!
    @IBOutlet private var undondeText: MYTextField!
    @IBOutlet private var okButton: MYButton!
    @IBOutlet private var noButton: MYButton!
    @IBOutlet private var datePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
        for btn in [okButton, noButton] {
            btn?.layer.cornerRadius = (btn?.frame.size.height)! / 2
        }
        TblResultUtil.firstLoad()
        okTapped()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        undondeText.text = Current.result.comment
        if Current.result.execution_date.isEmpty == false {
            let d = Current.result.execution_date + " " + Current.result.execution_start_time + ":00"
            let date = d.toDate(withFormat: Config.DateFmt.DataOraJson)
            datePicker.date = date
        }
    }
    
    override func checkData(completion: @escaping (KpiResultType) -> ()) {
        if undoneView.isHidden == false && (undondeText.text?.isEmpty)! {
            undondeText.becomeFirstResponder()
            completion (.errNotes)
        }
        
        myRealmBegin()
        Current.result.execution_date = datePicker.date.toString(withFormat: Config.DateFmt.DataJson)
        Current.result.execution_start_time = datePicker.date.toString(withFormat: Config.DateFmt.Ora)
        myRealmCommit()
        completion (.next)
    }
    
    // MARK: - Actions
    
    @IBAction func okTapped () {
        undoneView.isHidden = true
        okButton.backgroundColor = UIColor.white
        noButton.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func noTapped () {
        undoneView.isHidden = false
        okButton.backgroundColor = UIColor.lightGray
        noButton.backgroundColor = UIColor.white
    }
 }

