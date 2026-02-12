import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../streaming_screen.dart';
import '../drawer/custom_drawer.dart';
import 'liveMonitoring/live_monitoring_section.dart';
import 'recentEvents/recent_events_section.dart';
import '../../services/apiService/ApiService.dart';
import '../../models/recentEvent/RecentEvent.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<RecentEvent> recentEvents = [];
  bool isLoadingEvents = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRecentEvents();
  }

  Future<void> _fetchRecentEvents() async {
    setState(() {
      isLoadingEvents = true;
      errorMessage = null;
    });

    try {
      final events = await ApiService.fetchRecentEvents(
        deviceId: '866693080014181',
        tenantId: '35c79fed-3785-4d26-bbce-ce8b05972acb',
      );
      setState(() {
        recentEvents = events;
        isLoadingEvents = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingEvents = false;
      });
      print('Error fetching recent events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
              icon: SvgPicture.asset('assets/svgs/menu.svg'),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
        centerTitle: true,
        title: SvgPicture.asset('assets/svgs/toyota.svg', width: 110, height: 30,),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.black),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: SizedBox(
        width: screenWidth * 0.75, // 75% of screen width
        child: CustomDrawer(
          onClose: () {
            Navigator.of(context).pop(); // ✅ CLOSE DRAWER
            },
          ),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Main Content Area with Grey Border
                Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Live Monitoring Section
                      const LiveMonitoringSection(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recent Events Header (Fixed)
                        Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                l10n.recentEvents,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (recentEvents.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE60012),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${recentEvents.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Scrollable Event Cards
                        Expanded(
                          child: isLoadingEvents
                              ? const Center(child: CircularProgressIndicator())
                              : errorMessage != null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            l10n.errInLoadingEvents,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: _fetchRecentEvents,
                                            child: Text(l10n.retry),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      child: RecentEventsSection(
                                        events: recentEvents,
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }

}

