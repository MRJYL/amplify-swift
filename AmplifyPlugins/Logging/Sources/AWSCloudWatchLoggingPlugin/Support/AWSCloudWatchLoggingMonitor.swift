//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

class AWSCLoudWatchLoggingMonitor {
    private let automaticFlushLogsInterval: TimeInterval
    private var automaticFlushLogsTimer: DispatchSourceTimer? {
        willSet {
            automaticFlushLogsTimer?.cancel()
        }
    }
    
    private weak var eventDelegate: AWSCloudWatchLoggingMonitorDelegate?
    
    init(flushIntervalInSeconds: TimeInterval, eventDelegate: AWSCloudWatchLoggingMonitorDelegate?) {
        self.automaticFlushLogsInterval = flushIntervalInSeconds
        self.eventDelegate = eventDelegate
    }

    func setAutomaticFlushIntervals() {
        guard automaticFlushLogsInterval != .zero else {
            automaticFlushLogsTimer = nil
            return
        }
        
        automaticFlushLogsTimer = Self.createRepeatingTimer(
            timeInterval: automaticFlushLogsInterval,
            eventHandler: { [weak self] in
                guard let self = self else { return }
                self.eventDelegate?.handleAutomaticFlushIntervalEvent()
        })
        automaticFlushLogsTimer?.resume()
    }

    static func createRepeatingTimer(timeInterval: TimeInterval,
                                     eventHandler: @escaping () -> Void) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        timer.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
        timer.setEventHandler(handler: eventHandler)
        return timer
    }
}

public protocol AWSCloudWatchLoggingMonitorDelegate: AnyObject {
    func handleAutomaticFlushIntervalEvent()
}
