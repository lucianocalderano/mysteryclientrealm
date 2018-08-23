//
//  SendJob.swift
//  MysteryClient
//
//  Created by Lc on 10/05/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import Foundation

class SendJob {
    private let fm = FileManager.default

    func createZipFileWithDict (_ dict: JsonDict) -> String {
        do {
            let json = try JSONSerialization.data(withJSONObject: dict,
                                                  options: .prettyPrinted)
            return writeJson(json)
        } catch {
        }
        return "JSONSerialization: error"
    }
    
    private func writeJson (_ json: Data) -> String {
        do {
            try json.write(to: URL.init(fileURLWithPath: MYJob.JobPath + Config.File.json))
            return readFiles ()

        } catch {
        }
        return "json.write: error"
    }

    private func readFiles () -> String {
        do {
            let filesToZip = try fm.contentsOfDirectory(at: URL.init(string: MYJob.JobPath)!,
                                                                includingPropertiesForKeys: nil,
                                                                options: [])
        
            return zipFiles(filesToZip)
        } catch {
        }
        return "contentsOfDirectory: error"
    }

    private func zipFiles (_ filesToZip: [URL]) -> String {
        let zipFile = URL.init(fileURLWithPath: MYZip.getZipFilePath(id: MYJob.current.id))
        if MYZip.zipFiles(filesToZip, toZipFile: zipFile) {
            return removeFiles()
        }
        return "zipFiles: error"
    }

    private func removeFiles () -> String {
        do {
            try fm.removeItem(atPath: MYJob.JobPath)
            MYJob.removeJobWithId(MYJob.current.id)
            MYResult.shared.removeResultWithId(MYJob.current.id)
            return ""
        } catch {
        }
        return "removeFiles: error"
    }
}
