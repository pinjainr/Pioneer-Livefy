import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'fullscreen_stream_view.dart';

class LiveStreamView extends StatefulWidget {
  final String streamUrl;
  final VoidCallback toggleCameraCallback;

  const LiveStreamView({
    super.key,
    required this.streamUrl,
    required this.toggleCameraCallback
  });

  @override
  State<LiveStreamView> createState() => _LiveStreamViewState();
}

class _LiveStreamViewState extends State<LiveStreamView> {
  late final WebViewController controller;
  bool isLoading = true;
  String? errorMessage;
  int _webViewKey = 0; // Key counter to force rebuild when returning from fullscreen

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void didUpdateWidget(LiveStreamView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      _loadUrl(widget.streamUrl);
    }
  }

  /// Load a new URL in the existing controller (used when toggling camera).
  void _loadUrl(String url) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await controller.clearCache();
      await controller.clearLocalStorage();
    } catch (e) {
      print("Error clearing cache when switching URL: $e");
    }
    if (!mounted) return;
    controller.loadRequest(Uri.parse(url));
  }

  void _initializeWebView() async {
    try {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..addJavaScriptChannel(
          'VideoDebug',
          onMessageReceived: (JavaScriptMessage message) {
            print("VIDEO DEBUG: ${message.message}");
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print("WebView page started: $url");
              if (mounted) {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
              }
            },
            onProgress: (int progress) {
              print("onProgress: $progress%");
              if (progress == 100) {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              }
            },
            onPageFinished: (String url) {
              print("onPageFinished: $url");
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
                // Check video status after page loads
                Future.delayed(const Duration(milliseconds: 1000), () {
                  _checkVideoStatus();
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              print("onWebResourceError:");
              print("  Error Code: ${error.errorCode}");
              print("  Description: ${error.description}");
              print("  Error Type: ${error.errorType}");
              print("  Failed URL: ${error.url}");
              
              if (mounted) {
                setState(() {
                  isLoading = false;
                  // Only show error if it's a critical error
                  if (error.errorCode != -999) { // -999 is usually cancellation
                    errorMessage = 'Error loading page: ${error.description}';
                  }
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              print("Navigation request to: ${request.url}");
              return NavigationDecision.navigate;
            },
          ),
        );
      
      // Clear cache and localStorage before loading
      try {
        await controller.clearCache();
        print("WebView cache cleared");
        await controller.clearLocalStorage();
        print("WebView localStorage cleared");
      } catch (e) {
        print("Error clearing cache: $e");
        // Continue even if cache clearing fails
      }
      
      // Load the URL
      controller.loadRequest(Uri.parse(widget.streamUrl));
    } catch (e) {
      print("Error initializing webview: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to initialize webview: $e';
        });
      }
    }
  }

  void _checkVideoStatus() {
    // Check video element and WebRTC connection status
    try {
      controller.runJavaScript('''
        (function() {
          function log(message) {
            if (window.VideoDebug) {
              window.VideoDebug.postMessage(message);
            }
            console.log(message);
          }
          
          log('=== Checking Video Status ===');
          var video = document.querySelector('video');
          if (video) {
            log('✓ Video element found');
            log('  - readyState: ' + video.readyState);
            log('  - paused: ' + video.paused);
            log('  - currentSrc: ' + video.currentSrc);
            log('  - videoWidth: ' + video.videoWidth);
            log('  - videoHeight: ' + video.videoHeight);
            log('  - networkState: ' + video.networkState);
            log('  - error: ' + (video.error ? video.error.message : 'none'));
            
            // Check if video has source
            if (video.src) {
              log('  - src: ' + video.src);
            }
            if (video.srcObject) {
              log('  - srcObject: present');
              var stream = video.srcObject;
              if (stream) {
                log('  - Stream ID: ' + stream.id);
                log('  - Stream active: ' + stream.active);
                var videoTracks = stream.getVideoTracks();
                log('  - Video tracks: ' + videoTracks.length);
                videoTracks.forEach(function(track, index) {
                  log('    Track ' + index + ': ' + track.label + ', enabled: ' + track.enabled + ', readyState: ' + track.readyState);
                });
                var audioTracks = stream.getAudioTracks();
                log('  - Audio tracks: ' + audioTracks.length);
                audioTracks.forEach(function(track, index) {
                  log('    Track ' + index + ': ' + track.label + ', enabled: ' + track.enabled + ', readyState: ' + track.readyState);
                });
              }
            } else {
              log('  - srcObject: null');
            }
            
            // Monitor video events
            video.addEventListener('loadedmetadata', function() {
              log('Video metadata loaded - width: ' + video.videoWidth + ', height: ' + video.videoHeight);
            });
            video.addEventListener('loadeddata', function() {
              log('Video data loaded');
            });
            video.addEventListener('canplay', function() {
              log('Video can play');
            });
            video.addEventListener('playing', function() {
              log('Video is playing');
            });
            video.addEventListener('error', function(e) {
              log('Video error: ' + (video.error ? video.error.message : 'unknown'));
              if (video.error) {
                log('  Error code: ' + video.error.code);
              }
            });
            video.addEventListener('waiting', function() {
              log('Video waiting for data');
            });
            video.addEventListener('stalled', function() {
              log('Video stalled');
            });
            video.addEventListener('progress', function() {
              log('Video progress - buffered: ' + video.buffered.length);
            });
          } else {
            log('✗ No video element found');
            // Try to find any media elements
            var mediaElements = document.querySelectorAll('video, audio');
            log('Found ' + mediaElements.length + ' media elements');
          }
          
          // Check for WebRTC connection
          if (window.RTCPeerConnection) {
            log('✓ WebRTC is supported');
          } else {
            log('✗ WebRTC not supported');
          }
          
          // Check if getUserMedia is available (for debugging)
          if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            log('✓ getUserMedia is available');
          } else {
            log('✗ getUserMedia not available');
          }
        })();
      ''');
    } catch (e) {
      print("Error checking video status: $e");
    }
  }

  void _openFullscreen() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullscreenStreamView(controller: controller),
        ),
      );
      // Force rebuild of webview when returning from fullscreen
      if (mounted) {
        setState(() {
          _webViewKey++; // Increment key to force rebuild
        });
        // Small delay to ensure proper reattachment
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            // Reload the page to restore state
            controller.reload();
          }
        });
      }
    } catch (e) {
      print("Error opening fullscreen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
            content: Text('${AppLocalizations.of(context)?.errorInFullScreen} $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    errorMessage = null;
                    isLoading = true;
                  });
                  controller.reload();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // WebViewWidget with error boundary and key to force rebuild when returning from fullscreen
          Builder(
            builder: (context) {
              try {
                return WebViewWidget(
                  key: ValueKey(_webViewKey), // Key changes when returning from fullscreen
                  controller: controller,
                );
              } catch (e) {
                print("Error building WebViewWidget: $e");
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'WebView error: $e',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          // Toggle Camera button - bottom left
          Positioned(
            bottom: 12,
            left: 16,
            child: IconButton(
                onPressed: widget.toggleCameraCallback,
                icon: SvgPicture.asset(
                  'assets/svgs/toggleCam.svg',
                  width: 32,
                  height: 32,
                ),
            ),
          ),

          // // Fullscreen button - bottom right
          // Positioned(
          //   bottom: 12,
          //   right: 12,
          //   child: IconButton(
          //       onPressed: _openFullscreen,
          //       icon: SvgPicture.asset(
          //         'assets/svgs/fullscreen.svg',
          //         width: 32,
          //         height: 32,
          //       ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
