import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:marquee/marquee.dart';

class HomePage extends StatefulWidget {
  
  final String accountId;

  const HomePage({Key? key, required this.accountId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> songs = [];
  List<Map<String, dynamic>> playlists = [];
  Map<String, dynamic>? currentPlaylist;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'date';
  String? currentSong;
  bool isSongsTab = true;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  List<bool> expandedStates = [];

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
  void _showSortOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Sort By',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _sortBy = 'date';
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Date Added',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        _sortBy == 'date' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sortBy = 'name';
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        _sortBy == 'name' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
   // Songs Tab Widget
 Widget _buildSongsTab() {
    // Filter songs based on search query
    List<Map<String, String>> filteredSongs = songs.where((song) {
      return song["title"]!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort songs based on selected option
    if (_sortBy == 'name') {
      filteredSongs.sort((a, b) => a["title"]!.compareTo(b["title"]!));
    }
    // For date sorting we keep the original order since songs are added chronologically

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.sort, color: Colors.white),
              onPressed: _showSortOptionsDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Search bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search songs...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredSongs.length,
            itemBuilder: (context, index) {
              final song = filteredSongs[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex =
                        songs.indexOf(song); // Get the original index
                    currentSong = song["title"];
                    _audioPlayer.play(DeviceFileSource(song["path"]!));
                    _isPlaying = true;
                  });
                },
                onLongPress: () => _showSongOptionsDialog(
                    songs.indexOf(song)), // Use original index
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
      ],
    );
  }

  // Playlists Tab Widget
  Widget _buildPlaylistsTab() {
    if (currentPlaylist == null) {
      // Show the list of playlists
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.white),
                onPressed: _createPlaylist,
              ),
              const SizedBox(width: 8),
              const Text(
                "Create a playlist",
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
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  leading: Icon(Icons.folder, color: Colors.grey[400]),
                  title: Text(
                    playlist["name"]!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "${playlist["songs"].length} songs",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      currentPlaylist = playlist;
                    });
                  },
                  onLongPress: () => _showPlaylistOptionsDialog(index),
                );
              },
            ),
          ),
        ],
      );
  } else {
    // Show the songs in the selected playlist
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  currentPlaylist = null; // Return to playlist list
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              currentPlaylist!["name"]!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: currentPlaylist!["songs"].isEmpty
              ? const Center(
                  child: Text(
                    "No songs in this playlist",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: currentPlaylist!["songs"].length,
                  itemBuilder: (context, index) {
                    final song = currentPlaylist!["songs"][index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentSong = song["title"];
                          _audioPlayer.play(DeviceFileSource(song["path"]!));
                          _isPlaying = true;
                        });
                      },
                      
                          onLongPress: () => _showSongOptionsDialog(index, isPlaylistContext: true),
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
      ],
    );
  }
}



  // Updated create playlist function
  void _createPlaylist() {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Enter Playlist Name',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            
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
                  playlists.add({"name": _controller.text, "songs": []});
                  expandedStates =
                      List<bool>.filled(playlists.length, false); // Resync
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Create',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add playlist options dialog
  void _showPlaylistOptionsDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Playlist Options',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _renamePlaylist(index);
                },
                child: const Text(
                  'Rename',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deletePlaylist(index);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Add rename playlist function
  void _renamePlaylist(int index) {
    TextEditingController _controller = TextEditingController();
    _controller.text = playlists[index]["name"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Rename Playlist',
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
                  playlists[index]["name"] = _controller.text;
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

  // Add delete playlist function
  void _deletePlaylist(int index) {
    setState(() {
      playlists.removeAt(index);
      expandedStates = List<bool>.filled(playlists.length, false); // Resync
    });
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
// Delete a song from the current playlist
  void _deleteSongFromPlaylist(int index) {
    setState(() {
      currentPlaylist!["songs"].removeAt(index);
    });
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
 void _showSongOptionsDialog(int index, {bool isPlaylistContext = false}) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  isPlaylistContext
                      ? _renameSongInPlaylist(index)
                      : _renameSong(index);
                },
                child: const Text(
                  'Rename',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (!isPlaylistContext) // Only show Add to Playlist for main songs tab
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _addToPlaylist(index);
                  },
                  child: const Text(
                    'Add to Playlist',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  isPlaylistContext
                      ? _deleteSongFromPlaylist(index)
                      : _deleteSong(index);
                },
                child: isPlaylistContext
                    ? const Text(
                        'Remove from Playlist',
                        style: TextStyle(color: Colors.white),
                      )
                    : const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

// Specific to playlist context: Rename a song
  void _renameSongInPlaylist(int index) {
    TextEditingController _controller = TextEditingController();
    _controller.text = currentPlaylist!["songs"][index]["title"]!;

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
                  currentPlaylist!["songs"][index]["title"] = _controller.text;
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

// Function to add a song to a playlist
  void _addToPlaylist(int songIndex) {
    String? selectedPlaylist;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[800],
              title: const Text(
                'Add to Playlist',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Where do you want to add this song?',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedPlaylist,
                    dropdownColor: Colors.grey[900],
                    hint: const Text(
                      'Select a playlist',
                      style: TextStyle(color: Colors.white),
                    ),
                    items: playlists.map((playlist) {
                      return DropdownMenuItem<String>(
                        value: playlist["name"],
                        child: Text(
                          playlist["name"]!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedPlaylist = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
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
                    if (selectedPlaylist != null) {
                      setState(() {
                        final playlist = playlists
                            .firstWhere((p) => p["name"] == selectedPlaylist);
                        playlist["songs"].add(songs[songIndex]);
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
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
    expandedStates = List<bool>.filled(playlists.length, false);


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
    _searchController.dispose();
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
              Expanded(
                child: isSongsTab ? _buildSongsTab() : _buildPlaylistsTab(),
              ),
              const SizedBox(height: 16),
              
              if (currentSong != null)
                Container(
                  color: Colors.grey[900],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Close button above the slider, aligned to the right and smaller size
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            iconSize: 20, // Smaller size for the close button
                            onPressed: () {
                              setState(() {
                                _audioPlayer.stop(); // Stop the audio
                                currentSong = null; // Clear the current song
                                _isPlaying = false; // Reset play/pause state
                              });
                            },
                          ),
                        ],
                      ),

                      // Slider for audio position
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

                      // Song name and control buttons in 1 row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Song name on the left
                          Text(
                            currentSong!,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Control buttons on the right
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
                        ],
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
