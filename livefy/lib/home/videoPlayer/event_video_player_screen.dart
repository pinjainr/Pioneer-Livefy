import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

import '../../models/recentEvent/RecentEvent.dart';

class EventVideoPlayerScreen extends StatefulWidget {
  final PresignedUrl videoUrls;

  const EventVideoPlayerScreen({
    super.key,
    required this.videoUrls,
  });

  @override
  State<EventVideoPlayerScreen> createState() => _EventVideoPlayerScreenState();
}

class _EventVideoPlayerScreenState extends State<EventVideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  bool isFront = true;

  void toggleCamera() {
    setState(() {
      isFront = !isFront;
    });
    if (isFront) {
      print("Front camera selected.");
    } else {
      print("Cabin camera selected.");
    }
    // Re-initialize player with the other URL
    _controller?.dispose();
    _controller = null;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    _initializePlayer();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Delay initialization slightly to ensure widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  bool _isValidUrl(String? url) {
    return url != null && url.trim().isNotEmpty;
  }

  void _initializePlayer() async {
    try {
      final String? frontUrl = widget.videoUrls.front;
      final String? cabinUrl = widget.videoUrls.cabin;
      final String? selectedUrl = isFront ? frontUrl : cabinUrl;

      if (!_isValidUrl(selectedUrl)) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = isFront
                ? 'Front camera video URL is not available.'
                : 'Cabin camera video URL is not available.';
          });
        }
        return;
      }

      final String url = selectedUrl!;
      print('Initializing video player with URL: $url');

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
        ),
      );
      
      // Add listener for errors
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          print('Video player error: ${_controller!.value.errorDescription}');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = _controller!.value.errorDescription ?? 'Unknown error';
            });
          }
        }
      });
      
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _controller!.play();
        _controller!.setLooping(true);
      }
    } catch (e, stackTrace) {
      print('Error initializing video player: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading video',
                        style: TextStyle(color: Colors.white),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _hasError = false;
                            _errorMessage = null;
                          });
                          _controller?.dispose();
                          _initializePlayer();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _controller != null && _controller!.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                        // Toggle Camera button - bottom left (similar to LiveStreamView)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: IconButton(
                            onPressed: toggleCamera,
                            icon: SvgPicture.asset(
                              'assets/svgs/toggleCam.svg',
                              width: 32,
                              height: 32,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
      floatingActionButton: _isLoading || _hasError || _controller == null || !_controller!.value.isInitialized
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
    );
  }
}
