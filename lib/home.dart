import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  final String accountId; // Pass the account ID to store user-specific data

  const HomePage({Key? key, required this.accountId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> songs = []; // To store songs added by the user
  String? currentSong; // To store the currently playing song
  bool isSongsTab = true; // Default tab selection

  // Function to pick an MP3 file
  Future<void> pickMusicFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'], // Restrict to MP3 files
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;

      setState(() {
        songs.add({"title": fileName, "path": filePath});
      });

      // Store the song in the user-specific account (this would typically be connected to a database or backend)
      // Example: saveSongToAccount(widget.accountId, filePath);
    }
  }

  // Function to switch tabs
  void switchTab(bool isSongsTabSelected) {
    setState(() {
      isSongsTab = isSongsTabSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Your Library + Sign Out Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Library",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to login page
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      "Sign Out",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tabs: Playlists and Songs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => switchTab(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSongsTab
                              ? const Color(0xFF48494A)
                              : const Color(0xFF0047AB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Playlists",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => switchTab(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSongsTab
                              ? const Color(0xFF0047AB)
                              : const Color(0xFF48494A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Songs",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add Local Music Button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: pickMusicFile, // Trigger file picker
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Add a local music file",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Song List
              Expanded(
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentSong = song["title"];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.music_note, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                song["title"]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom Now Playing Bar
              if (currentSong != null)
                Container(
                  color: Colors.grey[900],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.music_note, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentSong!,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.shuffle, color: Colors.white),
                        onPressed: () {
                          // Shuffle functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        onPressed: () {
                          // Play functionality
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
