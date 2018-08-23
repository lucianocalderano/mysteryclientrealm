//
//  MYHttp.swift
//  MysteryClient
//
//  Created by mac on 17/08/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import Alamofire
import UserNotifications

class MYUpload {
    class func startUpload() {
        return
        let me = MYUpload()
        
        do {
            let zipPath = URL.init(string: Config.Path.zip)!
            let files = try FileManager.default.contentsOfDirectory(at: zipPath,
                                                                    includingPropertiesForKeys: nil,
                                                                    options:[])
            for file in files {
                if file.pathExtension != Config.File.zip {
                    continue
                }
                let data = try Data.init(contentsOf: file, options: .mappedIfSafe)
                let id = file.deletingPathExtension().lastPathComponent
                me.start(jobId: id, data: data)
            }
        }
        catch {
            print("startUpload: error")
        }
    }
    
    private func start (jobId: String, data: Data) {
        let id = Int(jobId)!
        let url = URL.init(string: Config.Url.put)!
        let headers = [
            "Authorization" : User.shared.token
        ]
        
        let request: URLRequest!
        do {
            let req = try URLRequest(url: url, method: .post, headers: headers)
            request = req
        }
        catch {
            print("start: URLRequest error")
            return
        }
        
        Alamofire.upload(multipartFormData: {
            (formData) in
            formData.append(data,
                            withName: "object_file",
                            fileName:  Config.File.idPrefix + MYZip.getZipFileName(id: id),
                            mimeType: "multipart/form-data")
            
            let json = [
                "object"        : "job",
                "object_id"     : jobId,
                ]
            
            for (key, value) in json {
                formData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, with: request, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    (response) in
                    if let JSON = response.result.value {
                        print("Upload: Response.JSON: \(JSON)")
                        MYZip.removeZipWithId(id)
                        self.done(id: id)
                    }
                }
            case .failure(let encodingError):
                self.error(id: id, err: encodingError.localizedDescription)
                print(encodingError)
            }
        })
    }
    
    private func done(id: Int) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Invio avvenuto"
            content.subtitle = "Incarico n. \(id)"
            content.body = "La trasmisisone dell'incarico n. \(id) è avvenuta corretamente"
            content.badge = 1
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "MysteryClientJobSent", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    private func error(id: Int, err: String) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Errore"
            content.subtitle = "Incarico n. \(id)"
            content.body = "La trasmisisone dell'incarico n. \(id) ha dato il eguente errore: \(err)"
            content.badge = 1
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "MysteryClientJobSent", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

