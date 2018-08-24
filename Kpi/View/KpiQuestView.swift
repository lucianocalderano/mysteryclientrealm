//
//  SubKpi.swift
//  MysteryClient
//
//  Created by Lc on 11/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//
import UIKit

class KpiQuestView: KpiBaseView {
    class func Instance() -> KpiQuestView {
        return InstanceView() as! KpiQuestView
    }
    
    @IBOutlet private var content: UIView!
    @IBOutlet private var containerSubView: UIView!
    @IBOutlet private var atchView: UIView!
    @IBOutlet private var atchImage: UIImageView!
    @IBOutlet private var atchName: MYLabel!
    @IBOutlet private var kpiTitle: MYLabel!
    @IBOutlet private var kpiQuestion: MYLabel!
    @IBOutlet private var kpiInstructions: MYLabel!
    @IBOutlet private var kpiAtchBtn: MYButton!
    @IBOutlet private var kpiNote: UITextView!
    @IBOutlet private var noteLabel: UILabel!
    @IBOutlet private var subViewHeight: NSLayoutConstraint!
    
    private var valueMandatoty = true
    private var kpiQuestSubView: KpiBaseSubView!
    private var kpiAtch: KpiAtch?
    
    //MARK:-
    
    override func awakeFromNib() {
        super.awakeFromNib()
        kpiNote.delegate = self
        kpiNote.layer.borderWidth = 1
        kpiNote.layer.borderColor = UIColor.lightGray.cgColor

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(atchRemove))
        atchView.addGestureRecognizer(tap)
        atchView.isUserInteractionEnabled = true
        atchView.layer.borderColor = UIColor.lightGray.cgColor
        atchView.layer.borderWidth = 1
    }
    
    override func initialize() {
        kpiTitle.text = currentJobKpi.factor
        kpiQuestion.text = currentJobKpi.standard
        kpiInstructions.text = currentJobKpi.instructions
        kpiAtchBtn.isHidden = !currentJobKpi.attachment && !currentJobKpi.attachment_required

        updateNoteTitle(note_required: currentJobKpi.note_required)
        updateAtchTitle(atch_required: currentJobKpi.attachment_required)

        kpiNote.text = currentResult.notes
        showAtch()
        
        addQuestSubview(type: currentJobKpi.type)
    }
    
    override func getHeight() -> CGFloat {
        
        return atchView.frame.origin.y + 100
    }

    override func checkData(completion: @escaping (KpiResultType) -> ()) {
        let responseValue = kpiQuestSubView.getValuation()
        var noteRequired = currentJobKpi.note_required
        var atchRequired = currentJobKpi.attachment_required
        var saveResult: KpiResultType {
            if currentResult.value != responseValue.value {
                InvalidKpi.resetDependenciesWithKpi(currentJobKpi)
            }
            
//            if currentResult.kpi_id == 0 {
//                currentResult.kpi_id = currentKpi.id
//            }
            LcRealm.begin()
            currentResult.value = responseValue.value
            currentResult.notes = kpiNote.text
            currentResult.attachment = atchName.text!
            LcRealm.commit()

            if responseValue.dependencies.count > 0 {
                InvalidKpi.updateWithResponse(responseValue)
            }
//            TblResultUtil.saveCurrentResult()
            return .next
        }

        if currentJobKpi.required == true {
            if responseValue.value.isEmpty && valueMandatoty == true {
                completion (.errValue)
            }
            if responseValue.notesReq == true {
                noteRequired = responseValue.notesReq
            }
            if responseValue.attchReq == true {
                atchRequired = responseValue.attchReq
            }
        }
        
        if noteRequired == true && kpiNote.text.isEmpty {
            completion (.errNotes)
        }
        
        self.endEditing(true)
        if atchRequired == true && atchImage.image == nil {
            askNoAtch { (okSelected) in
                if okSelected  {
                    completion (saveResult)
                } else {
                    completion (.errAttch)
                }
            }
        } else {
            completion (saveResult)
        }
    }
    
    func showAtch () {
        atchImage.image = nil
        if currentResult.attachment.isEmpty == false {
            let fileName = MYJob.JobPath + currentResult.attachment
            let imageURL = URL(fileURLWithPath: fileName)
            if let image = UIImage(contentsOfFile: imageURL.path) {
                atchImage.image = image
            } else {
                atchImage.image = UIImage.init(named: "ico.warn")
            }
        }
        
        if atchImage.image == nil {
            atchView.isHidden = true
            setAtchName()
        } else {
            atchView.isHidden = false
        }
        atchName.text = currentResult.attachment
    }
    
    private func setAtchName (file: String = "") {
        LcRealm.begin()
        currentResult.attachment = file
        LcRealm.commit()
    }
    
    @objc func atchRemove () {
        let imv = UIImageView()
        imv.backgroundColor = UIColor.lightGray
        imv.image = atchImage.image
        imv.contentMode = .scaleAspectFit
        imv.frame = UIScreen.main.bounds
        imv.layer.borderColor = UIColor.white.cgColor
        imv.layer.borderWidth = 5
        mainVC.view.addSubview(imv)
        
        func showAlert() {
            let fileName = MYJob.JobPath + currentResult.attachment
            mainVC.alert(Lng("atchRemove"), message: "", cancelBlock: {
                (cancel) in
                imv.removeFromSuperview()
            }) {
                (ok) in
                imv.removeFromSuperview()
                do {
                    try FileManager.default.removeItem(atPath: fileName)
                    self.setAtchName()
                }
                catch let error as NSError {
                    print("removeItem atPath: \(error)")
                    self.setAtchName()
                }
                self.showAtch()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showAlert()
        }
        
    }
    
    //MARK: - Actions
    
    @IBAction func atchButtonTapped () {
        if kpiAtch == nil {
            kpiAtch = KpiAtch.init(mainViewCtrl: mainVC)
            kpiAtch?.delegate = self
        }
        kpiAtch?.showArchSelection()
    }
    
    private func askNoAtch (completion: @escaping (Bool) -> ()) {
        let alert = UIAlertController(title: Lng("noAtchTitle"),
                                      message:Lng("noAtchMsg"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: Lng("no"),
                                           style: .default,
                                           handler: { (action) in
                                            completion(false)
        }))
        
        alert.addAction(UIAlertAction.init(title: Lng("yes"),
                                           style: .default,
                                           handler: { (action) in
                                            completion(true)
        }))
        
        mainVC.present(alert, animated: true) { }
    }
    
    //MARK: - Private
    
    private func addQuestSubview (type: String) {
        valueMandatoty = true
        subViewHeight.constant = 1
        switch type {
        case "radio", "select" :
            kpiQuestSubView = SubRadio.Instance()
        case "text" :
            kpiQuestSubView = SubText.Instance()
        case "date" :
            kpiQuestSubView = SubDatePicker.Instance(type: .date)
        case "time" :
            kpiQuestSubView = SubDatePicker.Instance(type: .time)
        case "datetime" :
            kpiQuestSubView = SubDatePicker.Instance(type: .datetime)
        case "label", "geophoto" :
            kpiQuestSubView = SubLabel.Instance()
            valueMandatoty = false
        case "multicheckbox" :
            kpiQuestSubView = SubCheckBox.Instance()
        default:
            kpiQuestSubView = KpiBaseSubView()
            valueMandatoty = false
        }
        containerSubView.addSubviewWithConstraints(kpiQuestSubView)
        kpiQuestSubView.delegate = self
        kpiQuestSubView.currentKpi = currentJobKpi
        kpiQuestSubView.currentResult = currentResult
    }
    
    private func updateNoteTitle (note_required: Bool) {
        noteLabel.text = (note_required) ? Lng("noteReq") : Lng("note")
    }
    private func updateAtchTitle (atch_required: Bool) {
        kpiAtchBtn.setTitle((atch_required) ? Lng("jobSelAtchReq") : Lng("jobSelAtchReq"), for: .normal)
    }
}

