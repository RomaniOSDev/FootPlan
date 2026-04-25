//
//  PersistenceManager.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let savedUrlKey = PersistenceStringCodec.decode([76, 97, 115, 116, 85, 114, 108])
    private let hasShownContentViewKey = PersistenceStringCodec.decode([72, 97, 115, 83, 104, 111, 119, 110, 67, 111, 110, 116, 101, 110, 116, 86, 105, 101, 119])
    private let hasSuccessfulWebViewLoadKey = PersistenceStringCodec.decode([72, 97, 115, 83, 117, 99, 99, 101, 115, 115, 102, 117, 108, 87, 101, 98, 86, 105, 101, 119, 76, 111, 97, 100])
    
    var savedUrl: String? {
        get {
            // Синхронизация с SaveService для обратной совместимости
            if let url = SaveService.lastUrl {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: savedUrlKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: savedUrlKey)
                // Синхронизация с SaveService
                if let url = URL(string: urlString) {
                    SaveService.lastUrl = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: savedUrlKey)
                SaveService.lastUrl = nil
            }
        }
    }
    
    var hasShownContentView: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasShownContentViewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasShownContentViewKey)
        }
    }
    
    var hasSuccessfulWebViewLoad: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSuccessfulWebViewLoadKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSuccessfulWebViewLoadKey)
        }
    }
    
    private init() {}
}

private enum PersistenceStringCodec {
    static func decode(_ bytes: [UInt8]) -> String {
        String(decoding: bytes, as: UTF8.self)
    }
}
