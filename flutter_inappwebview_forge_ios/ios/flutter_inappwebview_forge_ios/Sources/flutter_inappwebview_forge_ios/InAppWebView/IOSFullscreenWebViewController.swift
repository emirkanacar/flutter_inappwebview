//
//  IOSFullscreenWebViewController.swift
//  flutter_inappwebview_forge_ios
//

import UIKit

/// Presents the existing WKWebView in a full-screen UIKit container.
///
/// The web view is moved out of its Flutter platform-view hierarchy and put
/// back in the exact same position when the presentation ends. Keeping the
/// WKWebView instance alive avoids the iOS 26 WebKit fullscreen surface that
/// can become stale after a media seek.
final class IOSFullscreenWebViewController: UIViewController {
    private weak var webView: InAppWebView?
    private var originalSuperview: UIView?
    private var originalSubviewIndex = 0
    private var originalFrame = CGRect.zero
    private var originalAutoresizingMask: UIView.AutoresizingMask = []
    private var originalTranslatesAutoresizingMaskIntoConstraints = true
    private var originalConstraints: [NSLayoutConstraint] = []
    private var fullscreenConstraints: [NSLayoutConstraint] = []
    private var didCaptureViewState = false
    private var didRestoreWebView = false
    private var didStartDismissal = false
    private var didNotifyDismissed = false
    private var didNotifyPresented = false

    var onPresented: ((IOSFullscreenWebViewController) -> Void)?
    var onPresentationFailed: ((IOSFullscreenWebViewController) -> Void)?
    var onRequestDismiss: (() -> Void)?
    var onDismissed: ((IOSFullscreenWebViewController) -> Void)?

    init(webView: InAppWebView) {
        self.webView = webView
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .coverVertical
        didCaptureViewState = captureViewState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let fullscreenView = UIView(frame: UIScreen.main.bounds)
        fullscreenView.backgroundColor = .black
        view = fullscreenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let webView = webView, didCaptureViewState else {
            onPresentationFailed?(self)
            return
        }

        webView.removeFromSuperview()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        fullscreenConstraints = [
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(fullscreenConstraints)
        addCloseButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didNotifyPresented else { return }
        guard webView != nil, didCaptureViewState else { return }
        didNotifyPresented = true
        onPresented?(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !didNotifyPresented && !didStartDismissal {
            onPresentationFailed?(self)
        } else if didStartDismissal || isBeingDismissed || presentingViewController == nil {
            finishDismissalIfNeeded()
        }
    }

    func dismissFullscreen(animated: Bool) {
        guard !didStartDismissal else { return }
        didStartDismissal = true
        onRequestDismiss?()
        restoreWebView()

        if presentingViewController != nil {
            dismiss(animated: animated) { [weak self] in
                self?.finishDismissalIfNeeded()
            }
        } else {
            finishDismissalIfNeeded()
        }
    }

    func dismissWithoutCallback() {
        didStartDismissal = true
        restoreWebView()
        dismiss(animated: false, completion: nil)
        didNotifyDismissed = true
    }

    private func captureViewState() -> Bool {
        guard let webView = webView, let superview = webView.superview else {
            return false
        }

        originalSuperview = superview
        originalSubviewIndex = superview.subviews.firstIndex(of: webView) ?? superview.subviews.count
        originalFrame = webView.frame
        originalAutoresizingMask = webView.autoresizingMask
        originalTranslatesAutoresizingMaskIntoConstraints = webView.translatesAutoresizingMaskIntoConstraints
        originalConstraints = superview.constraints.filter { constraint in
            (constraint.firstItem as AnyObject?) === webView ||
            (constraint.secondItem as AnyObject?) === webView
        }
        NSLayoutConstraint.deactivate(originalConstraints)
        return true
    }

    private func restoreWebView() {
        guard !didRestoreWebView, let webView = webView else { return }
        didRestoreWebView = true

        NSLayoutConstraint.deactivate(fullscreenConstraints)
        webView.removeFromSuperview()
        webView.translatesAutoresizingMaskIntoConstraints = originalTranslatesAutoresizingMaskIntoConstraints
        webView.autoresizingMask = originalAutoresizingMask
        webView.frame = originalFrame

        guard let originalSuperview = originalSuperview else { return }
        let index = min(originalSubviewIndex, originalSuperview.subviews.count)
        originalSuperview.insertSubview(webView, at: index)
        NSLayoutConstraint.activate(originalConstraints)
    }

    private func finishDismissalIfNeeded() {
        guard !didNotifyDismissed else { return }
        didNotifyDismissed = true
        restoreWebView()
        onDismissed?(self)
    }

    private func addCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        closeButton.layer.cornerRadius = 8
        closeButton.accessibilityLabel = "Close fullscreen video"
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
            closeButton.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    @objc private func closeButtonTapped() {
        dismissFullscreen(animated: true)
    }
}
