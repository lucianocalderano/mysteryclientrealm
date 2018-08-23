//
//  MYLang.swift
//  Lc
//
//  Created by Luciano Calderano on 09/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import Foundation

typealias LangDict = [String: String]

public extension String {
    func toLang() -> String {
        var s = self as String
        guard s.count > 0 else {
            return ""
        }
        if s.left(lenght: 1) == "#" {
            s = MYLang.value(s.mid(startAtChar: 2, lenght: s.count - 1))
        }
        return s
    }
}

public class MYLang {
    public static func value (_ key: String) -> String {
        return MYLang.shared.getValue (key: key)
    }
    public static func setup (langListCodes l: [String], langFileName f: String) {
        MYLang.shared.setup(langListCodes: l, langFileName: f)
    }

    public static let shared = MYLang()
    
    public func setLanguage(code: String) {
        var selectedLangIdx = 0
        if let idx = langList.index(of: code) {
            selectedLangIdx = idx
        }
        dict = loadLanguage(index: selectedLangIdx)
    }
    
    func getValue(key: String) -> String {
        if let value = dict[key] {
            let newLine = "\\n"
            if value.range(of: newLine) != nil {
                return value.replacingOccurrences(of: newLine, with: "\n")
            }
            return value
        }
        return "[Key:" + key + "?]"
    }

    //MARK:- private
    
    private var langList = [""]
    private var fileName =  ""
    private var dict = LangDict()

    private func setup (langListCodes l: [String], langFileName f: String) {
        langList = l
        fileName = f

        let lng = selectLanguageFromDevice()
        setLanguage(code: lng)
    }

    private func selectLanguageFromDevice() -> String {
        var strIso = Locale.current.identifier
        if (strIso.count < 2) {
            strIso = Bundle.main.preferredLocalizations.first!
        }
        else if (strIso.count > 2) {
            strIso = strIso.left(lenght: 2)
        }
        return strIso
    }
    
    private func loadLanguage(index: Int) -> LangDict {
        let arr = fileName.components(separatedBy: ".")
        if arr.count != 2 {
            return [:]
        }
        let filePath = Bundle.main.path(forResource: arr.first, ofType: arr.last)
        
        let str = try? String(contentsOfFile: filePath!, encoding: String.Encoding.utf8) as String
        let array = (str?.components(separatedBy: "\n"))! as [String]
        var dic = [String: String]()
        
        for s in array {
            let riga = s.components(separatedBy: "=")
            guard riga.count == 2 else {
                continue
            }
            let valuesArray = riga[1].components(separatedBy: "|") as [String]
            guard valuesArray.count == langList.count else {
                continue
            }
            dic[riga[0]] = valuesArray[index]
        }
        return dic
    }
}

//
//class MYLang {
//    public struct Config {
//        static var languagesList = [ "it" ]
//        static var fileName = ""
//    }
//
//    static var dict = LangDict()
//    static var selectedLangIdx = 0
//
//    static var langId: String {
//        get {
//            return MYLang.getKey("id")
//        }
//    }
//    static var langCode: String {
//        get {
//            return MYLang.getKey("code")
//        }
//    }
//    class func key (_ key: String) -> String {
//        return Lng(key)
//    }
//    class func getKey (_ key: String) -> String {
//        let key = "Language"
//        let dict = UserDefaults.standard.value(forKey: key) as? LangDict
//        if dict == nil {
//            return ""
//        }
//        return dict!.string(key)
//    }
//
//    class func saveLanguageList (_ array: [LangDict]) {
//        let key = "Language"
//        UserDefaults.standard.set(array, forKey: "LanguagesArray")
//        for dict in array {
//            let langDict = dict.dictionary(key)
//            let iso = langDict.string("iso")
//            let idx = Config.languagesList.contains(iso)
//            if idx {
//                UserDefaults.standard.set(langDict, forKey: key)
//                break
//            }
//        }
//    }
//}
//
//class LanguageClass {
//    class func open () {
//        let lng = LanguageClass().selectLanguageFromDevice()
//        MYLang.selectedLangIdx = 0
//        if let idx = MYLang.Config.languagesList.index(of: lng) {
//            MYLang.selectedLangIdx = idx
//        }
//       MYLang.dict = LanguageClass().loadLanguage(index: MYLang.selectedLangIdx)
//    }
//
//    init() {
////        let selectLanguageSEL = #selector(selectLanguage)
////        NotificationCenter.default.addObserver(self,
////                                               selector: selectLanguageSEL,
////                                               name: UserDefaults.didChangeNotification,
////                                               object: nil)
//    }
//
//    deinit {
////        NotificationCenter.default.removeObserver(self)
//    }
//
////    @objc func selectLanguage() {
////        switch UserDefaults.standard.string(forKey: "settings.langId") ?? "" {
////        case LanguageType.en.rawValue:
////            LanguageConfig.currentLanguage =  LanguageType.en
////        case LanguageType.it.rawValue:
////            LanguageConfig.currentLanguage =  LanguageType.it
////        default:
////            LanguageConfig.currentLanguage = self.selectLanguageFromDevice()
////        }
////        LanguageConfig.dict = self.loadLanguage(languageType: LanguageConfig.currentLanguage)
////    }
//
//    private func loadLanguage(index: Int) -> LangDict {
//        let arr = MYLang.Config.fileName.components(separatedBy: ".")
//        if arr.count != 2 {
//            return [:]
//        }
//        let filePath = Bundle.main.path(forResource: arr.first, ofType: arr.last)
//
//        let str = try? String(contentsOfFile: filePath!, encoding: String.Encoding.utf8) as String
//        let array = (str?.components(separatedBy: "\n"))! as [String]
//        var dic = [String: String]()
//
//        for s in array {
//            let riga = s.components(separatedBy: "=")
//            guard riga.count == 2 else {
//                continue
//            }
//            let valuesArray = riga[1].components(separatedBy: "|") as [String]
//            guard valuesArray.count == MYLang.Config.languagesList.count else {
//                continue
//            }
//            dic[riga[0]] = valuesArray[index]
//        }
//        return dic
//    }
//
//    private func selectLanguageFromDevice() -> String {
//        var strIso = Locale.current.identifier
//        if (strIso.count < 2) {
//            strIso = Bundle.main.preferredLocalizations.first!
//        }
//        else if (strIso.count > 2) {
//            strIso = strIso.left(lenght: 2)
//        }
//        return strIso
//    }
//}

