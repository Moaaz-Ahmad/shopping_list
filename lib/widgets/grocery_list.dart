import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  String? _error;
  var _isLoading = true;
  @override
  void initState() {
    super.initState();
    _laodItems();
  }

  void _laodItems () async {
    final url = Uri.https('flutter-prep-6a331-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    final data = json.decode(response.body) as Map<String, dynamic>;
    final List<GroceryItem> loadedItems = [];
    try {
      data.forEach((itemId, itemData) {
      loadedItems.add(GroceryItem(
        id: itemId,
        name: itemData['name'],
        quantity: itemData['quantity'],
        category: categories.values.firstWhere((category) => category.name == itemData['category']),
      ));
    });
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
    } catch (e) {
      setState(() {
        _error = 'Something Went Wrong';
      });
    }
  }
  void _removeItem(GroceryItem item) async {
      final index = _groceryItems.indexOf(item);
      setState(() {
        _groceryItems.remove(item);
      });
      final url = Uri.https('flutter-prep-6a331-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to delete item';
          _isLoading = false;
          _groceryItems.insert(index, item);
        });
        return;
      }
  }
  void _addItem() async {
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NewItem()),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet'));
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }
    if (_groceryItems.isNotEmpty){
      content = ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (context, index) {
                final item = _groceryItems[index];
                return Dismissible(key: ValueKey(item.id), 
                onDismissed: (direction) {
                  _removeItem(item.id as GroceryItem);
                },
                background: Container(
                  color: Theme.of(context).colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(item.name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: item.category.color,
                  ),
                  trailing: Text(item.quantity.toString(),
                )
                )
                );
              },
            );
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: content,
    );
  }
}