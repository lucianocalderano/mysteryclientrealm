//
//  MYZip.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import Zip

class MYZip {
    class func getZipFileName (id: Int) -> String {
        return "\(id)." + Config.File.zip
    }
    class func getZipFilePath (id: Int) -> String {
        return Config.Path.zip + MYZip.getZipFileName(id: id)
    }
    class func unzip(urlFile: URL, urlDest: URL) {
        try? Zip.unzipFile(urlFile, destination: urlDest, overwrite: true, password: nil)
    }
    
    class func removeZipWithId (_ id: Int) {
        do {
            try? FileManager.default.removeItem(atPath: MYZip.getZipFilePath(id: id))
        }
    }
    class func zipFiles (_ files: [URL], toZipFile zipFile: URL) -> Bool {
        do {
            try Zip.zipFiles(paths: files, zipFilePath: zipFile, password: nil, progress: nil)
            return true
        } catch  {
            print("Zip error")
        }
        return false
    }
}
