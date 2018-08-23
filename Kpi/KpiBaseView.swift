//
//  KpisSubView.swift
//  MysteryClient
//
//  Created by Lc on 11/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit

class KpiBaseSubView: UIView {
    var delegate: KpiSubViewDelegate?
    
    var currentKpi: TblJobKpi!
    var currentResult: JobResult.KpiResult!

    func getValuation () -> KpiResponseValues {
        return KpiResponseValues()
    }
}

class KpiBaseView: UIView {
    var delegate: KpiDelegate?
    var mainVC: KpiMain!
    var currentKpi: TblJobKpi!
    var currentResult: JobResult.KpiResult!
    var kpiIndex = 0 {
        didSet {
            currentKpi = MYJob.current.kpis[kpiIndex]
            currentResult = MYResult.current.results[kpiIndex]
            initialize()
        }
    }
    
    func initialize () {
    }
    
    func getHeight () -> CGFloat {
        return self.frame.size.height
    }
    
    func checkData(completion: @escaping (KpiResultType) -> ()) {
//        return .err
    }
}
