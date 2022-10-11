import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(id: "", title: "", description: "", price: 0, imageUrl: "");
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(_isInit) {
      if(ModalRoute.of(context)!.settings.arguments != null) {
        final productId = ModalRoute.of(context)!.settings.arguments as String;
        if(productId.isNotEmpty) {
          _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
          _initValues = {
            'title': _editedProduct.title,
            'description': _editedProduct.description,
            'price': _editedProduct.price.toString(),
            'imageUrl': '',
          };
          _imageUrlController.text = _editedProduct.imageUrl;
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if(!isValid) {
      print("not valid");
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if(_editedProduct.id != "") {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch(error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error Occurred"),
            content: Text("Something went wrong"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("Okay"),
              ),
            ],
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(
              onPressed: _saveForm,
              icon: Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      ) : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(
                  labelText: "Title",
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value) {
                  if(value!.isEmpty) {
                    return "Title is a required field.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                      title: value!,
                      price: _editedProduct.price,
                      id: _editedProduct.id,
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(
                  labelText: "Price",
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value) {
                  if(value!.isEmpty) {
                    return "Price is a required field.";
                  }
                  if(double.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  if(double.parse(value) <= 0) {
                    return "Please enter a value greater than ZERO";
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: double.parse(value!),
                    id: _editedProduct.id,
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(
                  labelText: "Description",
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if(value!.isEmpty) {
                    return "Description is a required field.";
                  }
                  if(value.length < 10) {
                    return "Description should be at least ten characters";
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    id: _editedProduct.id,
                    description: value!,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10,),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: _imageUrlController.text.isEmpty ? Text("Enter a URL") : FittedBox(
                      child: Image.network(
                          _imageUrlController.text,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "Image URL"),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      validator: (value) {
                        if(value!.isEmpty) {
                          return "Image Url is a required field.";
                        }
                        if(!value.startsWith('http') && !value.startsWith('https')) {
                          return "Please enter a valid URL";
                        }
                        if(!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg')) {
                          return "Please enter a valid image Url";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          id: _editedProduct.id,
                          description: _editedProduct.description,
                          imageUrl: value!,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
