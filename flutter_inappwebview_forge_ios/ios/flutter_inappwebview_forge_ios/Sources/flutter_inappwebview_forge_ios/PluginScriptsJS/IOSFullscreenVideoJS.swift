//
//  IOSFullscreenVideoJS.swift
//  flutter_inappwebview_forge_ios
//

import Foundation

/// Coordinates the iOS 26 fullscreen workaround without using the public
/// JavaScript bridge. The script is installed in every frame so that a video
/// inside an iframe can identify its own frame before the native handoff.
public final class IOSFullscreenVideoJS {
    public static let pluginScriptGroupName = "IN_APP_WEBVIEW_IOS_FULLSCREEN_VIDEO_JS_PLUGIN_SCRIPT"
    public static let messageHandlerName = "forgeIOSFullscreenVideo"
    public static let namespace = "window.__forgeIOSFullscreenVideo"

    public static func pluginScript(enabled: Bool, allowedOriginRules: [String]?, messageSecret: String) -> PluginScript {
        return PluginScript(
            groupName: pluginScriptGroupName,
            source: source(enabled: enabled, messageSecret: messageSecret),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [messageHandlerName]
        )
    }

    public static func setEnabledSource(_ enabled: Bool) -> String {
        return "(namespace).setNativeFullscreenEnabled(\(enabled ? "true" : "false"));"
    }

    public static func enterSource(videoID: String) -> String {
        return "(namespace).enter(\(jsonString(videoID)));"
    }

    public static func exitSource(videoID: String) -> String {
        return "(namespace).exit(\(jsonString(videoID)));"
    }

    public static func fallbackSource(videoID: String) -> String {
        return "(namespace).fallback(\(jsonString(videoID)));"
    }

