import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../const.dart';

class ProductCart extends StatefulWidget {
  const ProductCart({Key? key}) : super(key: key);

  @override
  _ProductCartState createState() => _ProductCartState();
}

class _ProductCartState extends State<ProductCart> {
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsJson = prefs.getStringList('cart_items');
    if (cartItemsJson != null) {
      setState(() {
        _cartItems = cartItemsJson.map((item) => jsonDecode(item)).toList().cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _removeItemFromCart(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _cartItems.removeAt(index);
    });
    List<String> updatedCartItems = _cartItems.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('cart_items', updatedCartItems);
  }

  double _calculateTotalCost() {
    double totalCost = 0;
    for (var item in _cartItems) {
      totalCost += item['finalPrice'];
    }
    return totalCost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(baseUrl + _cartItems[index]['images'][0]), // Assuming the first image URL is used
            ),
            title: Text(_cartItems[index]['name'] + ' (' + _cartItems[index]['tagName'] + ')'),
            subtitle: Text('Price: \$${_cartItems[index]['finalPrice']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _removeItemFromCart(index);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${_calculateTotalCost()}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  // Place order functionality
                },
                child: const Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
