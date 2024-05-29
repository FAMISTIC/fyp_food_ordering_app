import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/pages/reservation_history_page.dart';
import 'package:intl/intl.dart';

class TableReservationPage extends StatefulWidget {
  final AppUser user;

  const TableReservationPage({Key? key, required this.user}) : super(key: key);

  @override
  _TableReservationPageState createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Add a list to store the selected tables
  final List<String> _selectedTables = [];

  List<String> _userReservations = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    List<int> availableTables = List.generate(10, (index) => index + 1)
      ..removeWhere((table) => _userReservations.contains('Table $table'));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Center(child: Text('Table Reservation')),
        titleSpacing: 0.0,
        elevation: 0.0,
        backgroundColor: const Color.fromARGB(225, 245, 93, 66),
        shadowColor: Colors.grey,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ReservationHistoryPage(user: widget.user)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(225, 245, 93, 66),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(225, 245, 93, 66),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(224, 234, 47, 13),
                      width: 2,
                    ),
                  ),
                ),
                controller: TextEditingController(text: _dateFormat.format(_selectedDate)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                onTap: () => _selectTime(context),
                decoration: InputDecoration(
                  labelText: 'Time',
                  suffixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(225, 245, 93, 66),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(225, 245, 93, 66),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(224, 234, 47, 13),
                      width: 2,
                    ),
                  ),
                ),
                controller: TextEditingController(text: _selectedTime.format(context)),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: availableTables.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text('Table ${availableTables[index]}'),
                      value: _selectedTables.contains('Table ${availableTables[index]}'),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _selectedTables.add('Table ${availableTables[index]}');
                          } else {
                            _selectedTables.remove('Table ${availableTables[index]}');
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(225, 245, 93, 66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                onPressed: _submitReservation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: const Center(
                      child: Text(
                    'Make Booking',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchUserDetails() async {
    AppUser? userDetails =
        await FirebaseAuthService().getUserDetails(widget.user.uid);

    if (userDetails != null) {
      // Clear previous reservations to avoid duplication
      _userReservations.clear();

      // Retrieve the user's reservations
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('table_reservation')
          .get()
          .then((querySnapshot) {
        setState(() {
          querySnapshot.docs.forEach((doc) {
            _userReservations.addAll(List<String>.from(doc['tables']));
          });
        });
      });
    } else {
      print("Error fetching user details.");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTables.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a table')),
        );
        return;
      }

      String userId = widget.user.uid;

      CollectionReference tableReservationCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('table_reservation');

      // Lock selected tables
      tableReservationCollection.add({
        'Date': _dateFormat.format(_selectedDate),
        'Time': _selectedTime.format(context),
        'status': 'pending',
        'tables': _selectedTables, // Add the selected tables to the reservation data
      }).then((value) {
        // Refresh user details and UI after successful reservation
        _fetchUserDetails();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation successful')),
        );

        // Clear selected tables
        setState(() {
          _selectedTables.clear();
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to make reservation: $error')),
        );
      });
    }
  }
}
