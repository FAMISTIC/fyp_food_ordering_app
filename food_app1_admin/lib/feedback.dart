import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FeedbackListPage extends StatefulWidget {
  const FeedbackListPage({Key? key}) : super(key: key);

  @override
  _FeedbackListPageState createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 55.0),
                child: Text('Customer Feedback'),
              ),
            ),
          ),
        ),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              // Check if user's name is "admin", if yes, skip rendering
              if (user['name'] == "admin") {
                return const SizedBox(); // Return an empty SizedBox to skip rendering
              }

              return FutureBuilder(
                future: user.reference.collection('feedback').get(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final feedback = snapshot.data!.docs;
                  if (feedback.isEmpty) {
                    return const SizedBox(); // Return an empty SizedBox to skip rendering if no feedback
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          user['name'], // Assuming 'name' is a field in your user document
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        children: feedback.map((feedback) {
                          final date = feedback['timestamp'] != null
                              ? DateFormat('yyyy-MM-dd').format((feedback['timestamp'] as Timestamp).toDate())
                              : 'Not Available';
                          final feedbacknote = feedback['feedbacknote'] ?? 'Not Available';

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date: $date'),
                                    Text('Feedback: $feedbacknote'),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await feedback.reference.delete();
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
