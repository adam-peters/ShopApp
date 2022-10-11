import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final double price;
  // final String imageUrl;
  //
  // ProductItem(this.id, this.title, this.price, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: product.id,);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        header: Text(
          product.title,
          textAlign: TextAlign.center,
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              product.toggleFavoriteStatus();
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart,),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Added to Cart!"),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: "Undo",
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  )
              );
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(product.price.toString(), textAlign: TextAlign.center,),
        ),
      ),
    );
  }
}