//MARK: - KpiSubViewDelegate

extension KpiQuestView: KpiSubViewDelegate {
    func kpiViewHeight(_ height: CGFloat) {
        subViewHeight.constant = height
        var rect = self.frame
        rect.size.height += height
        self.frame = rect
    }
    
    func valuationSelected(_ valuation: TblJobKpiValuation) {
        print(valuation.note_required , currentJobKpi.note_required , ":" , valuation.attachment_required , currentJobKpi.attachment_required)
        updateNoteTitle(note_required: valuation.note_required || currentJobKpi.note_required)
        updateAtchTitle(atch_required: valuation.attachment_required || currentJobKpi.attachment_required)
    }
}

//MARK: - UITextViewDelegate

extension KpiQuestView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.kpiStartEditingAtPosY(kpiNote.frame.origin.y - 30)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.kpiEndEditing()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK:- Image picker

extension KpiQuestView: KpiAtchDelegate {
    func kpiAtchSelectedImage(withData data: Data) {
        setAtchName(file: "\(Current.job.reference).\(currentJobKpi.id).jpg")
        let fileName = MYJob.JobPath + currentResult.attachment
        
        do {
            try data.write(to: URL.init(string: Config.File.urlPrefix + fileName)!)
        } catch {
            print("errore salvataggio file " + currentResult.attachment)
            setAtchName()
        }
        showAtch()
    }
}

