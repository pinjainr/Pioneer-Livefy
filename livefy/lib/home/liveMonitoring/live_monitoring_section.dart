import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../streaming_screen.dart';
import '../liveStreamView/live_stream_view.dart';

class LiveMonitoringSection extends StatefulWidget {
  const LiveMonitoringSection({super.key});

  @override
  _LiveMonitoringSection createState() => _LiveMonitoringSection();
}

class _LiveMonitoringSection extends State<LiveMonitoringSection> {
  bool isPlaying = false;
  bool isFront = true;

  void togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {
      print("▶️ Play");
      // start player
    } else {
      print("⏸ Pause");
      // pause player
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final appBarHeight = AppBar().preferredSize.height;
    final availableHeight = screenHeight - safeAreaTop - appBarHeight;
    final sectionHeight = availableHeight * 0.25;

    var whepUrl = "http://13.202.239.228:8889/front"; //isFront ? "http://13.202.239.228:8889/front" : "http://13.202.239.228:8889/cabin/";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StreamingScreen(),
          ),
        );
      },
      child: Container(
        height: sectionHeight,
        child: Center(
          child: isPlaying ? LiveStreamView(streamUrl: whepUrl) : LiveMonitoringSectionCard(onTapStream: togglePlay,),
        ),
      ),
    );
  }
}

class LiveMonitoringSectionCard extends StatelessWidget {
  final VoidCallback onTapStream;

  const LiveMonitoringSectionCard({
    super.key,
    required this.onTapStream
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final appBarHeight = AppBar().preferredSize.height;
    final availableHeight = screenHeight - safeAreaTop - appBarHeight;
    final sectionHeight = availableHeight * 0.25;

    return GestureDetector(
      onTap: onTapStream,
      child: Container(
        height: sectionHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset("assets/svgs/play.svg", width: 88, height: 90,)
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap to start live monitoring',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ]),
        ),
      ),
    );
  }
}
