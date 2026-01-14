import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/family_member_provider.dart';
import '../models/family_member_model.dart';

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
        title: const Text('Settings', style: TextStyle(fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Family Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Family Members',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddMemberDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
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
                      Text('No family members found. Use the Add button to create new members.'),
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
                            color: _hexToColor(member.color),
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
              'About',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version', style: TextStyle(fontSize: 18)),
              subtitle: Text('1.0.0'),
            ),
            const ListTile(
              leading: Icon(Icons.family_restroom),
              title: Text('Family Management App',
                  style: TextStyle(fontSize: 18)),
              subtitle: Text('Manage your family calendar and shopping list'),
            ),
          ],
        ),
      ),
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
              title: const Text('Add Family Member'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Color:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getColorOptions().map((color) {
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a name')),
                      );
                      return;
                    }

                    FamilyMember newMember = FamilyMember(
                      id: '',
                      name: nameController.text.trim(),
                      color: _colorToHex(selectedColor),
                    );

                    final provider = Provider.of<FamilyMemberProvider>(
                        context,
                        listen: false);
                    bool success = await provider.addFamilyMember(newMember);

                    if (success) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Family member added successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to add family member')),
                      );
                    }
                  },
                  child: const Text('Add'),
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
    Color selectedColor = _hexToColor(member.color);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Family Member'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Color:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getColorOptions().map((color) {
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a name')),
                      );
                      return;
                    }

                    FamilyMember updatedMember = member.copyWith(
                      name: nameController.text.trim(),
                      color: _colorToHex(selectedColor),
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
                            content: Text('Family member updated successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to update family member')),
                      );
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteMember(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Family Member'),
          content: Text(
              'Are you sure you want to delete ${member.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
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
                        content: Text('Family member deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to delete family member')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  List<Color> _getColorOptions() {
    return [
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFFE91E63), // Pink
      const Color(0xFFF44336), // Red
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF9800), // Orange
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFFFFEB38), // Lime
      const Color(0xFFFF5722), // Deep Orange
    ];
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
