//
//  ExtString.swift
//  Lc
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import Foundation

public extension String {
    func left (lenght l: Int) -> String {
        let fine = l < self.count ? l : self.count
        return range(0, fine: fine)
    }

    func mid (startAtChar iniz: Int, lenght l: Int) -> String {
        let i = iniz < 1 ? 0 : iniz - 1
        var fine = i + l
        if fine >= self.count { fine = self.count }
        return range(i, fine: fine)
    }

    func right (lenght: Int) -> String {
        var iniz = self.count - lenght;
        if iniz < 0 { iniz = 0 }
        let fine = self.count
        return range(iniz, fine: fine)
    }
    
    private func range (_ iniz: Int, fine: Int) -> String {
        let ini = self.index(self.startIndex, offsetBy: iniz)
        let end = self.index(self.startIndex, offsetBy: fine)
        let s = self[ini..<end]
        return String(s)
    }

}
