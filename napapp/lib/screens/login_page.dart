import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  static const routename = 'LoginPage';

  final _nameController = TextEditingController();
  final _pswController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usiamo un Center e SingleChildScrollView per evitare errori di pixel se la tastiera copre i campi
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Un tocco di stile: Icona app
              Icon(
                Icons.calendar_today_rounded,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                "Nap App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 50),

              // Text box - Name
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Text box - Password
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _pswController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Login Button
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
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
                      // Navigazione tramite route nominata
                      Navigator.pushReplacementNamed(
                        context,
                        '/homepage',
                        arguments: _nameController.text,
                      );
                    } else {
                      // Mostra un errore se i dati sono sbagliati
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Errore Accesso"),
                          content: const Text("Username o password errati."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
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
