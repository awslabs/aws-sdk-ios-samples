//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSPinpoint
import Foundation

class AnalyticsEventTimer {
    private enum State {
        case suspended
        case resumed
    }

    let analyticsClient: AWSPinpointAnalyticsClient

    private var state: State = .suspended

    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: .seconds(10))
        timer.setEventHandler(handler: { [weak self] in
            print("--- timer was triggered")
            if let ref = self {
                ref.analyticsClient.submitEvents(completionBlock: ref.onEventSubmissionComplete)
            }
        })
        return timer
    }()

    init(analyticsClient: AWSPinpointAnalyticsClient) {
        self.analyticsClient = analyticsClient
    }

    deinit {
        self.cancel()
        timer.setEventHandler {}
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }

    func cancel() {
        if state == .suspended {
            timer.resume()
        }
        timer.cancel()
    }

    private func onEventSubmissionComplete(task: AWSTask<AnyObject>) -> Any? {
        return task.continueWith { ref in
            if ref.error?.localizedDescription == "No events to submit." {
                return nil
            }
            print("============================================")
            print("Pinpoint event submission task is complete...")
            print("  isComplete: \(ref.isCompleted)")
            print("  isCancelled: \(ref.isCancelled)")
            print("  result: \(String(describing: ref.result))")
            print("  error: \(String(describing: ref.error))")
            //            if let error = t.error {
            //                Thread.callStackSymbols.forEach { print($0) }
            //            }
            return ref.result
        }
    }
}
