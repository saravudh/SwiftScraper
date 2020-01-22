//
//  WaitForConditionStep.swift
//  SwiftScraper
//
//  Created by Ken Ko on 28/04/2017.
//  Copyright © 2017 Ken Ko. All rights reserved.
//

import Foundation

/// Step that waits for condition to become true before proceeding,
/// failing if the condition is still false when timeout occurs.
public class WaitForConditionStep: Step {

    private enum Constants {
        static let refreshInterval: TimeInterval = 1.0
    }

    private var assertionName: String
    private var params: [Any]
    private var timeoutInSeconds: TimeInterval
    private var timer: Timer?

    private var startRunDate: Date?
    private weak var browser: Browser?
    private var model: JSON?
    private var completion: StepCompletionCallback?
    private let dispatchGroup = DispatchGroup()

    /// Initializer.
    ///
    /// - parameter assertionName: Name of JavaScript function that evaluates the conditions and returns a Boolean.
    /// - parameter timeoutInSeconds: The number of seconds before the step fails due to timeout.
    public init(assertionName: String, params: [Any] = [], timeoutInSeconds: TimeInterval) {
        self.params = params
        self.assertionName = assertionName
        self.timeoutInSeconds = timeoutInSeconds
    }

    public func run(with browser: Browser, model: JSON, completion: @escaping StepCompletionCallback) {
        startRunDate = Date()
        self.browser = browser
        self.model = model
        self.completion = completion
        timer = Timer.scheduledTimer(timeInterval: Constants.refreshInterval, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }

    @objc func handleTimer() {
        guard let startRunDate = startRunDate,
            let browser = browser,
            let model = model,
            let completion = completion else { return }
        browser.runScript(functionName: assertionName, params: params) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let ok):
                if ok as? Bool ?? false {
                   var htmlData = ""
                    if let webView = this.browser?.webView {
                        this.dispatchGroup.enter()
                        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                                   completionHandler: { (html: Any?, error: Error?) in
                                                    htmlData = (html as? String) ?? ""
                                                    this.dispatchGroup.leave()
                        })
                    }
                    this.dispatchGroup.notify(queue: .main) {
                        this.reset()
                        completion(.proceed(["html": htmlData]))
                    }
                } else {
                    if Date().timeIntervalSince(startRunDate) > this.timeoutInSeconds {
                        this.reset()
                        completion(.failure(SwiftScraperError.timeout, model))
                    }
                }
            case .failure(let error):
                this.reset()
                completion(.failure(error, model))
            }
        }
    }

    private func reset() {
        timer?.invalidate()
        timer = nil
        startRunDate = nil
        browser = nil
        model = nil
        completion = nil
    }
}
