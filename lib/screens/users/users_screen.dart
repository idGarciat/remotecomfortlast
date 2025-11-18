import 'package:flutter/material.dart';
import 'user_row.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final api = ApiService(baseUrl: 'http://192.168.100.66:5000'); // ajustar según entorno
  late Future<List<User>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = api.fetchUsers();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureUsers = api.fetchUsers();
    });
    await _futureUsers;
  }

  Future<void> _showEditDialog(User user) async {
    final parentCtx = context; // capture parent context to use after awaits
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email ?? '');
    bool saving = false;

    await showDialog<void>(
      context: parentCtx,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Editar usuario'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        setStateDialog(() => saving = true);
                        final navigator = Navigator.of(parentCtx);
                        final messenger = ScaffoldMessenger.of(parentCtx);
                        try {
                          if (user.id == null) throw Exception('User id is null');
                          await api.updateUser(user.id!, name: nameController.text.trim(), email: emailController.text.trim());
                          // use captured navigator/messenger instances (safe across async)
                          navigator.pop();
                          if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Usuario actualizado')));
                          if (mounted) await _refresh();
                        } catch (e) {
                          setStateDialog(() => saving = false);
                          if (mounted) messenger.showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
                        }
                      },
                child: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
  const backgroundDark = Color(0xFF101922);

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Usuarios', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<User>>(
                  future: _futureUsers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          children: [
                            SizedBox(
                              height: 200,
                              child: Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final users = snapshot.data ?? [];
                      if (users.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView(
                            children: const [
                              SizedBox(height: 200),
                              Center(child: Text('No hay usuarios', style: TextStyle(color: Colors.white))),
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final u = users[index];
                            return UserRow(
                              name: u.name,
                              email: u.email,
                              createdAt: u.createdAt,
                              avatarUrl: '',
                              onEdit: () => _showEditDialog(u),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
              // Add button removed; editing handled via edit icon per row
            ],
          ),
        ),
      ),
    );
  }
}

