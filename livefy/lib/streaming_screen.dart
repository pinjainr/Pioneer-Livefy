import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StreamingScreen extends StatefulWidget {
  const StreamingScreen({super.key});

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  bool _isFullScreen = true;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    // Set full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video/Stream Content
          GestureDetector(
            onTap: () {
              // Toggle controls visibility on tap
              setState(() {
                _isFullScreen = !_isFullScreen;
              });
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade300,
                    Colors.blue.shade500,
                    Colors.grey.shade700,
                    Colors.grey.shade800,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Simulated dashcam view - highway scene
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DashcamViewPainter(),
                    ),
                  ),
                  // Play/Pause overlay
                  if (!_isPlaying)
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pause,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Fullscreen toggle button
                  IconButton(
                    icon: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFullScreen,
                  ),
                ],
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play/Pause button
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    const SizedBox(width: 20),
                    // Stop button
                    IconButton(
                      icon: const Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to simulate dashcam view
class DashcamViewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Sky gradient
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.center,
      colors: [
        Colors.lightBlue.shade200,
        Colors.lightBlue.shade100,
      ],
    );
    paint.shader = skyGradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.3),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.3),
      paint,
    );

    // Clouds
    paint.color = Colors.white.withOpacity(0.7);
    paint.style = PaintingStyle.fill;
    _drawCloud(canvas, paint, size.width * 0.2, size.height * 0.1, 60);
    _drawCloud(canvas, paint, size.width * 0.6, size.height * 0.15, 50);
    _drawCloud(canvas, paint, size.width * 0.8, size.height * 0.08, 55);

    // Horizon line with hills
    paint.shader = null;
    paint.color = Colors.green.shade900;
    final hillPath = Path();
    hillPath.moveTo(0, size.height * 0.3);
    hillPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.3,
    );
    hillPath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.35,
      size.width,
      size.height * 0.3,
    );
    hillPath.lineTo(size.width, size.height);
    hillPath.lineTo(0, size.height);
    hillPath.close();
    canvas.drawPath(hillPath, paint);

    // Highway
    paint.color = Colors.grey.shade600;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.6),
      paint,
    );

    // Lane markings
    paint.color = Colors.white.withOpacity(0.8);
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    final dashPath = Path();
    for (double i = 0; i < size.width; i += 40) {
      dashPath.moveTo(i, size.height * 0.5);
      dashPath.lineTo(i + 20, size.height * 0.5);
    }
    canvas.drawPath(dashPath, paint);

    // Vehicles on the road (simplified)
    paint.style = PaintingStyle.fill;
    paint.color = Colors.grey.shade800;
    // Left lane vehicle
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.6, 80, 40),
      paint,
    );
    // Middle lane vehicle
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.55, 90, 45),
      paint,
    );
    // Right lane truck
    paint.color = Colors.grey.shade700;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.7, size.height * 0.5, 100, 60),
      paint,
    );

    // Dashboard/foreground
    paint.color = Colors.grey.shade400;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.9, size.width, size.height * 0.1),
      paint,
    );
    // Dashboard grille pattern
    paint.color = Colors.grey.shade300;
    paint.strokeWidth = 2;
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, size.height * 0.92),
        Offset(i, size.height * 0.98),
        paint,
      );
    }
  }

  void _drawCloud(Canvas canvas, Paint paint, double x, double y, double size) {
    canvas.drawCircle(Offset(x, y), size * 0.3, paint);
    canvas.drawCircle(Offset(x + size * 0.2, y), size * 0.4, paint);
    canvas.drawCircle(Offset(x + size * 0.4, y), size * 0.3, paint);
    canvas.drawCircle(Offset(x + size * 0.1, y - size * 0.1), size * 0.25, paint);
    canvas.drawCircle(Offset(x + size * 0.3, y - size * 0.1), size * 0.25, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
