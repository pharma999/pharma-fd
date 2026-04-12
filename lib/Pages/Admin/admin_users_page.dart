import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/admin_controller.dart';
import 'package:home_care/Model/user_detail_model.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final ctrl = Get.find<AdminController>();
  final _roles = ['', 'PATIENT', 'DOCTOR', 'NURSE', 'CAREGIVER', 'HOSPITAL'];

  @override
  void initState() {
    super.initState();
    ctrl.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('User Management',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                    children: _roles
                        .map((r) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(r.isEmpty ? 'All' : r),
                                selected: ctrl.userRoleFilter.value == r,
                                onSelected: (_) {
                                  ctrl.userRoleFilter.value = r;
                                  ctrl.fetchUsers(role: r.isEmpty ? null : r);
                                },
                                selectedColor:
                                    const Color(0xFF1A237E).withValues(alpha: 0.15),
                                checkmarkColor: const Color(0xFF1A237E),
                              ),
                            ))
                        .toList(),
                  )),
            ),
          ),
          // List
          Expanded(
            child: Obx(() {
              if (ctrl.isLoadingUsers.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ctrl.users.isEmpty) {
                return const Center(child: Text('No users found'));
              }
              return RefreshIndicator(
                onRefresh: ctrl.fetchUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.users.length,
                  itemBuilder: (_, i) =>
                      _UserTile(user: ctrl.users[i], ctrl: ctrl),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserDetail user;
  final AdminController ctrl;
  const _UserTile({required this.user, required this.ctrl});

  Color get _roleColor {
    switch (user.role) {
      case 'DOCTOR':
        return Colors.purple;
      case 'NURSE':
        return Colors.teal;
      case 'HOSPITAL':
        return Colors.orange;
      case 'ADMIN':
      case 'SUPER_ADMIN':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = user.blockStatus == 'BLOCKED';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _roleColor.withValues(alpha: 0.15),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(color: _roleColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.name.isEmpty ? 'Unknown' : user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.phoneNumber,
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Row(
              children: [
                _Badge(label: user.role, color: _roleColor),
                const SizedBox(width: 6),
                if (isBlocked)
                  _Badge(label: 'BLOCKED', color: Colors.red),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isBlocked ? Icons.lock_open : Icons.lock,
            color: isBlocked ? Colors.green : Colors.red,
          ),
          tooltip: isBlocked ? 'Unblock' : 'Block',
          onPressed: () async {
            final confirm = await _confirm(
              context,
              isBlocked ? 'Unblock user?' : 'Block user?',
              isBlocked
                  ? 'This user will be allowed to use the app again.'
                  : 'This user will lose app access.',
            );
            if (confirm) ctrl.blockUser(user.userId, !isBlocked);
          },
        ),
      ),
    );
  }

  Future<bool> _confirm(
      BuildContext ctx, String title, String message) async {
    return await showDialog<bool>(
          context: ctx,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Confirm')),
            ],
          ),
        ) ??
        false;
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
