import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/family_member_model.dart';
import '../models/shopping_item_model.dart';
import '../providers/family_member_provider.dart';
import '../utils/color_utils.dart';

/// Widget for displaying a shopping list item
class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final Function(bool?) onToggle;
  final VoidCallback onDelete;

  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FamilyMemberProvider>(
      builder: (context, familyMemberProvider, child) {
        // Find the family member who added this item
        FamilyMember? addedByMember;
        try {
          addedByMember = familyMemberProvider.familyMembers
              .firstWhere((m) => m.id == item.addedBy);
        } catch (_) {
          addedByMember = null;
        }
        final memberName = addedByMember?.name;
        final memberColor = addedByMember != null
            ? ColorUtils.hexToColor(addedByMember.color)
            : Colors.grey;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: item.isPurchased ? 0 : 2,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Checkbox(
              value: item.isPurchased,
              onChanged: onToggle,
              activeColor: Colors.green,
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                decoration: item.isPurchased
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: item.isPurchased ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: memberName != null
                ? Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: memberColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Aggiunto da $memberName',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmation(context);
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Elimina Articolo'),
          content: Text('Sei sicuro di voler eliminare "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: const Text('Elimina', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
