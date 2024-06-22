import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_app1_admin/add_image.dart';
import 'package:food_app1_admin/utils.dart';
import 'package:image_picker/image_picker.dart';

class EditFood extends StatefulWidget {
  const EditFood({
    Key? key,
    required this.docID,
  }) : super(key: key);
  
  final String docID;

  @override
  State<EditFood> createState() => _EditFoodState();
}

class _EditFoodState extends State<EditFood> {
  Uint8List? _image;

  // Form key
  final _formKey = GlobalKey<FormState>();

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void saveFoodImage() async {
    try {
      if (_image != null) {
        String resp = await StoreData().saveData(file: _image!, id: widget.docID);
        print(resp); // Handle the response accordingly
      } else {
        print("Image is null. Cannot save profile.");
      }
    } catch (err) {
      print(err.toString()); // Handle error appropriately
    }
  }

  // Update User
  CollectionReference updateFood =
      FirebaseFirestore.instance.collection('foods');

  Future<void> _updateUser(id, name, description, price, type) {
    return updateFood
        .doc(id)
        .update({
          'name': name,
          'description': description,
          'price': price,
          'type' : type
        })
        .then((value) => print("Food Updated"))
        .catchError((error) => print("Failed to update food: $error"));
  }

  void _showConfirmationDialog(String id, String name, String description, String price, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Update"),
          content: const Text("Are you sure you want to update this food item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateUser(id, name, description, price, type);
                  saveFoodImage();
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pop(context); // Close the form
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('foods').doc(widget.docID).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Something Wrong in Food Page');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Getting Data From Firestore
        var data = snapshot.data?.data();
        var name = data!['name'];
        var description = data['description'];
        var price = data['price'];
        var type = data['type'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                Stack(
                  children: [
                    _image != null
                        ? Container(
                            height: 200,
                            width: 400,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              image: DecorationImage(
                                image: MemoryImage(_image!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Center(
                          child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                          iconSize: 200,
                        ),
                      ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 15,
                  ),
                  child: TextFormField(
                    initialValue: name,
                    onChanged: (value) {
                      name = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(fontSize: 18),
                      errorStyle: TextStyle(color: Colors.red, fontSize: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please Fill Food Name';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 15,
                  ),
                  child: TextFormField(
                    initialValue: description,
                    onChanged: (value) {
                      description = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(fontSize: 18),
                      errorStyle: TextStyle(color: Colors.red, fontSize: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please Fill Description';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 15,
                  ),
                  child: TextFormField(
                    initialValue: type,
                    onChanged: (value) {
                      type = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      labelStyle: TextStyle(fontSize: 18),
                      errorStyle: TextStyle(color: Colors.red, fontSize: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please Fill Type';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 15,
                  ),
                  child: TextFormField(
                    initialValue: price?.toString(),
                    onChanged: (value) {
                      price = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(fontSize: 18),
                      errorStyle: TextStyle(color: Colors.red, fontSize: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please Fill The Price';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 15,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _showConfirmationDialog(widget.docID, name, description, price, type);
                        }
                      },
                      child: const Text('Update'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
