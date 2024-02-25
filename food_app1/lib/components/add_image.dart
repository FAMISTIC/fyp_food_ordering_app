import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
class StoreData{
  Future<String> uploadImageToStorage(String childName, Uint8List file,  String userId) async{
      Reference ref = _firebaseStorage.ref().child(childName).child(userId);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
  }

  Future<String> saveData({
    required Uint8List file,
    required String id,
    
  }) async{
    String resp = "Some error happened";
   try{
    String imageUrl = await uploadImageToStorage('profileImage', file, id);
    //await _firebaseFirestore.collection('users').add({'imageLink':imageUrl});
    await _firebaseFirestore.collection('users').doc(id).update({'imageLink': imageUrl});

    resp = 'success';
    
  }catch(err){
    resp=err.toString();
  }
  return resp;
}
}