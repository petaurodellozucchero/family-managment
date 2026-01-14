import 'package:flutter/material.dart';
import '../models/shopping_item_model.dart';

/// Widget for displaying a shopping list item
class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final Function(bool?) onToggle;
  final VoidCallback onDelete;

  const ShoppingItemTile({
    Key? key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: item.isPurchased ? 0 : 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteConfirmation(context);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
