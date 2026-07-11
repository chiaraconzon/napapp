import 'package:flutter/material.dart';

// Login page that handles user authentication
class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  static const routename = 'LoginPage';

  // Controllers used to read user input
  final _nameController = TextEditingController();
  final _pswController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //acess current app theme color
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Image.asset(
                'assets/sleep_icon.png', 
                height: 100, 
                fit: BoxFit.contain,
              ), 


              const SizedBox(height: 20),

              // App title
              Text(
                "Nap App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 10),

              // App slogan
              Text(
                "Don't give up, take a nap!",
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 50),

              // Username input field
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Password input field
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _pswController,
                  obscureText: true,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Login button and authentication logic
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    // Check user credentials
                    if (_nameController.text == "admin" &&
                        _pswController.text == "123") {
                      // Navigate to homepage after successful login
                      Navigator.pushReplacementNamed(
                        context,
                        '/homepage',
                        arguments: _nameController.text,
                      );
                    } else {
                      // Show error message for invalid credentials
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: theme.colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        // Error message bottom sheet
                        builder: (context) => SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: Row(
                              children: [
                                // Error text
                                Expanded(
                                  child: Text(
                                    "Username o password errati.",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                                // Close error message
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "OK",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
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
