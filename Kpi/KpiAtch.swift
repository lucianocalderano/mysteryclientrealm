//
//  KpiAtch.swift
//  MysteryClient
//
//  Created by Lc on 12/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit
import Photos

protocol KpiAtchDelegate {
    func kpiAtchSelectedImage(withData data: Data)
}

class KpiAtch: NSObject {
    var mainVC: UIViewController
    var delegate: KpiAtchDelegate?
    
    init(mainViewCtrl: UIViewController) {
        mainVC = mainViewCtrl
    }
    
    func showArchSelection () {
        let alert = UIAlertController(title: Lng("uploadPic") as String,
                                      message: "" as String,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: Lng("picFromCam"),
                                           style: .default,
                                           handler: { (action) in
                                            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction.init(title: Lng("picFromGal"),
                                           style: .default,
                                           handler: { (action) in
                                            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: Lng("cancel"),
                                           style: .cancel,
                                           handler: { (action) in
        }))
        
        mainVC.present(alert, animated: true) { }
    }
    
    //MARK:- Image picker
    
    private func openGallary() {
        presentPicker(type: .photoLibrary)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable (.camera) else {
            let alert = UIAlertController(title: "Camera Not Found",
                                          message: "This device has no Camera",
                                          preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            mainVC.present(alert, animated: true, completion: nil)
            return
        }
        MYGps.shared.start()
        presentPicker(type: .camera)
    }
    
    private func presentPicker (type: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = type
        picker.allowsEditing = false
        if type == .camera {
            picker.cameraCaptureMode = .photo
        }
        let wheel = MYWheel()
        wheel.start(mainVC.view)
        mainVC.present(picker, animated: true) {
            wheel.stop()
        }
    }
    
    private func close () {
        mainVC.dismiss(animated: true, completion: nil)
    }
}

//MARK:-

extension KpiAtch: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        close()
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        var coo = MYGps.shared.currentGps
        var dat = Date()
        if picker.sourceType != .camera {
            if let URL = info[UIImagePickerControllerReferenceURL] as? URL {
                let opts = PHFetchOptions()
                opts.fetchLimit = 1
                if let asset = PHAsset.fetchAssets(withALAssetURLs: [URL], options: opts).firstObject {
                    dat = asset.creationDate ?? Date();
                    coo = asset.location?.coordinate ?? MYGps.shared.currentGps
                }
            }
        }
        
        let resizedImage = pickedImage.resize(CGFloat(Config.maxPicSize))!
        let resizedData = NSMutableData(data: UIImageJPEGRepresentation(resizedImage, 0.7)!)
        let resizedSource = CGImageSourceCreateWithData(resizedData as CFData, nil)
        let resizedExif = CGImageSourceCopyPropertiesAtIndex(resizedSource!, 0, nil)! as NSDictionary
        
        let finalExif = NSMutableDictionary.init(dictionary: resizedExif)
        
        let gpsDict = [
            kCGImagePropertyGPSLatitude     : fabs(coo.latitude),
            kCGImagePropertyGPSLongitude    : fabs(coo.longitude),
            kCGImagePropertyGPSLatitudeRef  : coo.latitude < 0.0 ? "S" : "N",
            kCGImagePropertyGPSLongitudeRef : coo.longitude < 0.0 ? "W" : "E",
            kCGImagePropertyGPSTimeStamp    : dat.toString(withFormat: "HH:mm:ss"),
            kCGImagePropertyGPSDateStamp    : dat.toString(withFormat: "yyyy-MM-dd"),
            ] as [CFString : Any]
        finalExif.setValue(gpsDict, forKey: kCGImagePropertyGPSDictionary as String)
        
        let uti = CGImageSourceGetType(resizedSource!)
        let destination = CGImageDestinationCreateWithData(resizedData as CFMutableData, uti!, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, resizedSource!, 0, (finalExif as CFDictionary?))
        CGImageDestinationFinalize(destination)
        self.delegate?.kpiAtchSelectedImage(withData: resizedData as Data)
        close()
    }
}
