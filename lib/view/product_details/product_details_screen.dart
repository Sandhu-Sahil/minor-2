import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences package

import '../../model/product.dart';
import 'components/product_carousel_slider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  NumberFormat formatter = NumberFormat('00');
  int _qty = 1;
  int _tagIndex = 0;

  Future<void> addToCart(Product product, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Calculate the final price based on the selected tag and quantity
    double finalPrice = product.tags[_tagIndex].price * quantity;

    // Get the selected tag name with quatity
    String tagName = product.tags[_tagIndex].title + ' x ' + formatter.format(quantity);

    // Create a map with the necessary fields
    Map<String, dynamic> cartItem = {
      'name': product.name,
      'images': product.images,
      'finalPrice': finalPrice,
      'tagName': tagName,
    };

    // Fetch existing cart items or initialize an empty list
    List cartItems = prefs.getStringList('cart_items')?.map((item) => jsonDecode(item)).toList() ?? [];

    // Add the new item to the cart
    cartItems.add(cartItem);

    // Convert the list of maps to a list of JSON strings
    List<String> cartItemsJson = cartItems.map((item) => jsonEncode(item)).toList();

    // Save the updated cart items
    await prefs.setStringList('cart_items', cartItemsJson);

    // Show a dialog to confirm that the item has been added to the cart
    // Show a snackbar indicating that the item has been added to the cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating, // Make the snackbar float over the screen
        
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8), // Change background color
        content: Text(
          'Item added to cart: ${product.name}',
          style: const TextStyle(color: Colors.white), // Change text color
        ),
        duration: const Duration(seconds: 2), // Adjust the duration as needed
        shape: RoundedRectangleBorder( // Make edges round
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     behavior: SnackBarBehavior.floating, // Make the snackbar float over the screen
    //     backgroundColor: Colors.white.withOpacity(0.9), // Change background color to a lighter shade
    //     content: Text(
    //       'Item added to cart: ${product.name}',
    //       style: const TextStyle(color: Colors.black), // Change text color to black
    //     ),
    //     duration: const Duration(seconds: 3), // Increase the duration to slow down the floating
    //     shape: RoundedRectangleBorder( // Make edges round
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductCarouselSlider(
              images: widget.product.images,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.product.name,
                style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '\$${widget.product.tags.first.price.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (_qty > 1) {
                              setState(() {
                                _qty--;
                              });
                            }
                          },
                          child: Icon(
                            Icons.keyboard_arrow_left_sharp,
                            size: 32,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          formatter.format(_qty),
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade800),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _qty++;
                            });
                          },
                          child: Icon(
                            Icons.keyboard_arrow_right_sharp,
                            size: 32,
                            color: Colors.grey.shade800,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (_tagIndex > 0) {
                              setState(() {
                                _tagIndex--;
                              });
                            }
                          },
                          child: Icon(
                            Icons.keyboard_arrow_left_sharp,
                            size: 32,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          widget.product.tags[_tagIndex].title,
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade800),
                        ),
                        InkWell(
                          onTap: () {
                            if (_tagIndex !=
                                (widget.product.tags.length - 1)) {
                              setState(() {
                                _tagIndex++;
                              });
                            }
                          },
                          child: Icon(
                            Icons.keyboard_arrow_right_sharp,
                            size: 32,
                            color: Colors.grey.shade800,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'About this product:',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.product.description,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor:
                MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
          ),
          onPressed: () {
            addToCart(widget.product, _qty); // Call addToCart function on button press
          },
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Text(
              'Add to Card',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
