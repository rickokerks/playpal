import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  final String accountId;

  const HomePage({Key? key, required this.accountId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> songs = [];
  String? currentSong;
  bool isSongsTab = true;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Function to pick an MP3 file
Future<void> pickMusicFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp3'],
  );

  if (result != null && result.files.single.path != null) {
    final filePath = result.files.single.path!;
    final fileName = result.files.single.name;

    // Remove the ".mp3" extension from the song title
    final songTitle = fileName.replaceAll('.mp3', '');

    setState(() {
      songs.add({"title": songTitle, "path": filePath});
    });
  }
}

  // Function to switch tabs
  void switchTab(bool isSongsTabSelected) {
    setState(() {
      isSongsTab = isSongsTabSelected;
    });
  }

  // Play/Pause functionality
  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play(DeviceFileSource(songs[_currentIndex]["path"]!));
    }

    setState(() {
      _isPlaying = !_isPlaying;
      _isPaused = !_isPlaying;
    });
  }

  // Function to play the next song
  void _nextSong() {
    if (_currentIndex < songs.length - 1) {
      setState(() {
        _currentIndex++;
        currentSong = songs[_currentIndex]["title"];
        _audioPlayer.play(DeviceFileSource(songs[_currentIndex]["path"]!));
        _isPlaying = true;
      });
    }
  }

  // Function to play the previous song
  void _previousSong() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        currentSong = songs[_currentIndex]["title"];
        _audioPlayer.play(DeviceFileSource(songs[_currentIndex]["path"]!));
        _isPlaying = true;
      });
    }
  }

  // Function to handle sign-out confirmation dialog
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                // Stop the audio when signing out
                _audioPlayer.stop();
                // Navigate back to the login page
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to show the options dialog when a song is long-pressed
  void _showSongOptionsDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Choose an option',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _renameSong(index);
                },
                child: const Text(
                  'Rename',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _moveSong(index);
                },
                child: const Text(
                  'Move to',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteSong(index);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to rename a song
  void _renameSong(int index) {
    TextEditingController _controller = TextEditingController();
    _controller.text = songs[index]["title"]!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Rename Song',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter new name',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  songs[index]["title"] = _controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to move a song (basic placeholder)
  void _moveSong(int index) {
    // Add functionality to move the song to another playlist if desired
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Move to another playlist',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                // Implement the functionality to move the song
                Navigator.pop(context);
              },
              child: const Text(
                'Move',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a song
  void _deleteSong(int index) {
    setState(() {
      songs.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    // Listen to the audio player position and duration changes
    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _currentPosition = p;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _totalDuration = d;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    onPressed: _showSignOutDialog,
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: pickMusicFile,
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
              Expanded(
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                          currentSong = song["title"];
                          _audioPlayer.play(DeviceFileSource(song["path"]!));
                          _isPlaying = true;
                        });
                      },
                      onLongPress: () => _showSongOptionsDialog(index),
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
              if (currentSong != null)
                Container(
                  color: Colors.grey[900],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous,
                                color: Colors.white),
                            onPressed: _previousSong,
                          ),
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next,
                                color: Colors.white),
                            onPressed: _nextSong,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              activeColor: Colors.white,
                              inactiveColor: Colors.grey[600],
                              value: _currentPosition.inSeconds.toDouble(),
                              min: 0.0,
                              max: _totalDuration.inSeconds.toDouble(),
                              onChanged: (double value) {
                                setState(() {
                                  _audioPlayer
                                      .seek(Duration(seconds: value.toInt()));
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Text(
                        currentSong!,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
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
