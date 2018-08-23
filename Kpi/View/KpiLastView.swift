//
//  KpiLast.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiLastView: KpiBaseView {
    class func Instance() -> KpiLastView {
        return InstanceView() as! KpiLastView
    }
    
    @IBOutlet private var finalView: UIView!
    @IBOutlet private var finalText: UITextView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var datePicker: UIDatePicker!
    private var minmax = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        finalText.text = MYResult.current.comment
        finalText.layer.borderColor = UIColor.lightGray.cgColor
        finalText.layer.borderWidth = 1
        finalText.delegate = self
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if MYResult.current.compilation_date.isEmpty == false {
            let d = MYResult.current.compilation_date
            let date = d.toDate(withFormat: Config.DateFmt.DataOraJson)
            datePicker.date = date
        }
        counterLabel.text = ""
        if (MYJob.current.comment_min == 0 && MYJob.current.comment_max == 0) {
            counterLabel.isHidden = true
        }
        else {
            minmax = ""
            if MYJob.current.comment_min > 0 {
                minmax = minmax + " Min." + String(MYJob.current.comment_min)
            }
            if MYJob.current.comment_max > 0 {
                minmax = minmax + " Max." + String(MYJob.current.comment_max)
            }
            counterLabel.text = minmax
        }
    }
    
    override func checkData(completion: @escaping (KpiResultType) -> ()) {
        if finalText.text.count < MYJob.current.comment_min {
            completion(.errComment)
            return
        }
        if MYJob.current.comment_max > 0 && finalText.text.count > MYJob.current.comment_max {
            completion(.errComment)
            return
        }
        MYResult.current.comment = finalText.text!
        MYResult.current.compiled = 1
        MYResult.current.compilation_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
        MYResult.current.execution_end_time = datePicker.date.toString(withFormat: Config.DateFmt.Ora)
        MYResult.shared.saveResult()        
        completion (.last)
    }
}

extension KpiLastView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if text != "" {
            if MYJob.current.comment_max > 0 && range.location >= MYJob.current.comment_max {
                return false
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        if counterLabel.isHidden == false {
            counterLabel.text = "\(textView.text.count)" + minmax
        }
    }
}
