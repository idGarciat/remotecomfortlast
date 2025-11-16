import 'package:flutter/material.dart';

class UserRow extends StatelessWidget {
  final String name;
  final String? email;
  final DateTime? createdAt;
  final String avatarUrl;
  final VoidCallback? onEdit;

  const UserRow({required this.name, this.email, this.createdAt, required this.avatarUrl, this.onEdit, super.key});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withAlpha((0.03 * 255).round()), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: Colors.grey, child: Text(name.isNotEmpty ? name[0] : '?')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(email ?? '', style: TextStyle(color: Colors.grey[400])),
                if (createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text('Creado: ${_formatDate(createdAt)}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ]
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: Icon(Icons.edit, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
