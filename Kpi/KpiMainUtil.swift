//
//  KpiMainUtil.swift
//  MysteryClient
//
//  Created by Lc on 12/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit
import RealmSwift

protocol KpiSubViewDelegate {
    func kpiViewHeight(_ height: CGFloat)
    func valuationSelected (_ valuation: TblJobKpiValuation)
}

protocol KpiDelegate {
    func kpiStartEditingAtPosY (_ y: CGFloat)
    func kpiEndEditing ()
}

extension KpiDelegate {
    func kpiStartEditingAtPosY (_ y: CGFloat) {}
    func kpiEndEditing () {}
}

struct KpiResponseValues {
    var value = ""
    var notesReq = false
    var attchReq = false
    var dependencies = List<TblJobKpiValDependency>()
}

enum KpiResultType {
    case next
    case last
    
    case errValue
    case errNotes
    case errAttch
    case errComment
    case err
}

class InvalidKpi {
    private class func fixValuation (isValid: Bool, dep: TblJobKpiValDependency) {
        if let idx = Current.kpiKeyList.index(of: dep.key) {
            LcRealm.begin()
            Current.job.kpis[idx].isValid = isValid

            let kpiResult = Current.result.results[idx]
            kpiResult.kpi_id = dep.key
            kpiResult.value = isValid ? "" : dep.value
            kpiResult.notes = isValid ? "" : dep.notes
            
            Current.result.results[idx] = kpiResult
            LcRealm.commit()
        }
    }
    
    class func resetDependenciesWithKpi (_ kpi: TblJobKpi) {
        for val in kpi.valuations {
            for dep in val.dependencies {
                fixValuation(isValid: true, dep: dep)
            }
        }
    }
    
    class func updateWithResponse (_ response: KpiResponseValues!) {
        for dep in response.dependencies {
            fixValuation(isValid: false, dep: dep)
        }
    }
}


