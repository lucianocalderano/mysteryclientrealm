//
//  User.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

class User: NSObject {
    static let shared = User()
    
    private let userKey = "userKey"
    private let kUsr = "keyUser"
    private let kPwd = "keyPass"
    private let kSav = "keySave"
    private let kTkn = "keyToken"
    
    var userData = [String: String]()
    var token: String {
        get {
            let tkn = userData[kTkn]!
            return tkn.isEmpty ? tkn : "Bearer " + tkn
        }
    }
    
    override init() {
        super.init()
        userData[kUsr] = ""
        userData[kPwd] = ""
        userData[kSav] = ""
        userData[kTkn] = ""

        let userDefault = UserDefaults.standard
        if let user = userDefault.dictionary(forKey: userKey) {
            userData = user as! [String : String]
        }
    }

    private func saveUserData () {
        let userDefault = UserDefaults.standard
        userDefault.set(userData, forKey: userKey)
    }
    
    func credential () -> (user: String, pass: String) {
        if userData[kSav] != "1" {
            return ("", "")
        }
        return (userData[kUsr]!, userData[kPwd]!)
    }
    
    func logout() {
        userData[kTkn] = ""
        saveUserData()
    }
    
    func checkUser (saveCredential: Bool, userName: String, password: String,
                    completion: @escaping () -> () = { () in },
                    failure: @escaping (String, String) -> () = { (errorCode, message) in }) {
        userData[kUsr] = userName
        userData[kPwd] = password
        userData[kSav] = saveCredential ? "1" : "0"
        userData[kTkn] = ""
        saveUserData()
        
        getUserToken(completion: {
            completion()
        }) {
            (errorCode, message) in
            failure(errorCode, message)
        }
    }
    
    func getUserToken(completion: @escaping () -> (), failure: @escaping (String, String) -> ()) {
        var version = "?"
        if let vers = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            version = vers
        }
        
        let param = [
            "grant_type"    : "password",
            "client_id"     : "mystery_app",
            "client_secret" : "UPqwU7vHXGtHk6JyXrA5",
            "version"       : "i" + version,
            "username"      : userData[kUsr]!,
            "password"      : userData[kPwd]!,
        ]

        let req = MYHttp.init(.grant, param: param, showWheel: false, hasHeader: false)
        req.load( { (response) in
            self.tokenWithDict(response.dictionary("token"))
            completion()
        }) {
            (code, error) in
            failure(code, error)
        }
    }
    
    private func tokenWithDict (_ dict: JsonDict) {
        let token = dict.string("access_token")
        print ("\ntoken: " + token)
        userData[kTkn] = token
        saveUserData()
    }
}
