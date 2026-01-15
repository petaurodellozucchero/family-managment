import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/family_member_provider.dart';
import '../providers/current_user_provider.dart';
import '../models/family_member_model.dart';
import '../utils/color_utils.dart';

/// Settings screen for managing family members
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni', style: TextStyle(fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current User Section
            Consumer<CurrentUserProvider>(
              builder: (context, currentUserProvider, child) {
                final currentUser = currentUserProvider.currentUser;
                if (currentUser == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Utente Corrente',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: ColorUtils.hexToColor(currentUser.color),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          currentUser.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text('Tocca per cambiare utente'),
                        trailing: const Icon(Icons.swap_horiz),
                        onTap: () => _confirmSwitchUser(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            // Family Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Membri della Famiglia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddMemberDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Aggiungi'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<FamilyMemberProvider>(
              builder: (context, familyMemberProvider, child) {
                if (familyMemberProvider.isLoading &&
                    familyMemberProvider.familyMembers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (familyMemberProvider.familyMembers.isEmpty) {
                  return const Column(
                    children: [
                      Text('Nessun membro della famiglia trovato. Usa il pulsante Aggiungi per creare nuovi membri.'),
                      SizedBox(height: 16),
                    ],
                  );
                }

                List<FamilyMember> members = familyMemberProvider.familyMembers;

                return Column(
                  children: members.map((member) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ColorUtils.hexToColor(member.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(member.color),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditMemberDialog(context, member),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteMember(context, member),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // App Information
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Info',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Versione', style: TextStyle(fontSize: 18)),
              subtitle: Text('1.0.0'),
            ),
            const ListTile(
              leading: Icon(Icons.family_restroom),
              title: Text('App Gestione Familiare',
                  style: TextStyle(fontSize: 18)),
              subtitle: Text('Gestisci il calendario familiare e la lista della spesa'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSwitchUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cambia Utente'),
          content: const Text(
              'Sei sicuro di voler cambiare utente? Verrai reindirizzato alla schermata di login.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final currentUserProvider =
                    Provider.of<CurrentUserProvider>(context, listen: false);
                await currentUserProvider.clearCurrentUser();
              },
              child: const Text('Cambia Utente'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Aggiungi Membro Famiglia'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Seleziona Colore:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ColorUtils.getColorOptions().map((color) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inserisci un nome')),
                      );
                      return;
                    }

                    FamilyMember newMember = FamilyMember(
                      id: '',
                      name: nameController.text.trim(),
                      color: ColorUtils.colorToHex(selectedColor),
                    );

                    final provider = Provider.of<FamilyMemberProvider>(
                        context,
                        listen: false);
                    final newMemberId = await provider.addFamilyMember(newMember);

                    if (newMemberId != null) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Membro famiglia aggiunto con successo')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Impossibile aggiungere membro famiglia')),
                      );
                    }
                  },
                  child: const Text('Aggiungi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMemberDialog(BuildContext context, FamilyMember member) {
    final TextEditingController nameController =
        TextEditingController(text: member.name);
    Color selectedColor = ColorUtils.hexToColor(member.color);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifica Membro Famiglia'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Seleziona Colore:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ColorUtils.getColorOptions().map((color) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inserisci un nome')),
                      );
                      return;
                    }

                    FamilyMember updatedMember = member.copyWith(
                      name: nameController.text.trim(),
                      color: ColorUtils.colorToHex(selectedColor),
                    );

                    final provider = Provider.of<FamilyMemberProvider>(
                        context,
                        listen: false);
                    bool success =
                        await provider.updateFamilyMember(member.id, updatedMember);

                    if (success) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Membro famiglia aggiornato con successo')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Impossibile aggiornare membro famiglia')),
                      );
                    }
                  },
                  child: const Text('Aggiorna'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteMember(BuildContext context, FamilyMember member) {
    // Check if user is trying to delete themselves
    final currentUserProvider =
        Provider.of<CurrentUserProvider>(context, listen: false);
    if (currentUserProvider.currentUser?.id == member.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Non puoi eliminare te stesso. Cambia utente prima.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Elimina Membro Famiglia'),
          content: Text(
              'Sei sicuro di voler eliminare ${member.name}? Questa azione non può essere annullata.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                final provider =
                    Provider.of<FamilyMemberProvider>(context, listen: false);
                bool success = await provider.deleteFamilyMember(member.id);

                Navigator.pop(dialogContext);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Membro famiglia eliminato con successo')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Impossibile eliminare membro famiglia')),
                  );
                }
              },
              child: const Text('Elimina', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
