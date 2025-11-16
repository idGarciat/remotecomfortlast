import 'package:flutter/material.dart';

class DeviceRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DeviceRow({super.key, required this.name, required this.subtitle, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      // ignore: deprecated_member_use
      decoration: BoxDecoration(color: Colors.white.withAlpha((0.03 * 255).round()), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, backgroundColor: Colors.grey, child: Icon(Icons.devices, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(onPressed: onEdit ?? () {}, icon: Icon(Icons.edit, color: Colors.grey[400])),
              IconButton(onPressed: onDelete ?? () {}, icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          )
        ],
      ),
    );
  }
}

class DeviceList extends StatelessWidget {
  const DeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 8),
            children: const [
              DeviceRow(name: 'Lámpara Sala', subtitle: 'Encendido'),
              SizedBox(height: 8),
              DeviceRow(name: 'Termostato', subtitle: '22°C'),
              SizedBox(height: 8),
              DeviceRow(name: 'Cámara Entrada', subtitle: 'Activo'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/manage-devices'),
              icon: const Icon(Icons.add),
              label: const Text('Añadir Dispositivo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF1173D4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
