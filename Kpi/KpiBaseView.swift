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
    var currentResult: TblResultKpi!

    func getValuation () -> KpiResponseValues {
        return KpiResponseValues()
    }
}

class KpiBaseView: UIView {
    var delegate: KpiDelegate?
    var mainVC: KpiMain!
    var currentJobKpi: TblJobKpi!
    var currentResult: TblResultKpi!
    var kpiIndex = 0 {
        didSet {
            currentJobKpi = Current.job.kpis[kpiIndex]
            currentResult = Current.result.results[kpiIndex]
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
