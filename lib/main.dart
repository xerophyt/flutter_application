import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        primaryColor: Colors.blue, // Customize the primary color
        fontFamily: 'Roboto', // Set the default font family
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showPassword = false;
  String errorMessage = '';

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[\w-]+(?:\.[\w-]+)*@gmail\.com$',
    );
    return emailRegExp.hasMatch(email);
  }

  Future<void> login(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    if (!_isValidEmail(email)) {
      setState(() {
        errorMessage = 'Please enter a valid Gmail address.';
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(user: userCredential.user!),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Login failed: ${e.toString()}';
      });
    }
  }

  Future<void> signUp(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    if (!_isValidEmail(email)) {
      setState(() {
        errorMessage = 'Please enter a valid Gmail address.';
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(user: userCredential.user!),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Sign up failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/background.webp'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.android,
                size: 50,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.white), // Customize text color
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white), // Customize label text color
                prefixIcon: Icon(Icons.email, color: Colors.white), // Customize icon color
                filled: true,
                fillColor: Colors.black.withOpacity(0.3), // Customize background color
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: passwordController,
              obscureText: !showPassword,
              style: TextStyle(color: Colors.white), // Customize text color
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white), // Customize label text color
                prefixIcon: Icon(Icons.lock, color: Colors.white), // Customize icon color
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3), // Customize background color
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  errorMessage = '';
                });
                login(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Customize button background color
                onPrimary: Colors.white, // Customize button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  errorMessage = '';
                });
                signUp(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // Customize button background color
                onPrimary: Colors.blue, // Customize button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.blue), // Add border to the button
                ),
              ),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user, Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController shiftdetailsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  ImageProvider? profileImage;
  bool isLoading = true;
  DateTime? selectedDate;
  bool isFormComplete = false;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final userId = widget.user.uid;
    final profileDoc =
        await FirebaseFirestore.instance.collection('profiles').doc(userId).get();
    if (profileDoc.exists) {
      final data = profileDoc.data() as Map<String, dynamic>;
      setState(() {
        nameController.text = data['name'];
        roleController.text = data['role'];
        departmentController.text = data['department'];
        emailController.text = data['email'];
        phoneNumberController.text = data['phoneNumber'];
        genderController.text = data['gender'];
        selectedGender = data['gender'];
        shiftdetailsController.text = data['shiftdetails'];

        final dateOfBirth = data['dateOfBirth'];
        if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
          selectedDate = DateTime.tryParse(dateOfBirth);
          dateOfBirthController.text = selectedDate != null
              ? DateFormat('dd-MM-yyyy').format(selectedDate!)
              : '';
        } else {
          selectedDate = null;
          dateOfBirthController.text = '';
        }

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File image = File(pickedFile.path);
      setState(() {
        profileImage = FileImage(image);
      });
    }
  }

  Future<void> saveProfileData() async {
    final userId = widget.user.uid;
    final name = nameController.text.trim();
    final role = roleController.text.trim();
    final department = departmentController.text.trim();
    final email = emailController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();
    final gender = genderController.text.trim();
    final shiftdetails = shiftdetailsController.text.trim();

    // Form validation check
    if (name.isEmpty ||
        role.isEmpty ||
        department.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        gender.isEmpty ||
        selectedDate == null ||
        shiftdetails.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Form'),
          content: const Text('Please fill in all the fields.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Email validation check
    if (!_isValidEmail(email)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid Email'),
          content: const Text('Please enter a valid email address.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Phone number validation check
    if (!validatePhoneNumber(phoneNumber)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid Phone Number'),
          content: const Text('Please enter a valid 10-digit phone number.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('profiles').doc(userId).set({
        'name': name,
        'role': role,
        'department': department,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'dateOfBirth': selectedDate!.toIso8601String(),
        'shiftdetails': shiftdetails,
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Profile Saved'),
          content: const Text('Your profile has been saved successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to save profile. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      print('Error saving profile data: $e');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logged Out'),
        content: const Text('Logged out successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[\w-]+(?:\.[\w-]+)*@gmail\.com$',
    );
    return emailRegExp.hasMatch(email);
  }

  bool validatePhoneNumber(String value) {
    // Validate that the phone number has exactly 10 digits
    if (value.length != 10) {
      return false;
    }
    return true;
  }

  List<String> genderOptions = ['Male', 'Female', 'Other'];
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: profileImage,
                      child: profileImage == null
                          ? const Icon(Icons.person, size: 80)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: roleController,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    items: genderOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: dateOfBirthController,
                    keyboardType: TextInputType.datetime,
                    onTap: () {
                      _selectedDate(context);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: shiftdetailsController,
                    decoration: const InputDecoration(
                      labelText: 'Shift Details',
                      prefixIcon: Icon(Icons.timer),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: saveProfileData,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _selectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateOfBirthController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }
}
