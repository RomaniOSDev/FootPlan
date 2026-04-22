//
//  SaveService.swift
//  FootPlan
//

import Foundation

struct FootPlanBookmarkSink {
    static var storedHTTPBookmark: URL? {
        get { UserDefaults.standard.url(forKey: FootPlanRouterOpaqueText.userDefaultsLastUrlKey) }
        set { UserDefaults.standard.set(newValue, forKey: FootPlanRouterOpaqueText.userDefaultsLastUrlKey) }
    }
}
