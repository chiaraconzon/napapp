import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ProfilePage extends StatefulWidget {
  final String currentName;
  final int currentImage;

  const ProfilePage({
    super.key,
    required this.currentName,
    required this.currentImage,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;

  late int selectedImage;

  final List<String> profileImages = [
    "assets/profile_imm/imm1.png",
    "assets/profile_imm/imm2.png",
    "assets/profile_imm/imm3.png",
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.currentName);

    selectedImage = widget.currentImage;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    var name = nameController.text.trim();
    if (name.length > 15) {
      name = name.substring(0, 13);
    }

    if (name.isEmpty) return;

    await PreferencesService.saveProfileName(name);

    await PreferencesService.saveProfileImage(selectedImage);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(title: const Text("Profilo")),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Nome utente",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: nameController,

                        maxLength: 13,

                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Inserisci nome",
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Scegli immagine profilo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                        children: List.generate(profileImages.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImage = index;
                              });
                            },

                            child: CircleAvatar(
                              radius: 40,

                              backgroundImage: AssetImage(profileImages[index]),

                              child: selectedImage == index
                                  ? Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 4,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: FilledButton(
                          onPressed: saveProfile,

                          child: const Text(
                            "Salva",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
