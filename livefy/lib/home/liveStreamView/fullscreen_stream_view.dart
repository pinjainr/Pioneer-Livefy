import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FullscreenStreamView extends StatefulWidget {
  final WebViewController controller;

  const FullscreenStreamView({
    super.key,
    required this.controller,
  });

  @override
  State<FullscreenStreamView> createState() => _FullscreenStreamViewState();
}

class _FullscreenStreamViewState extends State<FullscreenStreamView> {
  @override
  void initState() {
    super.initState();
    // Set fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // Lock to landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _restoreOrientation() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Restore to portrait-only (app default)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _restoreOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _restoreOrientation();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Fullscreen webview using the same controller
            WebViewWidget(controller: widget.controller),
            // Restore screen button - bottom right
            Positioned(
              bottom: 16,
              right: 16,
              child: SafeArea(
                child: IconButton(
                  onPressed: () {
                    _restoreOrientation();
                    Navigator.of(context).pop();
                  },
                  icon: SvgPicture.asset(
                    'assets/svgs/restoreScreen.svg',
                    width: 32,
                    height: 32,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
