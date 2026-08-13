//
//  CallbackResult.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 06/05/22.
//

import Foundation

public class CallbackResult<T>: MethodChannelResult {
    private let resultLock = NSLock()
    private var notImplementedHandler: () -> Void = {}
    private var successHandler: (Any?) -> Void = {_ in }
    private var errorHandler: (String, String?, Any?) -> Void = {_,_,_ in }
    public var nonNullSuccess: (T) -> Bool = {_ in true}
    public var nullSuccess: () -> Bool = {true}
    public var decodeResult: (Any?) -> T? = {_ in nil}

    private var defaultBehaviourHandler: (T?) -> Void = {_ in }
    private var callbackCompleted = false
    private var defaultBehaviourCompleted = false
    private var defaultBehaviourAllowedDuringHandler = false

    public var notImplemented: () -> Void {
        get {
            return { [weak self] in
                _ = self?.completeNotImplemented()
            }
        }
        set {
            resultLock.lock()
            notImplementedHandler = newValue
            resultLock.unlock()
        }
    }

    public var success: (Any?) -> Void {
        get {
            return { [weak self] result in
                _ = self?.completeSuccess(result)
            }
        }
        set {
            resultLock.lock()
            successHandler = newValue
            resultLock.unlock()
        }
    }

    public var error: (String, String?, Any?) -> Void {
        get {
            return { [weak self] code, message, details in
                _ = self?.completeError(code, message: message, details: details)
            }
        }
        set {
            resultLock.lock()
            errorHandler = newValue
            resultLock.unlock()
        }
    }

    public var defaultBehaviour: (T?) -> Void {
        get {
            return { [weak self] result in
                _ = self?.completeDefaultBehaviour(result)
            }
        }
        set {
            resultLock.lock()
            defaultBehaviourHandler = newValue
            resultLock.unlock()
        }
    }

    @discardableResult
    public func completeSuccess(_ result: Any?) -> Bool {
        let handler: (Any?) -> Void
        resultLock.lock()
        if callbackCompleted {
            resultLock.unlock()
            return false
        }
        callbackCompleted = true
        defaultBehaviourAllowedDuringHandler = true
        handler = successHandler
        resultLock.unlock()
        handler(result)
        resultLock.lock()
        defaultBehaviourAllowedDuringHandler = false
        resultLock.unlock()
        return true
    }

    @discardableResult
    public func completeError(_ code: String, message: String?, details: Any?) -> Bool {
        let handler: (String, String?, Any?) -> Void
        resultLock.lock()
        if callbackCompleted {
            resultLock.unlock()
            return false
        }
        callbackCompleted = true
        defaultBehaviourAllowedDuringHandler = true
        handler = errorHandler
        resultLock.unlock()
        handler(code, message, details)
        resultLock.lock()
        defaultBehaviourAllowedDuringHandler = false
        resultLock.unlock()
        return true
    }

    @discardableResult
    public func completeNotImplemented() -> Bool {
        let handler: () -> Void
        resultLock.lock()
        if callbackCompleted {
            resultLock.unlock()
            return false
        }
        callbackCompleted = true
        defaultBehaviourAllowedDuringHandler = true
        handler = notImplementedHandler
        resultLock.unlock()
        handler()
        resultLock.lock()
        defaultBehaviourAllowedDuringHandler = false
        resultLock.unlock()
        return true
    }

    @discardableResult
    public func completeDefaultBehaviour(_ result: T?) -> Bool {
        let handler: (T?) -> Void
        resultLock.lock()
        if defaultBehaviourCompleted ||
            (callbackCompleted && !defaultBehaviourAllowedDuringHandler) {
            resultLock.unlock()
            return false
        }
        defaultBehaviourCompleted = true
        callbackCompleted = true
        handler = defaultBehaviourHandler
        resultLock.unlock()
        handler(result)
        return true
    }
}
