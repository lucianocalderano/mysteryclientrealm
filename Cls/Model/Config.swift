//
//  Config.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//
// git: mcappios@git.mebius.it:projects/mcappios - Pw: Mc4ppIos
// web: mysteryclient.mebius.it - User: utente_gen - Pw: novella44

import Foundation
import LcLib

typealias JsonDict = Dictionary<String, Any>
func Lng(_ key: String) -> String {
    return MYLang.value(key)
}

struct Config {
    struct Url {
        static let home  = "https://mysteryclient.mebius.it/"
        static let grant = Config.Url.home + "default/oauth/grant"
        static let get   = Config.Url.home + "default/rest/get"
        static let put   = Config.Url.home + "default/rest/put"
        static let maps  = "http://maps.apple.com/?"
    }

    struct File {
        static let json = "job.json"
        static let zip = "zip"
        static let plist = "plist"
        static let idPrefix = "id_"
        static let urlPrefix = "file://"
    }

    struct Path {
        static let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
        static let jobs = Config.Path.docs + "jobs/"
        static let result = Config.Path.docs + "result/"
        static let zip = Config.Path.docs + "zip/"
    }

    struct DateFmt {
        static let Ora           = "HH:mm"
        static let DataJson      = "yyyy-MM-dd"
        static let DataOraJson   = "yyyy-MM-dd HH:mm:ss"
        static let Data          = "dd/MM/yyyy"
        static let DataOra       = "dd/MM/yyyy HH:mm"
    }

    static let maxPicSize = 1200
}
