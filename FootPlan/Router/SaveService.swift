//
//  SaveService.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

struct SaveService {
    
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: KeyVault.lastURLKey) }
        set { UserDefaults.standard.set(newValue, forKey: KeyVault.lastURLKey) }
    }
}

private enum KeyVault {
    static let lastURLKey = String(decoding: [76, 97, 115, 116, 85, 114, 108], as: UTF8.self)
}
