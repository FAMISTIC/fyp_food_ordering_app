// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:food_app1_admin/feedback.dart';
import 'package:food_app1_admin/food_item.dart';
import 'package:food_app1_admin/notify_user.dart';
import 'package:food_app1_admin/order_page.dart';
import 'package:food_app1_admin/recommend.dart';
import 'package:food_app1_admin/table_reservation.dart';
import 'package:food_app1_admin/user_account.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends  State<HomePage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: Padding(
            padding: EdgeInsets.only(right: 55.0),
            child: Text('Home Page'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200], // Adding background color
              child: ListTile(
                leading: const Icon(Icons.note, color: Color.fromARGB(255, 129, 18, 18),),
                title: const Text(
                  'Food Order',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward), // Adding a trailing icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200], // Adding background color
              child: ListTile(
                leading: const Icon(Icons.table_bar, color: Color.fromARGB(255, 129, 18, 18),),
                title: const Text(
                  'Table Reservation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward), // Adding a trailing icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TableReservationPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200], // Adding background color
              child: ListTile(
                leading: const Icon(Icons.person, color: Color.fromARGB(255, 129, 18, 18),),
                title: const Text(
                  'User Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward), // Adding a trailing icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200], // Adding background color
              child: ListTile(
                leading: const Icon(Icons.feedback, color: Color.fromARGB(255, 129, 18, 18),),
                title: const Text(
                  'Customer Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward), // Adding a trailing icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FeedbackListPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200], // Adding background color
              child: ListTile(
                leading: const Icon(Icons.food_bank, color: Color.fromARGB(255, 129, 18, 18),),
                title: const Text(
                  'Food Menu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward), // Adding a trailing icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FoodPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200], // Adding background color
              child: ListTile(
                leading: const Icon(Icons.notification_important, color: Color.fromARGB(255, 129, 18, 18),),
                title: const Text(
                  'Notify Users',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward), // Adding a trailing icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotifyPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200], // Adding background color
              child: ListTile(
                leading: const Icon(Icons.recommend, color: Color.fromARGB(255, 129, 18, 18),),
                title: const Text(
                  'Recommend Food',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward), // Adding a trailing icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecommendPage()),
                  );
                },
              ),
            ),
            
           ],
          ),   
        ),
      ),
    );
  }
}

