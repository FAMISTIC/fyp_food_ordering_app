import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_app1_admin/constraints/textfield.dart';
import 'package:food_app1_admin/food_model.dart';

class AddFood extends StatefulWidget {
  const AddFood({Key? key}) : super(key: key);

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController imagePathController = TextEditingController(); // New controller for image path
  TextEditingController typeController = TextEditingController(); 

  _clearText() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    typeController.clear();
    imagePathController.clear(); // Clear image path controller
  }

  Future<void> addFoodDetails(Food food) async {
    try {
      CollectionReference foods = FirebaseFirestore.instance.collection('foods');

      await foods.add({
        'name': food.name,
        'description': food.description,
        'price': food.price,
        'imagePath': food.imagePath, // Save image path to Firestore
        'type' : food.type,
      });
    } catch (e) {
      print("Failed to add food details: $e");
    }
  }

  Food _createFoodObject() {
    String name = nameController.text;
    String description = descriptionController.text;
    double price = double.tryParse(priceController.text) ?? 0.0;
    String foodid = "some_generated_id";
    String imagePath = imagePathController.text; // Get image path from the controller
    String type = typeController.text;

    return Food(
        foodid: foodid,
        name: name,
        description: description,
        price: price,
        imagePath: imagePath,
        type: type);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imagePathController.dispose(); // Dispose image path controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
      ),
      body: Form(
        key: _formkey,
        child: ListView(
          children: [
            CustomTextEditField(
              controller: nameController,
              labettxt: 'Name',
            ),
            CustomTextEditField(
              controller: descriptionController,
              labettxt: 'Desciption',
            ),
            CustomTextEditField(
              controller: priceController,
              labettxt: 'Price',
            ),
            CustomTextEditField(
              controller: typeController,
              labettxt: 'Type', // New field for image path
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        Food newFood = _createFoodObject();
                        addFoodDetails(newFood);
                        Navigator.pop(context);
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  child: const Text('Add'),
                ),
                ElevatedButton(
                  onPressed: _clearText,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
