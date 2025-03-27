import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define your color palette
const Color primaryGreen = Color(0xFF4CAF50); // A nice green
const Color lightGreen = Color(0xFFE8F5E9);
const Color darkGreen = Color(0xFF388E3C);
const Color accentColor = Color(0xFFFFC107); // A yellow accent

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? userRole = prefs.getString('userRole');

  runApp(FarmAssistApp(isLoggedIn: isLoggedIn, userRole: userRole));
}

class FarmAssistApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? userRole;

  const FarmAssistApp({super.key, required this.isLoggedIn, this.userRole});

  @override
  _FarmAssistAppState createState() => _FarmAssistAppState();
}

class _FarmAssistAppState extends State<FarmAssistApp> {
  late bool _isLoggedIn;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    _userRole = widget.userRole;
  }

  void _updateLoginStatus(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  void _updateUserRole(String? userRole) {
    setState(() {
      _userRole = userRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm-Assist',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto', // Example font family
      ),
      initialRoute: _isLoggedIn ? '/dashboard' : '/',
      // Always go to dashboard after login
      routes: {
        '/':
            (context) => LoginScreen(
              onLoginSuccess: _updateLoginStatus,
              onRoleSelected: _updateUserRole,
            ),
        '/signup': (context) => SignUpScreen(),
        '/dashboard': (context) => const RoleSelectionScreen(),
        '/farmerDetails': (context) => const FarmerDetailsScreen(),
        '/buyerDetails': (context) => const BuyerDetailsScreen(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  final Function(bool) onLoginSuccess;
  final Function(String?) onRoleSelected;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onRoleSelected,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _tryLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usersJson = prefs.getString('users');
      List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

      bool found = false;
      for (var user in users) {
        if (user['email'] == _email && user['password'] == _password) {
          found = true;
          break;
        }
      }

      if (found) {
        await prefs.setBool('isLoggedIn', true);
        widget.onLoginSuccess(true);
        //String? userRole = prefs.getString('userRole');
        //widget.onRoleSelected(userRole);
        //if (userRole == 'Farmer') {
        //  Navigator.pushReplacementNamed(context, '/farmerDetails');
        //} else if (userRole == 'Buyer') {
        //  Navigator.pushReplacementNamed(context, '/buyerDetails');
        //} else {
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
        ); // Always go to dashboard
        //}
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/loginbg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.black54)),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  color: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Farm-Assist',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 63, 131, 100),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value ?? '';
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password cannot be empty.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value ?? '';
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              onPressed: _tryLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  63,
                                  131,
                                  100,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text('Create new account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _trySignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usersJson = prefs.getString('users');
      List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

      // Check if the email already exists
      bool emailExists = users.any((user) => user['email'] == _email);
      if (emailExists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email already exists')));
        return;
      }

      users.add({'email': _email, 'password': _password});
      await prefs.setString('users', jsonEncode(users));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );
      Navigator.pop(context); // Go back to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightGreen, Color(0xFFC8E6C9)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value ?? '';
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value ?? '';
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _trySignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Already have an account? Login',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm-Assist'),
        backgroundColor: primaryGreen,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightGreen, Color(0xFFC8E6C9)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Your Role',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: RoleButton(
                        label: 'Farmer',
                        icon: Icons.agriculture,
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('userRole', 'Farmer');
                          Navigator.pushReplacementNamed(
                            context,
                            '/farmerDetails',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: RoleButton(
                        label: 'Buyer',
                        icon: Icons.shopping_cart,
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('userRole', 'Buyer');
                          Navigator.pushReplacementNamed(
                            context,
                            '/buyerDetails',
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);
                    await prefs.remove('userRole');
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Role Button Widget
class RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const RoleButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 30),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: darkGreen,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
    );
  }
}

class FarmerDetailsScreen extends StatefulWidget {
  const FarmerDetailsScreen({super.key});

  @override
  _FarmerDetailsScreenState createState() => _FarmerDetailsScreenState();
}

class _FarmerDetailsScreenState extends State<FarmerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _state = '';
  String _city = '';
  String _area = '';
  String _farmArea = '';
  String _annualIncome = '';
  String _aadhar = '';
  String _rationCard = '';
  String _panCard = '';

  void _saveFarmerDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, String> farmerDetails = {
        'name': _name,
        'state': _state,
        'city': _city,
        'area': _area,
        'farmArea': _farmArea,
        'annualIncome': _annualIncome,
        'aadhar': _aadhar,
        'rationCard': _rationCard,
        'panCard': _panCard,
      };
      await prefs.setString('farmerDetails', jsonEncode(farmerDetails));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer details saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Details'),
        backgroundColor: primaryGreen,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightGreen, Color(0xFFC8E6C9)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRoundedInputField(
                    labelText: 'Name',
                    onSaved: (value) => _name = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your name'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'State',
                    onSaved: (value) => _state = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your state'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'City',
                    onSaved: (value) => _city = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your city'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'Area',
                    onSaved: (value) => _area = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your area'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'Farm Area (in acres)',
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _farmArea = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your farm area';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'Annual Income',
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _annualIncome = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your annual income';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'Aadhar Number',
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _aadhar = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Aadhar number';
                      }
                      if (value.length != 12) {
                        return 'Aadhar number must be 12 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'Ration Card Number',
                    onSaved: (value) => _rationCard = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your Ration card number'
                                : null,

                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'PAN Card Number',
                    onSaved: (value) => _panCard = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your PAN card number'
                                : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveFarmerDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save Details',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);
                      await prefs.remove('userRole');
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/',
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create rounded input fields
  Widget _buildRoundedInputField({
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: darkGreen),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}

class BuyerDetailsScreen extends StatefulWidget {
  const BuyerDetailsScreen({super.key});

  @override
  _BuyerDetailsScreenState createState() => _BuyerDetailsScreenState();
}

class _BuyerDetailsScreenState extends State<BuyerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  String _aadhar = '';
  String _email = '';
  String _phone = '';

  void _saveBuyerDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, String> buyerDetails = {
        'name': _name,
        'address': _address,
        'aadhar': _aadhar,
        'email': _email,
        'phone': _phone,
      };
      await prefs.setString('buyerDetails', jsonEncode(buyerDetails));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buyer details saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Details'),
        backgroundColor: primaryGreen,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightGreen, Color(0xFFC8E6C9)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRoundedInputField(
                    labelText: 'Name',
                    onSaved: (value) => _name = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your name'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'Address',
                    onSaved: (value) => _address = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your address'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'Aadhar Number',
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _aadhar = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Aadhar number';
                      }
                      if (value.length != 12) {
                        return 'Aadhar number must be 12 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => _email = value ?? '',
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildRoundedInputField(
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => _phone = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveBuyerDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save Details',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);
                      await prefs.remove('userRole');
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/',
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create rounded input fields
  Widget _buildRoundedInputField({
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: darkGreen),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
