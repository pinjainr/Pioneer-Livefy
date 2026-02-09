import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// Custom Drawer matching the design
class CustomDrawer extends StatelessWidget {
  final VoidCallback onClose;

  const CustomDrawer({
    super.key,
    required this.onClose
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header with Toyota logo and close button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/toyota_titile_nav_log.png',
                      height: 30,
                    ),

                    // Cross icon button
                    IconButton(
                      onPressed: onClose,
                      icon: SvgPicture.asset(
                        'assets/svgs/cross.svg',
                        width: 24,
                        height: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      context,
                      'Privacy Policy',
                      () {
                        Navigator.pop(context);
                        // Handle navigation
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    _buildMenuItem(
                      context,
                      'EULA',
                      () {
                        Navigator.pop(context);
                        // Handle navigation
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    _buildMenuItem(
                      context,
                      'Menu 3',
                      () {
                        Navigator.pop(context);
                        // Handle navigation
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.black,
      ),
      onTap: onTap,
    );
  }
}
