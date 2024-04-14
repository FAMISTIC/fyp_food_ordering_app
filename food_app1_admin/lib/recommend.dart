import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({Key? key}) : super(key: key);

  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  late File _imageFile = File('');
  String? _imageUrl;
  TextEditingController _imageNameController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadImage() async {
    try {
      // Upload image to Firebase Storage
      String fileName = _imageNameController.text.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : _imageNameController.text;
      Reference ref = _storage.ref().child('recommendImage/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(_imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Save image metadata to Firestore
      await _firestore.collection('recommend').add({
        'imageName': fileName,
        'imageUrl': imageUrl,
        'uploadedAt': DateTime.now(),
      });

      setState(() {
        _imageUrl = imageUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Image uploaded successfully!'),
      ));
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to upload image. Please try again.'),
      ));
    }
  }

  void _viewAllImages() async {
  final selectedImageUrl = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ImageListScreen()),
  );
  if (selectedImageUrl != null) {
    setState(() {
      _imageUrl = selectedImageUrl;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload Demo'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageFile.path.isNotEmpty
                  ? Image.file(_imageFile, height: 300)
                  : const Placeholder(
                      fallbackHeight: 200,
                      fallbackWidth: 200,
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: const Text('Take Photo'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _imageNameController,
                decoration: InputDecoration(
                  labelText: 'Image Name',
                  hintText: 'Enter the name of the image',
                ),
              ),
              ElevatedButton(
                onPressed:
                    _imageFile.path.isNotEmpty ? _uploadImage : null,
                child: const Text('Upload Image'),
              ),
              ElevatedButton(
                onPressed: _viewAllImages,
                child: const Text('View All Images'),
              ),
              _imageUrl != null
                  ? Image.network(_imageUrl!, height: 300)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageListScreen extends StatelessWidget {
  const ImageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Images'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('recommend').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              String imageUrl = document['imageUrl'];
              String imageName = document['imageName'];
              return ListTile(
                title: Image.network(imageUrl),
                subtitle: Text('$imageName'),
                onTap: () {
                  String documentId = document.id;
                  CollectionReference recommendCollection = FirebaseFirestore.instance.collection('recommend');
                  
                  // Start a batched write
                  WriteBatch batch = FirebaseFirestore.instance.batch();

                  // Update all documents to set 'status' to 'removed' except the selected one
                  recommendCollection.get().then((querySnapshot) {
                    querySnapshot.docs.forEach((doc) {
                      if (doc.id != documentId) {
                        batch.update(doc.reference, {'status': 'removed'});
                      }
                    });

                    // Commit the batched write
                    batch.commit().then((_) {
                      // Update the selected document
                      recommendCollection.doc(documentId).update({'status': 'selected'}).then((_) {
                        // Optionally, you can also navigate back after updating the document
                        Navigator.pop(context, imageUrl);
                      }).catchError((error) {
                        print('Error updating document: $error');
                        // Handle error accordingly
                      });
                    }).catchError((error) {
                      print('Error updating documents: $error');
                      // Handle error accordingly
                    });
                  }).catchError((error) {
                    print('Error getting documents: $error');
                    // Handle error accordingly
                  });
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