    private static func jsonString(_ value: String) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: [value], options: []),
              let json = String(data: data, encoding: .utf8) else {
            return "\"\""
        }
        return String(json.dropFirst().dropLast())
    }

    private static func source(enabled: Bool, messageSecret: String) -> String {
        return """
        (function() {
            'use strict';

            var nativeFullscreenEnabled = \(enabled ? "true" : "false");
            var nextVideoId = 0;
            var registeredVideos = [];
            var originalWebkitEnterFullscreen = null;
            var originalRequestFullscreen = null;
            var originalWebkitRequestFullscreen = null;

            function post(type, video, prevented) {
                if (!video || !window.webkit || !window.webkit.messageHandlers ||
                    !window.webkit.messageHandlers.\(messageHandlerName)) {
                    return;
                }
                try {
                    window.webkit.messageHandlers.\(messageHandlerName).postMessage({
                        secret: \(jsonString(messageSecret)),
                        type: type,
                        videoId: video.__forgeFullscreenVideoId || null,
                        hasSeeked: video.__forgeFullscreenHasSeeked === true,
                        prevented: prevented === true
                    });
                } catch (e) {
                    // The page may be torn down while a media event is queued.
                }
            }

            function addNoFullscreenToken(value) {
                var tokens = (value || '').split(/\\s+/).filter(function(token) { return token.length > 0; });
                if (tokens.indexOf('nofullscreen') < 0) {
                    tokens.push('nofullscreen');
                }
                return tokens.join(' ');
            }

            function registerVideo(video) {
                if (!(video instanceof HTMLVideoElement) || video.__forgeFullscreenVideoRegistered) {
                    return;
                }

                video.__forgeFullscreenVideoRegistered = true;
                video.__forgeFullscreenVideoId = 'forge-video-' + (++nextVideoId);
                video.__forgeFullscreenHasSeeked = false;
                video.__forgeFullscreenState = null;
                registeredVideos.push(video);

                video.addEventListener('seeking', function() {
                    video.__forgeFullscreenHasSeeked = true;
                    post('seeked', video, false);
                });
                video.addEventListener('seeked', function() {
                    video.__forgeFullscreenHasSeeked = true;
                    post('seeked', video, false);
                });
                video.addEventListener('webkitbeginfullscreen', function() {
                    post('fullscreenWillBegin', video, false);
                });
                video.addEventListener('webkitendfullscreen', function() {
                    post('fullscreenDidEnd', video, false);
                });
            }

            function findVideo(videoId) {
                for (var i = 0; i < registeredVideos.length; i++) {
                    var video = registeredVideos[i];
                    if (video && video.__forgeFullscreenVideoId === videoId) {
                        return video;
                    }
                }
                return null;
            }

            function requestNativeFullscreen(video) {
                registerVideo(video);
                if (!nativeFullscreenEnabled || !video.__forgeFullscreenHasSeeked ||
                    video.__forgeFullscreenState === 'active') {
                    return false;
                }
                video.__forgeFullscreenState = 'pending';
                post('fullscreenWillBegin', video, true);
                return true;
            }

            function enter(videoId) {
                var video = findVideo(videoId);
                if (!video || video.__forgeFullscreenState === 'active') {
                    return false;
                }

                video.__forgeFullscreenOriginalStyle = video.getAttribute('style');
                video.__forgeFullscreenOriginalControlsList = video.getAttribute('controlslist');
                video.__forgeFullscreenOriginalPlaysInline = video.getAttribute('playsinline');
                video.__forgeFullscreenOriginalWebkitPlaysInline = video.getAttribute('webkit-playsinline');
                video.__forgeFullscreenState = 'active';
                video.setAttribute('playsinline', '');
                video.setAttribute('webkit-playsinline', '');
                video.setAttribute('controlslist', addNoFullscreenToken(video.getAttribute('controlslist')));
                video.style.position = 'fixed';
                video.style.left = '0';
                video.style.top = '0';
                video.style.width = '100vw';
                video.style.height = '100vh';
                video.style.maxWidth = '100vw';
                video.style.maxHeight = '100vh';
                video.style.objectFit = 'contain';
                video.style.zIndex = '2147483647';
                video.style.backgroundColor = 'black';
                return true;
            }

            function restore(video) {
                if (!video || video.__forgeFullscreenState !== 'active') {
                    return;
                }
                var originalStyle = video.__forgeFullscreenOriginalStyle;
                var originalControlsList = video.__forgeFullscreenOriginalControlsList;
                var originalPlaysInline = video.__forgeFullscreenOriginalPlaysInline;
                var originalWebkitPlaysInline = video.__forgeFullscreenOriginalWebkitPlaysInline;
                if (originalStyle === null || originalStyle === undefined) {
                    video.removeAttribute('style');
                } else {
                    video.setAttribute('style', originalStyle);
                }
                if (originalControlsList === null || originalControlsList === undefined) {
                    video.removeAttribute('controlslist');
                } else {
                    video.setAttribute('controlslist', originalControlsList);
                }
                if (originalPlaysInline === null || originalPlaysInline === undefined) {
                    video.removeAttribute('playsinline');
                } else {
                    video.setAttribute('playsinline', originalPlaysInline);
                }
                if (originalWebkitPlaysInline === null || originalWebkitPlaysInline === undefined) {
                    video.removeAttribute('webkit-playsinline');
                } else {
                    video.setAttribute('webkit-playsinline', originalWebkitPlaysInline);
                }
                video.__forgeFullscreenState = null;
                video.__forgeFullscreenHasSeeked = false;
            }

            function exit(videoId) {
                restore(findVideo(videoId));
                return true;
            }

            function fallback(videoId) {
                var video = findVideo(videoId);
                if (!video) {
                    return false;
                }
                restore(video);
                video.__forgeFullscreenState = null;
                if (originalWebkitEnterFullscreen) {
                    try {
                        originalWebkitEnterFullscreen.call(video);
                    } catch (e) {
                        // Let the page continue if WebKit rejects the fallback.
                    }
                }
                return true;
            }

            function setNativeFullscreenEnabled(enabledValue, broadcast) {
                nativeFullscreenEnabled = enabledValue === true;
                if (!broadcast || !window.frames) {
                    return;
                }
                for (var i = 0; i < window.frames.length; i++) {
                    try {
                        window.frames[i].postMessage({
                            secret: \(jsonString(messageSecret)),
                            type: 'setNativeFullscreenEnabled',
                            enabled: nativeFullscreenEnabled
                        }, '*');
                    } catch (e) {
                        // A frame can disappear while settings are propagated.
                    }
                }
            }

            window.addEventListener('message', function(event) {
                var data = event.data;
                if (data && data.secret === \(jsonString(messageSecret)) &&
                    data.type === 'setNativeFullscreenEnabled') {
                    setNativeFullscreenEnabled(data.enabled, false);
                }
            }, false);

            window.__forgeIOSFullscreenVideo = {
                setNativeFullscreenEnabled: function(enabledValue) {
                    setNativeFullscreenEnabled(enabledValue, true);
                },
                enter: enter,
                exit: exit,
                fallback: fallback
            };

            if (HTMLVideoElement.prototype.webkitEnterFullscreen) {
                originalWebkitEnterFullscreen = HTMLVideoElement.prototype.webkitEnterFullscreen;
                HTMLVideoElement.prototype.webkitEnterFullscreen = function() {
                    if (requestNativeFullscreen(this)) {
                        return;
                    }
                    return originalWebkitEnterFullscreen.apply(this, arguments);
                };
            }

            if (Element.prototype.requestFullscreen) {
                originalRequestFullscreen = Element.prototype.requestFullscreen;
                Element.prototype.requestFullscreen = function() {
                    if (this instanceof HTMLVideoElement && requestNativeFullscreen(this)) {
                        return Promise.resolve();
                    }
                    return originalRequestFullscreen.apply(this, arguments);
                };
            }

            if (Element.prototype.webkitRequestFullscreen) {
                originalWebkitRequestFullscreen = Element.prototype.webkitRequestFullscreen;
                Element.prototype.webkitRequestFullscreen = function() {
                    if (this instanceof HTMLVideoElement && requestNativeFullscreen(this)) {
                        return;
                    }
                    return originalWebkitRequestFullscreen.apply(this, arguments);
                };
            }

            document.addEventListener('fullscreenchange', function() {
                var element = document.fullscreenElement || document.webkitFullscreenElement;
                if (element instanceof HTMLVideoElement) {
                    post('fullscreenWillBegin', element, false);
                }
            }, true);

            function scan(root) {
                if (!root || !root.querySelectorAll) {
                    return;
                }
                if (root instanceof HTMLVideoElement) {
                    registerVideo(root);
                }
                var videos = root.querySelectorAll('video');
                for (var i = 0; i < videos.length; i++) {
                    registerVideo(videos[i]);
                }
            }

            scan(document);
            if (window.MutationObserver) {
                new MutationObserver(function(records) {
                    for (var i = 0; i < records.length; i++) {
                        var addedNodes = records[i].addedNodes;
                        for (var j = 0; j < addedNodes.length; j++) {
                            scan(addedNodes[j]);
                        }
                    }
                }).observe(document.documentElement || document, {childList: true, subtree: true});
            }
        })();
        """
    }
}
