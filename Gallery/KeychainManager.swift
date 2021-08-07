//
//  KeychainManager.swift
//  Gallery
//
//  Created by Володя on 07.08.2021.
//

import Foundation
import SwiftyKeychainKit

class KeychainManager {
    static let shared = KeychainManager()
    private init() { }
    
    private let keychain = Keychain(service: "oleyarr.keychain")
    private let passwordkey = KeychainKey<String>(key: "pass")
    
    func savePassword(_ password: String) {
        do {
            try keychain.set(password, for: passwordkey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func validatePassword(_ password: String) -> Bool {
        do {
            let passString = try keychain.get(passwordkey)
            if passString == password {
                return true
            }
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    func clearPassword() {
        do {
            try keychain.removeAll()
        } catch {
            print(error.localizedDescription)
        }
    }
}
