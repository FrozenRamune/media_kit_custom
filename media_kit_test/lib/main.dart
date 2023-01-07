import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_core_video/media_kit_core_video.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('package:media_kit'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              top: 16.0,
              bottom: 16.0,
            ),
            child: Text('Situations:'),
          ),
          const Divider(height: 1.0, thickness: 1.0),
          ListTile(
            title: const Text(
              'Single [Player] with single [Video]',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SimpleScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Single [Player] with Video [Path] and optional Audio [Path]',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SimpleStream(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Single [Player] with multiple [Video]s',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const SinglePlayerMultipleVideosScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Multiple [Player]s with multiple [Video]s',
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const MultiplePlayersMultipleVideosScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Single [Player] with single [Video].

class SimpleScreen extends StatefulWidget {
  const SimpleScreen({Key? key}) : super(key: key);

  @override
  State<SimpleScreen> createState() => _SimpleScreenState();
}

class _SimpleScreenState extends State<SimpleScreen> {
  // Create a [Player] instance from `package:media_kit`.
  final Player player = Player();
  // Reference to the [VideoController] instance.
  VideoController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Create a [VideoController] instance from `package:media_kit_core_video`.
      // Pass the [handle] of the [Player] from `package:media_kit` to the [VideoController] constructor.
      controller = await VideoController.create(player.handle);
      setState(() {});
    });
  }

  @override
  void dispose() {
    Future.microtask(() async {
      debugPrint('Disposing [Player] and [VideoController]...');
      await controller?.dispose();
      await player.dispose();
    });
    super.dispose();
  }

  List<Widget> get assets => [
        const Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            bottom: 16.0,
          ),
          child: Text('Asset Videos:'),
        ),
        const Divider(height: 1.0, thickness: 1.0),
        for (int i = 0; i < 5; i++)
          ListTile(
            title: Text(
              'video_$i.mp4',
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              player.open(
                Playlist(
                  [
                    Media(
                      'asset://assets/video_$i.mp4',
                    ),
                  ],
                ),
              );
            },
          ),
      ];

  Widget get video => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Card(
              elevation: 8.0,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.all(32.0),
              child: Video(
                controller: controller,
              ),
            ),
          ),
          SeekBar(player: player),
          const SizedBox(height: 32.0),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('package:media_kit'),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Open [File]',
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.any,
            );
            if (result?.files.isNotEmpty ?? false) {
              player.open(
                Playlist(
                  [
                    Media(result!.files.first.path!),
                  ],
                ),
              );
            }
          },
          child: const Icon(Icons.file_open),
        ),
        body: SizedBox.expand(
          child: horizontal
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        child: video,
                      ),
                    ),
                    const VerticalDivider(width: 1.0, thickness: 1.0),
                    Expanded(
                      flex: 1,
                      child: ListView(
                        children: [...assets],
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 12.0 / 16.0,
                      child: video,
                    ),
                    const Divider(height: 1.0, thickness: 1.0),
                    ...assets,
                  ],
                ),
        ));
  }
}

// Single [Player] with Video [Path] and optional Audio [Path]

class SimpleStream extends StatefulWidget {
  const SimpleStream({Key? key}) : super(key: key);

  @override
  State<SimpleStream> createState() => _SimpleStreamState();
}

