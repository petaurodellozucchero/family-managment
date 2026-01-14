import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/family_member_provider.dart';
import '../providers/current_user_provider.dart';
import '../models/family_member_model.dart';
import '../utils/color_utils.dart';

/// Login screen for selecting user identity
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Who are you?', style: TextStyle(fontSize: 22)),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<FamilyMemberProvider>(
        builder: (context, familyMemberProvider, child) {
          if (familyMemberProvider.isLoading &&
              familyMemberProvider.familyMembers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Select your identity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose who you are from the family members below',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Family members list
                if (familyMemberProvider.familyMembers.isNotEmpty) ...[
                  ...familyMemberProvider.familyMembers.map((member) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FamilyMemberCard(
                        member: member,
                        onTap: () => _selectMember(context, member),
                      ),
                    );
                  }),
                ] else ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No family members found.\nCreate a new member to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Create new member button
                OutlinedButton.icon(
                  onPressed: () => _showCreateMemberDialog(context),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create New Member'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _selectMember(BuildContext context, FamilyMember member) async {
    final currentUserProvider =
        Provider.of<CurrentUserProvider>(context, listen: false);
    await currentUserProvider.setCurrentUser(member);
  }

  void _showCreateMemberDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Member'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Your Color:',
                        style: TextStyle(fontSize: 16)),
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
                        const SnackBar(content: Text('Please enter your name')),
                      );
                      return;
                    }

                    FamilyMember newMember = FamilyMember(
                      id: '',
                      name: nameController.text.trim(),
                      color: ColorUtils.colorToHex(selectedColor),
                    );

                    final familyProvider = Provider.of<FamilyMemberProvider>(
                        context,
                        listen: false);
                    bool success =
                        await familyProvider.addFamilyMember(newMember);

                    if (success) {
                      Navigator.pop(dialogContext);
                      
                      // Wait for the family members list to update
                      final memberName = nameController.text.trim();
                      final memberColorHex = ColorUtils.colorToHex(selectedColor);
                      await familyProvider.waitForLoading();

                      // Find the newly created member and select it
                      if (context.mounted) {
                        final members = familyProvider.familyMembers;
                        final createdMember = members.firstWhere(
                          (m) =>
                              m.name == memberName &&
                              m.color == memberColorHex,
                          orElse: () => members.last,
                        );
                        _selectMember(context, createdMember);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Welcome! Your profile has been created.')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to create profile')),
                        );
                      }
                    }
                  },
                  child: const Text('Create & Login'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Card widget for displaying a family member option
class _FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onTap;

  const _FamilyMemberCard({
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ColorUtils.hexToColor(member.color),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
