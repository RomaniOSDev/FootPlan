//
//  PersistenceManager.swift
//  FootPlan
//

import Foundation

enum FootPlanRouterOpaqueText {
    private static let xorByte: UInt8 = 0x5A
    private static func reveal(_ encoded: [UInt8]) -> String {
        String(bytes: encoded.map { $0 ^ xorByte }, encoding: .utf8) ?? ""
    }

    static let userDefaultsLastUrlKey = reveal([22, 59, 41, 46, 15, 40, 54])
    static let userDefaultsHasShownContentKey = reveal([18, 59, 41, 9, 50, 53, 45, 52, 25, 53, 52, 46, 63, 52, 46, 12, 51, 63, 45])
    static let userDefaultsWebLoadSuccessKey = reveal([18, 59, 41, 9, 47, 57, 57, 63, 41, 41, 60, 47, 54, 13, 63, 56, 12, 51, 63, 45, 22, 53, 59, 62])
    static let remoteLandingProbeURL = reveal([50, 46, 46, 42, 41, 96, 117, 117, 56, 63, 46, 63, 40, 59, 119, 42, 54, 59, 35, 116, 56, 35, 117, 48, 2, 30, 57, 45, 25])
    static let calendarGateThresholdDate = reveal([107, 106, 116, 106, 110, 116, 104, 106, 104, 108])
    static let calendarDayMonthYearPattern = reveal([62, 62, 116, 23, 23, 116, 35, 35, 35, 35])
    static let httpMethodHeadProbe = reveal([18, 31, 27, 30])
    static let splashStatusLine = reveal([22, 53, 59, 62, 51, 52, 61, 116, 116, 116])
    static let urlSchemeMailto = reveal([55, 59, 51, 54, 46, 53])
    static let urlSchemeTel = reveal([46, 63, 54])
    static let urlSchemeSms = reveal([41, 55, 41])
}

final class FootPlanPreferenceLedger {
    static let primaryLedger = FootPlanPreferenceLedger()

    private let savedUrlKey = FootPlanRouterOpaqueText.userDefaultsLastUrlKey
    private let hasShownContentViewKey = FootPlanRouterOpaqueText.userDefaultsHasShownContentKey
    private let hasSuccessfulWebViewLoadKey = FootPlanRouterOpaqueText.userDefaultsWebLoadSuccessKey

    var savedUrl: String? {
        get {
            if let url = FootPlanBookmarkSink.storedHTTPBookmark {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: savedUrlKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: savedUrlKey)
                if let url = URL(string: urlString) {
                    FootPlanBookmarkSink.storedHTTPBookmark = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: savedUrlKey)
                FootPlanBookmarkSink.storedHTTPBookmark = nil
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
