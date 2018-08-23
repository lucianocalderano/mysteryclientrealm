//
//  JobDetailDesc.swift
//  MysteryClient
//
//  Created by mac on 28/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class JobDetailDesc: UIView {
    class func Instance() -> JobDetailDesc {
        return InstanceView() as! JobDetailDesc
    }
    
    @IBOutlet var jobDesc: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var desc = MYJob.current.description
        if MYJob.current.additional_description.isEmpty == false {
            desc += "\n\n- Descrizione aggiuntiva\n\n" + MYJob.current.additional_description + "\n\n"
        }
        if MYJob.current.details.isEmpty == false {
            desc += "\n\n- Dettagli orario\n\n" + MYJob.current.details + "\n\n"
        }
        jobDesc.text = desc
    }
    
    @IBAction func okTapped () {
        self.removeFromSuperview()
    }
}
