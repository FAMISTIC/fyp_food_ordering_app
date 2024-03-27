import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1/components/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_app1/components/add_image.dart';
//import 'package:permission_handler/permission_handler.dart';


class UserProfilePage extends StatefulWidget {
  final AppUser user;

  const UserProfilePage({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  Uint8List? _image;

  // Create a form key to validate the input fields
  final _formKey = GlobalKey<FormState>();

  // Create text editing controllers to get the input values
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  // Create a boolean variable to show loading indicator
  bool _loading = false;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }
  void saveProfile() async {
  try {
    if (_image != null) {
      String resp = await StoreData().saveData(file: _image!, id: widget.user.uid);
      print(resp); // Handle the response accordingly
    } else {
      print("Image is null. Cannot save profile.");
    }
  } catch (err) {
    print(err.toString()); // Handle error appropriately
  }
}

  @override
  void initState() {
    super.initState();
    // Initialize the text editing controllers with the user data
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone.toString());
  }

  @override
  void dispose() {
    // Dispose the text editing controllers when not needed
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  //Future<bool> requestStoragePermission() async {
  //    final status = await Permission.storage.request();
   //   return status == PermissionStatus.granted;
  //}
  

  // Define a function to update the user data
  Future<void> _updateUserData() async {
      

    // Validate the input fields
    if (_formKey.currentState!.validate()) {
      // Get the input values
      String name = _nameController.text;
      String phone = _phoneController.text;
      


      // Set the loading state to true
      setState(() {
        _loading = true;
      });

      // Get a reference to the user document by its ID
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.user.uid);

      // Update only the name and age fields of the user document
      userRef.update({'name': name, 'phone': phone}).then((_) {
        // Set the loading state to false
        setState(() {
          _loading = false;
        });
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((error) {
        // Set the loading state to false
        setState(() {
          _loading = false;
        });
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong! Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          // Use an icon button to trigger the update function and the save data function
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: ()=>[_updateUserData(),saveProfile()],
          ),
        ],
      ),
      body: _loading
          // Show a circular progress indicator if loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          // Show a form with input fields if not loading
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                       // Use a StreamBuilder to display the image from Firestore
                       _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                              'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                        ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                      ),
                      ),
                      ],
                    ),
                      Text('Name: ${_nameController.text}'),
                      Text('Phone: ${_phoneController.text}'),
                    // Name input field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        // Validate the name input
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Age input field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        // Validate the age input
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Add more user profile details if needed
                  ],
                ),
              ),
            ),
    );
  }
}
