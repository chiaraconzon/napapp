import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  static const routename = 'LoginPage';

  final _nameController = TextEditingController();
  final _pswController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/sleep_icon.png', // Assicurati di usare il percorso corretto del tuo file
                height: 100, // Puoi regolare l'altezza come preferisci
                fit: BoxFit.contain,
              ), //modificare con il logo


              const SizedBox(height: 20),

              Text(
                "Nap App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Don't give up, take a nap!",
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 50),

              // USERNAME
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

              // PASSWORD
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

              // LOGIN BUTTON
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
                    if (_nameController.text == "admin" &&
                        _pswController.text == "123") {
                      Navigator.pushReplacementNamed(
                        context,
                        '/homepage',
                        arguments: _nameController.text,
                      );
                    } else {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: theme.colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Username o password errati.",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
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
