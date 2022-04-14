//
//  EpicTimerModel.swift
//  Epic
//
//  Created by Gopal Rao Gurram on 1/25/21.
//  Copyright © 2021 Epic. All rights reserved.
//

import UIKit

@objc class EpicTimerModel: NSObject {

    init(with timeInterval: Double, delayStartingTimer: Bool = false, target: NSObject, andJob job: Selector, repeats: Bool = true, autoStartOnAppDidBecomeActive: Bool = false, appDidBecomeActiveCompletionBlock: AppDidBecomeActiveCompletionBlock? = nil, activeWhenAppWillResignActive: Bool = false, appWillResignActiveCompletionBlock: AppWillResignActiveCompletionBlock? = nil) {
        self.target = target
        self.job = job
        self.repeats = repeats
        self.timeInterval = timeInterval
        self.autoStartOnAppDidBecomeActive = autoStartOnAppDidBecomeActive
        self.activeWhenAppWillResignActive = activeWhenAppWillResignActive
        self.appWillResignActiveCompletionBlock = appWillResignActiveCompletionBlock
        self.appDidBecomeActiveCompletionBlock = appDidBecomeActiveCompletionBlock

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        if !delayStartingTimer {
            startTimer()
        }
    }

    deinit {
        internalTimer?.invalidate()
        internalTimer = nil
    }

    private(set) var internalTimer: Timer?
    private(set) var timeRemaining: Double = 0
    weak var target: NSObject?
    let job: Selector
    let repeats: Bool
    private var timeInterval: Double {
        didSet {
            if oldValue != timeInterval {
                startTimer()
            }
        }
    }
    var isActive: Bool {
        Self.isTimerActive(timer: self)
    }
    var isPaused: Bool {
        (internalTimer != nil) && (Int(timeRemaining) > 0)
    }

    let autoStartOnAppDidBecomeActive: Bool
    let activeWhenAppWillResignActive: Bool
    private var appWillResignActiveCompletionBlock: AppWillResignActiveCompletionBlock?
    private var appDidBecomeActiveCompletionBlock: AppDidBecomeActiveCompletionBlock?

    typealias AppWillResignActiveCompletionBlock = () -> Void
    typealias AppDidBecomeActiveCompletionBlock = () -> Void

    func updateTimeInterval(with interval: Double) {
        self.timeInterval = interval
    }

    static func isTimerActive(timer: EpicTimerModel?) -> Bool {
        guard let timer = timer, let internalTimer = timer.internalTimer else {
            return false
        }
        return internalTimer.isValid
    }

    func startTimer() {
        guard timeInterval > 0,
              let target = target
        else { return }

        stopTimer()
        internalTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: target, selector: job, userInfo: nil, repeats: repeats)
    }

    func resumeTimer() {
        guard internalTimer != nil,
              let target = target,
              Int(timeRemaining) > 0
        else { return }

        internalTimer = Timer.scheduledTimer(timeInterval: timeRemaining, target: target, selector: job, userInfo: nil, repeats: repeats)
    }

    func pauseTimer() {
        guard let internalTimer = internalTimer
        else { return }

        if isActive {
            timeRemaining = internalTimer.fireDate.timeIntervalSinceNow
        }

        internalTimer.invalidate()
    }

    func stopTimer() {
        guard internalTimer != nil else {
            return
        }

        internalTimer?.invalidate()
        internalTimer = nil
    }

    // MARK: Handling Timers based on App Life Cycle

    @objc fileprivate func appWillResignActive() {
        if let completionBlock = self.appWillResignActiveCompletionBlock {
            completionBlock()
        }

        if activeWhenAppWillResignActive { return }

        stopTimer()
    }

    @objc fileprivate func appDidBecomeActive() {
        if let completionBlock = self.appDidBecomeActiveCompletionBlock {
            completionBlock()
        }

        guard autoStartOnAppDidBecomeActive == true,
              EpicTimerModel.isTimerActive(timer: self) == false
              else { return }

        startTimer()
    }

    // MARK: helper Functions

    class func stopTimerModel(_ timerModel: inout EpicTimerModel?) {
        timerModel?.stopTimer()
        timerModel = nil
    }
}
