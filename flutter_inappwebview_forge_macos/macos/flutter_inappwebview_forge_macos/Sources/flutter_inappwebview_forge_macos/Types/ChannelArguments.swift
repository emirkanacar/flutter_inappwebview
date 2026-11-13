//
//  ChannelArguments.swift
//  flutter_inappwebview_forge_macos
//
//  Method-channel arguments are untrusted, versioned input. Read required
//  values without force-unwrapping so a missing or mistyped argument completes
//  the call with an "invalid_arguments" FlutterError instead of crashing.
//

import Foundation
import FlutterMacOS

struct ChannelArgumentError: Error {
    let key: String
    let expectedType: String
}

/// Returns the required argument `key` cast to `T`, or throws
/// `ChannelArgumentError` when it is missing, null, or of another type.
func requiredArgument<T>(_ arguments: Any?, _ key: String, as type: T.Type = T.self) throws -> T {
    guard let value = (arguments as? NSDictionary)?[key] as? T else {
        throw ChannelArgumentError(key: key, expectedType: String(describing: T.self))
    }
    return value
}

/// Maps an error thrown while reading arguments to the FlutterError returned
/// to the Dart caller.
func invalidArgumentsError(_ error: Error, method: String) -> FlutterError {
    if let argumentError = error as? ChannelArgumentError {
        return FlutterError(
            code: "invalid_arguments",
            message: "\(method): argument '\(argumentError.key)' is missing or is not \(argumentError.expectedType).",
            details: nil)
    }
    return FlutterError(code: "invalid_arguments", message: "\(method): \(error.localizedDescription)", details: nil)
}
