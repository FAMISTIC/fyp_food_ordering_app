// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

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
    MaterialPageRoute(builder: (context) => const ImageListScreen()),
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
        title: const Center(child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: Padding(
            padding: EdgeInsets.only(right: 55.0),
            child: Text('Recommend Food'),
          )),
        )),
        titleSpacing: 0.0,
        elevation: 0.0,
        backgroundColor: const Color.fromARGB(255, 129, 18, 18),
        shadowColor: Colors.grey,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
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
                decoration: const InputDecoration(
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
              /*_imageUrl != null
                  ? Image.network(_imageUrl!, height: 300)
                  : const SizedBox.shrink(),*/
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
              String documentId = document.id;

              return ListTile(
                title: Image.network(imageUrl),
                subtitle: Text(imageName),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteDialog(context, documentId);
                  },
                ),
                onTap: () {
                  // The onTap code to update 'status' as before
                  _updateSelectedDocument(context, documentId);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Image"),
          content: const Text("Are you sure you want to delete this image?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteDocument(context, documentId);
                Navigator.pop(context); // Dismiss the dialog after deleting
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteDocument(BuildContext context, String documentId) {
    FirebaseFirestore.instance
        .collection('recommend')
        .doc(documentId)
        .delete()
        .catchError((error) {
          print("Error deleting document: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete image."),
            ),
          );
        });
  }

void _updateSelectedDocument(BuildContext context, String documentId) {
  // Show confirmation dialog
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Image"),
        content: const Text("Are you sure you want to select this image?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel, do nothing
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              
              // Start a batched write
              WriteBatch batch = FirebaseFirestore.instance.batch();

              CollectionReference recommendCollection =
                  FirebaseFirestore.instance.collection('recommend');

              recommendCollection.get().then((querySnapshot) {
                querySnapshot.docs.forEach((doc) {
                  if (doc.id != documentId) {
                    batch.update(doc.reference, {'status': 'removed'});
                  }
                });

                batch.commit().then((_) {
                  recommendCollection
                      .doc(documentId)
                      .update({'status': 'selected'})
                      .then((_) {
                        Navigator.pop(context); // Navigate back after updating
                      })
                      .catchError((error) {
                        print("Error updating document: $error");
                      });
                }).catchError((error) {
                  print("Error committing batch: $error");
                });
              }).catchError((error) {
                print("Error getting documents: $error");
              });
            },
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
}
}
