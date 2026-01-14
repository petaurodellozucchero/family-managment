import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/family_member_model.dart';

/// Settings screen for managing family members
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Family Members Section
            Text(
              'Family Members',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            StreamBuilder<List<FamilyMember>>(
              stream: _firebaseService.getFamilyMembersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error loading family members');
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      Text('No family members found'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await _firebaseService.initializeDefaultFamilyMembers();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Default family members added')),
                          );
                        },
                        child: Text('Initialize Default Members'),
                      ),
                    ],
                  );
                }

                List<FamilyMember> members = snapshot.data!;

                return Column(
                  children: members.map((member) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(member.color),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 32),
            
            // App Information
            Divider(),
            SizedBox(height: 16),
            Text(
              'About',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version', style: TextStyle(fontSize: 18)),
              subtitle: Text('1.0.0'),
            ),
            ListTile(
              leading: Icon(Icons.family_restroom),
              title: Text('Family Management App', style: TextStyle(fontSize: 18)),
              subtitle: Text('Manage your family calendar and shopping list'),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