class _SimpleStreamState extends State<SimpleStream> {
  // Create a [Player] instance from `package:media_kit`.
  final Player player = Player();
  // Reference to the [VideoController] instance.
  VideoController? controller;
  final _formKey = GlobalKey<FormState>();
  TextEditingController streamurl = TextEditingController();
  TextEditingController audiourl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Create a [VideoController] instance from `package:media_kit_core_video`.
      // Pass the [handle] of the [Player] from `package:media_kit` to the [VideoController] constructor.
      controller = await VideoController.create(player.handle);
      setState(() {});
    });
  }

  @override
  void dispose() {
    Future.microtask(() async {
      debugPrint('Disposing [Player] and [VideoController]...');
      await controller?.dispose();
      await player.dispose();
    });
    super.dispose();
  }

  Widget get video => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Card(
              elevation: 8.0,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.all(32.0),
              child: Video(
                controller: controller,
              ),
            ),
          ),
          SeekBar(player: player),
          const SizedBox(height: 32.0),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('package:media_kit'),
        ),
        body: SizedBox.expand(
          child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        child: video,
                      ),
                    ),
                    const VerticalDivider(width: 1.0, thickness: 1.0),
                    Expanded(
                      flex: 1,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: streamurl,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                // Local files do not need a proper identifier
                                // for example both file://C:\video.mkv 
                                // and C:\video.mkv get recognized
                                labelText: 'Video file path or URI',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a URI';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              // Optional field for a seperate audiotrack
                              controller: audiourl,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Optional audio path or URI',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {

                                    //set mpv options directly
                                    if (audiourl.text != null) {
                                      if (player?.platform is libmpvPlayer) {
                                        (player?.platform as libmpvPlayer?)?.setProperty("audio-files", audiourl.text);
                                      }
                                    }
                                    player.open(Playlist([Media(streamurl.text)]));
                                  }
                                },
                                child: const Text('Load Video'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),  
                  ],
          )
        )
      );
  }
}

// Single [Player] with multiple [Video]s

class SinglePlayerMultipleVideosScreen extends StatefulWidget {
  const SinglePlayerMultipleVideosScreen({Key? key}) : super(key: key);

  @override
  State<SinglePlayerMultipleVideosScreen> createState() =>
      _SinglePlayerMultipleVideosScreenState();
}

