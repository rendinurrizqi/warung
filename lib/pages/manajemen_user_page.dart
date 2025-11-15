import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class ManajemenUserPage extends StatelessWidget {
  const ManajemenUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Pengguna"),
        centerTitle: true,
      ),

      body: userProvider.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                final u = userProvider.users[index];

                return Card(
                  child: ListTile(
                    title: Text(u.name),
                    subtitle: Text("${u.email} • Role: ${u.role}"),

                    trailing: auth.user?.uid == u.id
                        ? const Text(
                            "You",
                            style: TextStyle(color: Colors.green),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /// BUTTON GANTI ROLE
                              IconButton(
                                icon: const Icon(Icons.shield),
                                onPressed: () async {
                                  final newRole = u.role == "owner"
                                      ? "staff"
                                      : "owner";
                                  await userProvider.updateUserRole(
                                    u.id,
                                    newRole,
                                  );
                                },
                              ),

                              /// DELETE USER
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await userProvider.deleteUser(u.id);
                                },
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
    );
  }
}
