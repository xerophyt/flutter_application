import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginPage({super.key});

  Future<void> login(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Login')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 100,
                color: Theme.of(context).primaryColor,
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
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () => login(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

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

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final userId = widget.user.uid;
    final profileDoc = await FirebaseFirestore.instance.collection('profiles').doc(userId).get();
    if (profileDoc.exists) {
      final data = profileDoc.data() as Map<String, dynamic>;
      setState(() {
        nameController.text = data['name'];
        roleController.text = data['role'];
        departmentController.text = data['department'];
        emailController.text = data['email'];
        phoneNumberController.text = data['phoneNumber'];
        genderController.text = data['gender'];
        dateOfBirthController.text = data['dateOfBirth'];
        shiftdetailsController.text = data['shiftdetails'];
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

    try {
      await FirebaseFirestore.instance.collection('profiles').doc(userId).set({
        'name': nameController.text,
        'role': roleController.text,
        'department': departmentController.text,
        'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
        'gender': genderController.text,
        'dateOfBirth': dateOfBirthController.text,
        'shiftdetails': shiftdetailsController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Your Profile')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              InkWell(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage,
                  child: profileImage == null
                      ? Icon(
                          Icons.person,
                          size: 100,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: shiftdetailsController,
                decoration: const InputDecoration(
                  labelText: 'Shift Details',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => saveProfileData(),
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
