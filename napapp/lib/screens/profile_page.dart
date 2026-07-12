import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import 'app_strings.dart';

// Profile page that allows the user to edit the nickname
// and select a profile picture
class ProfilePage extends StatefulWidget {
  // Current profile name
  final String currentName;

  // Index of the currently selected profile image
  final int currentImage;

  // Current application language
  final bool isEnglish;

  const ProfilePage({
    super.key,
    required this.currentName,
    required this.currentImage,
    this.isEnglish = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controller used to edit the profile name
  late TextEditingController nameController;

  // Index of the selected profile image
  late int selectedImage;

  // Available profile images
  final List<String> profileImages = [
    "assets/profile_imm/imm1.png",
    "assets/profile_imm/imm2.png",
    "assets/profile_imm/imm3.png",
  ];

  @override
  void initState() {
    super.initState();

    // Initializes the text field with the current profile name
    nameController = TextEditingController(text: widget.currentName);

    // Initializes the selected profile image
    selectedImage = widget.currentImage;
  }

  @override
  void dispose() {
    // Releases the text controller
    nameController.dispose();

    super.dispose();
  }

  // Saves the updated profile information
  Future<void> saveProfile() async {
    // Removes leading and trailing spaces
    var name = nameController.text.trim();

    // Limits the nickname length
    if (name.length > 15) {
      name = name.substring(0, 13);
    }

    // Prevents saving an empty nickname
    if (name.isEmpty) return;

    // Saves the nickname
    await PreferencesService.saveProfileName(name);

    // Saves the selected profile image
    await PreferencesService.saveProfileImage(selectedImage);

    if (!mounted) return;

    // Closes the page and notifies the previous screen
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    // Localized strings
    final s = AppStrings(widget.isEnglish);

    return Scaffold(
      resizeToAvoidBottomInset: true,

      // Page title
      appBar: AppBar(title: Text(s.profileTitle)),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // Ensures the content fills the available height
              constraints: BoxConstraints(minHeight: constraints.maxHeight),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // Nickname section title
                      Text(
                        s.nicknameLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Nickname input field
                      TextField(
                        controller: nameController,

                        // Maximum number of characters allowed
                        maxLength: 13,

                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: s.enterNameHint,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Profile image section title
                      Text(
                        s.chooseProfileImage,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Displays all available profile images
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                        children: List.generate(profileImages.length, (index) {
                          return GestureDetector(
                            // Updates the selected image
                            onTap: () {
                              setState(() {
                                selectedImage = index;
                              });
                            },

                            child: CircleAvatar(
                              radius: 40,

                              backgroundImage: AssetImage(profileImages[index]),

                              // Highlights the selected image
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

                      // Pushes the save button to the bottom
                      const Spacer(),

                      // Save profile button
                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: FilledButton(
                          onPressed: saveProfile,

                          child: Text(
                            s.saveButton,
                            style: const TextStyle(fontSize: 18),
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
