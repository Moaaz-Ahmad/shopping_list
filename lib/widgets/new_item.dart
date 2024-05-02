import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _enteredCategory = categories[Categories.vegetables]!;
  var _isSending = false;
  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https('flutter-prep-6a331-default-rtdb.firebaseio.com', 'shopping-list.json');
      final response = await http.post(url, 
      headers: {'Content-Type': 'application/json'}, 
      body: json.encode({
        'name': _enteredName,
        'quantity': _enteredQuantity,
        'category': _enteredCategory.name,
      }));
      // Navigator.of(context).pop(GroceryItem(id: DateTime.now().toString(), name: _enteredName, quantity: _enteredQuantity, category: _enteredCategory));
    final Map<String,dynamic> resData = json.decode(response.body);
    if (!context.mounted){
      return;
    }
    response.statusCode == 200 ? Navigator.of(context).pop(GroceryItem(id:resData['name'], name: _enteredName, quantity: _enteredQuantity, category: _enteredCategory)) : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add item')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration:const  InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().length <= 1 || value.trim().length > 50){
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty || int.tryParse(value) == null || int.tryParse(value)! <= 0){
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _enteredCategory,
                      items: [
                      for (final category in categories.entries)
                        DropdownMenuItem(
                          value: category.value,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: category.value.color,
                              ),
                              const SizedBox(width: 12),
                              Text(category.value.name),
                            ],
                          ),
                        )
                    ], onChanged: (value) {
                      setState(() {
                        _enteredCategory = value!;
                      });
                    },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed:_isSending ? null : (){ _formKey.currentState!.reset();}, child: const Text('Reset')),
                  ElevatedButton(onPressed: _isSending? null : _saveItem, child:_isSending ? const SizedBox(height: 16,width: 16,child: CircularProgressIndicator()) : const Text('Add Item'),),
                ],
              ),
            ],
                ),
        ),
    ),
    );
  }
}