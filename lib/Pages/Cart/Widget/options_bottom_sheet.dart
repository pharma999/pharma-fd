import 'package:flutter/material.dart';

void showOptionsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Options",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              OptionTile(
                icon: Icons.delete_outline,
                title: "Clear Cart",
                subtitle: "Remove all items",
                bgColor: Colors.redAccent,
                iconColor: Colors.red,
                onTap: () => Navigator.pop(context),
              ),
              OptionTile(
                icon: Icons.ios_share,
                title: "Share Cart",
                subtitle: "Send list to friends or family",
                bgColor: Colors.blueAccent,
                iconColor: Colors.blue,
                onTap: () => Navigator.pop(context),
              ),
              OptionTile(
                icon: Icons.bookmark_border,
                title: "Save for Later",
                subtitle: "Move items to wishlist",
                bgColor: Colors.orangeAccent,
                iconColor: Colors.orange,
                onTap: () => Navigator.pop(context),
              ),
              OptionTile(
                icon: Icons.support_agent,
                title: "Help & Support",
                subtitle: "Issues with your order?",
                bgColor: Colors.purpleAccent,
                iconColor: Colors.purple,
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),

              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// ✅ PUBLIC widget (NO underscore)
class OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        backgroundColor: bgColor.withOpacity(0.15),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
