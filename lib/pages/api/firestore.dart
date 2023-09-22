// import 'package:cloud_firestore/cloud_firestore.dart';

// class DatabaseManager {
//   final CollectionReference bookList =
//       Firestore.instance.collection('Books');

//   Future<void> createUserData(
//       String name, String gender, int score, String uid) async {
//     return await bookList
//         .document(uid)
//         .setData({'name': name, 'gender': gender, 'score': score});
//   }

//   Future updateUserList(String name, String gender, int score, String uid) async {
//     return await bookList.document(uid).updateData({
//       'name': name, 'gender': gender, 'score': score
//     });
//   }

//   Future getUsersList() async {
//     List itemsList = [];

//     try {
//       await bookList.getDocuments().then((querySnapshot) {
//         querySnapshot.documents.forEach((element) {
//           itemsList.add(element.data);
//         });
//       });
//       return itemsList;
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }
// }