class _SinglePlayerMultipleVideosScreenState
    extends State<SinglePlayerMultipleVideosScreen> {
  // Create a [Player] instance from `package:media_kit`.
  final Player player = Player();
  // Reference to the [VideoController] instance.
  VideoController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Create a [VideoController] instance from `package:media_kit_core_video`.
      // Pass the [handle] of the [Player] from `package:media_kit` to the [VideoController] constructor.
      controller = await VideoController.create(player.handle);
      setState(() {});
    });
  }

  @override
  void dispose() {
    Future.microtask(() async {
      debugPrint('Disposing [Player] and [VideoController]...');
      await controller?.dispose();
      await player.dispose();
    });
    super.dispose();
  }

  List<Widget> get assets => [
        const Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            bottom: 16.0,
          ),
          child: Text('Asset Videos:'),
        ),
        const Divider(height: 1.0, thickness: 1.0),
        for (int i = 0; i < 5; i++)
          ListTile(
            title: Text(
              'video_$i.mp4',
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              player.open(
                Playlist(
                  [
                    Media(
                      'asset://assets/video_$i.mp4',
                    ),
                  ],
                ),
              );
            },
          ),
      ];

  Widget get video => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Card(
                    elevation: 8.0,
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.fromLTRB(32.0, 32.0, 16.0, 8.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Video(
                        controller: controller,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 8.0,
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.fromLTRB(16.0, 32.0, 32.0, 8.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Video(
                        controller: controller,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Card(
                    elevation: 8.0,
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.fromLTRB(32.0, 8.0, 16.0, 32.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Video(
                        controller: controller,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 8.0,
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.fromLTRB(16.0, 8.0, 32.0, 32.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Video(
                        controller: controller,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SeekBar(player: player),
          const SizedBox(height: 32.0),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('package:media_kit'),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Open [File]',
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.any,
            );
            if (result?.files.isNotEmpty ?? false) {
              player.open(
                Playlist(
                  [
                    Media(result!.files.first.path!),
                  ],
                ),
              );
            }
          },
          child: const Icon(Icons.file_open),
        ),
        body: SizedBox.expand(
          child: horizontal
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        child: video,
                      ),
                    ),
                    const VerticalDivider(width: 1.0, thickness: 1.0),
                    Expanded(
                      flex: 1,
                      child: ListView(
                        children: [...assets],
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 12.0 / 16.0,
                      child: video,
                    ),
                    const Divider(height: 1.0, thickness: 1.0),
                    ...assets,
                  ],
                ),
        ));
  }
}

// Multiple [Player]s with multiple [Video]s

class MultiplePlayersMultipleVideosScreen extends StatefulWidget {
  const MultiplePlayersMultipleVideosScreen({Key? key}) : super(key: key);

  @override
  State<MultiplePlayersMultipleVideosScreen> createState() =>
      _MultiplePlayersMultipleVideosScreenState();
}

class _MultiplePlayersMultipleVideosScreenState
    extends State<MultiplePlayersMultipleVideosScreen> {
  // Create a [Player] instance from `package:media_kit`.
  final List<Player> players = [Player(), Player()];
  // Reference to the [VideoController] instance.
  List<VideoController?> controllers = [null, null];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Create a [VideoController] instance from `package:media_kit_core_video`.
      // Pass the [handle] of the [Player] from `package:media_kit` to the [VideoController] constructor.
      for (int i = 0; i < players.length; i++) {
        controllers[i] = await VideoController.create(players[i].handle);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    Future.microtask(() async {
      debugPrint('Disposing [Player]s and [VideoController]s...');
      for (int i = 0; i < players.length; i++) {
        await players[i].dispose();
        await controllers[i]?.dispose();
      }
    });
    super.dispose();
  }

  List<Widget> getAssetsListForIndex(int i) => [
        const Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            bottom: 16.0,
          ),
          child: Text('Asset Videos:'),
        ),
        const Divider(height: 1.0, thickness: 1.0),
        for (int j = 0; j < 5; j++)
          ListTile(
            title: Text(
              'video_$j.mp4',
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              players[i].open(
                Playlist(
                  [
                    Media(
                      'asset://assets/video_$j.mp4',
                    ),
                  ],
                ),
              );
            },
          ),
      ];

  Widget getVideoForIndex(int i) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Card(
              elevation: 8.0,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.all(32.0),
              child: Video(
                controller: controllers[i],
              ),
            ),
          ),
          SeekBar(player: players[i]),
          const SizedBox(height: 32.0),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.of(context).size.width / 2 >
        MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('package:media_kit'),
      ),
      body: Row(
        children: [
          for (int i = 0; i < 2; i++)
            Expanded(
              child: horizontal
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.center,
                            child: getVideoForIndex(i),
                          ),
                        ),
                        const VerticalDivider(width: 1.0, thickness: 1.0),
                        Expanded(
                          flex: 1,
                          child: ListView(
                            children: [...getAssetsListForIndex(i)],
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.width /
                              2 *
                              12.0 /
                              16.0,
                          child: getVideoForIndex(i),
                        ),
                        const Divider(height: 1.0, thickness: 1.0),
                        ...getAssetsListForIndex(i),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

class SeekBar extends StatefulWidget {
  final Player player;
  const SeekBar({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    isPlaying = widget.player.state.isPlaying;
    position = widget.player.state.position;
    duration = widget.player.state.duration;
    subscriptions.addAll(
      [
        widget.player.streams.isPlaying.listen((event) {
          setState(() {
            isPlaying = event;
          });
        }),
        widget.player.streams.position.listen((event) {
          setState(() {
            position = event;
          });
        }),
        widget.player.streams.duration.listen((event) {
          setState(() {
            duration = event;
          });
        }),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final s in subscriptions) {
      s.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 48.0),
        IconButton(
          onPressed: widget.player.playOrPause,
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          color: Theme.of(context).primaryColor,
          iconSize: 36.0,
        ),
        const SizedBox(width: 24.0),
        Text(position.toString().substring(2, 7)),
        Expanded(
          child: Slider(
            min: 0.0,
            max: duration.inMilliseconds.toDouble(),
            value: position.inMilliseconds.toDouble().clamp(
                  0,
                  duration.inMilliseconds.toDouble(),
                ),
            onChanged: (e) {
              setState(() {
                position = Duration(milliseconds: e ~/ 1);
              });
            },
            onChangeEnd: (e) {
              widget.player.seek(Duration(milliseconds: e ~/ 1));
            },
          ),
        ),
        Text(duration.toString().substring(2, 7)),
        const SizedBox(width: 48.0),
      ],
    );
  }
}
