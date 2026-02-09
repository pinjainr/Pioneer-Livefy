import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:livefy/utils/EventType.dart';
import '../../models/recentEvent/RecentEvent.dart';
import '../videoPlayer/event_video_player_screen.dart';

// Widget: Recent Events Section (Event Cards Only)
class RecentEventsSection extends StatelessWidget {
  final List<RecentEvent> events;

  const RecentEventsSection({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No recent events available.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: events.map((event) {
        return Column(
          children: [
            _buildEventCard(context: context, event: event),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Widget _getIconForEventType(String eventType) {
    switch (eventType) {
      case EventType.impact1:
      case EventType.impact2:
      case EventType.impact3:
      case EventType.impact4:
      case EventType.impact1call:
      case EventType.impact2call:
      case EventType.impact3call:
      case EventType.impact4call:
          return Image.asset("assets/images/evetns/gis_impact.png", width: 30, height: 30);
      case EventType.acceleration1:
      case EventType.acceleration2:
          return Image.asset("assets/images/events/gis_sudden_acceleration.png", width: 30, height: 30);
      case EventType.break1:
      case EventType.break2:
          return Image.asset("assets/svgs/gis_sudden_break.png", width: 30, height: 30);
      case EventType.right1:
      case EventType.right2:
          return Image.asset("assets/images/events/gis_sudden_right.png", width: 30, height: 30);
      case EventType.left1:
      case EventType.left2:
          return Image.asset("assets/images/events/gis_sudden_left.png", width: 30, height: 30);
      case EventType.driverCameraBlocked:
          return Image.asset("assets/images/events/dms_cameera_blocked.png", width: 30, height: 30);
      case EventType.driverCameraObstructed:
          return Image.asset("assets/images/events/dms_camera_obstructed.png", width: 30, height: 30);
      case EventType.driverEatingDrinking:
          return Image.asset("assets/images/events/dms_eating_drinking.png", width: 30, height: 30);
      case EventType.driverFatigue:
          return Image.asset("assets/images/events/dms_yawning.png", width: 30, height: 30);
      case EventType.driverGazeDistracted:
          return Image.asset("assets/images/events/dms_gaze_distracted.png", width: 30, height: 30);
      case EventType.driverGazeFixated:
          return Image.asset("assets/images/events/dms_gaze_distracted.png", width: 30, height: 30);
      case EventType.driverPoseDistracted:
          return Image.asset("assets/images/events/dms_pose_distracted.png", width: 30, height: 30);
      case EventType.driverSleepy:
          return Image.asset("assets/images/events/dms_sleepy.png", width: 30, height: 30);
      case EventType.driverSmoking:
          return Image.asset("assets/images/events/dms_smoking.png", width: 30, height: 30);
      case EventType.driverUsingPhone:
          return Image.asset("assets/images/events/dms_using_phone.png", width: 30, height: 30);
      case EventType.frontCollisionWarning:
          return Image.asset("assets/images/events/adas_fornt_collision_warning.png", width: 30, height: 30);
      case EventType.dangerousHeadwayWarning:
          return Image.asset("assets/images/eventsimages/events/adas_tail_gate.png", width: 30, height: 30);
      case EventType.laneDepartureWarning:
          return Image.asset("assets/images/events/adas_lane_departure.png", width: 30, height: 30);
      case EventType.trafficSpeedSignViolation:
          return Image.asset("assets/images/events/adas_speed_violation.png", width: 30, height: 30);
      case EventType.rollingStopSignViolation:
          return Image.asset("assets/images/events/adas_rollong_stop_voilation.png", width: 30, height: 30);
      case EventType.movingTrafficAlert:
          return Image.asset("assets/images/events/adas_moving_traffic.png", width: 30, height: 30);

      default:
          return Image.asset("assets/images/events/adas_dms_warning.png", width: 30, height: 30);
    }
  }

String _getTitle(String eventType) {
  switch (eventType) {
    case EventType.impact5:
      return "Impact Detection Level 5";
    case EventType.impact4:
      return "Impact Detection Level 4";
    case EventType.impact3:
      return "Impact Detection Level 3";
    case EventType.impact2:
      return "Impact Detection Level 2";
    case EventType.impact1:
      return "Impact Detection Level 1";

    case EventType.impact4call:
      return "Impact 4 with call";
    case EventType.impact3call:
      return "Impact 3 with call";
    case EventType.impact2call:
      return "Impact 2 with call";
    case EventType.impact1call:
      return "Impact 1 with call";

    case EventType.sos:
      return "Emergency call";

    case EventType.right2:
      return "Sudden Turn Right Level 2";
    case EventType.right1:
      return "Sudden Turn Right Level 1";
    case EventType.left2:
      return "Sudden Turn Left Level 2";
    case EventType.left1:
      return "Sudden Turn Left Level 1";

    case EventType.break2:
      return "Sudden Braking Level 2";
    case EventType.break1:
      return "Sudden Braking Level 1";

    case EventType.acceleration2:
      return "Sudden Acceleration Level 2";
    case EventType.acceleration1:
      return "Sudden Acceleration Level 1";

    // DMS
    case EventType.driverCameraBlocked:
      return "Driver Camera Blocked";
    case EventType.driverCameraObstructed:
      return "Driver Camera Obstructed";
    case EventType.driverSleepy:
    case EventType.driverFatigue:
      return "Driver Fatigue";
    case EventType.driverEatingDrinking:
      return "Driver Eating/Drinking";
    case EventType.driverGazeDistracted:
    case EventType.driverGazeFixated:
      return "";
    case EventType.driverPoseDistracted:
      return "Driver Pose Distracted";
    case EventType.driverUsingPhone:
      return "Driver Using Phone";
    case EventType.driverSmoking:
      return "Driver Smoking";

    // ADAS
    case EventType.dangerousHeadwayWarning:
      return "Dangerous Headway Warning";
    case EventType.movingTrafficAlert:
      return "Moving Traffic Alert";
    case EventType.frontCollisionWarning:
      return "Front Collision Warning";
    case EventType.laneDepartureWarning:
      return "Lane Departure Warning";
    case EventType.trafficSpeedSignViolation:
      return "Traffic Speed Sign Violation";
    case EventType.rollingStopSignViolation:
      return "Rolling Stop Sign Violation";

    default:
      return "System Warning";
  }
}


  String _formatTimestamp(String timestamp) {
    try {
      // Parse ISO 8601 timestamp
      final dateTime = DateTime.parse(timestamp);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dateTime.month - 1];
      final day = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$day $month $year | $hour:$minute $period';
    } catch (e) {
      return timestamp; // Return original if parsing fails
    }
  }

  Widget _buildEventCard({required BuildContext context, required RecentEvent event}) {
    return GestureDetector(
      onTap: () {
        if (event.presignedUrl?.front != null && event.presignedUrl!.front.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventVideoPlayerScreen(
                videoUrl: event.presignedUrl!.front,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video URL not available'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Center(
                child: _getIconForEventType(event.eventType),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(event.eventType),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trip ID: ${event.tripId}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatTimestamp(event.timestamp),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
