import UIKit
import XCTest

@testable import flutter_inappwebview_forge_ios

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testPluginModuleLoads() {
    XCTAssertEqual(
      String(describing: InAppWebViewFlutterPlugin.self),
      "InAppWebViewFlutterPlugin"
    )
  }

}
