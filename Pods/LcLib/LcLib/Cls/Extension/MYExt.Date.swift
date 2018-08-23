//
//  ExtDate.swift
//  Lc
//
//  Created by Luciano Calderano on 09/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import Foundation

public extension String {
    func toDate(withFormat fmt: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = fmt
        return df.date(from: self)!
    }

    func dateConvert(fromFormat fmtIn: String, toFormat fmtOut: String) -> String {
        let d = self.toDate(withFormat: fmtIn)
        return d.toString(withFormat: fmtOut)
    }
}

public extension Date {
    func toString(withFormat fmt: String) -> String {
        let df = DateFormatter()
        df.dateFormat = fmt
        return df.string(from: self)
    }
}
