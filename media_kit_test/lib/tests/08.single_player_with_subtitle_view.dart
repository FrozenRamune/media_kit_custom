import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../common/globals.dart';
import '../common/sources.dart';
import '../common/widgets.dart';

class SinglePlayerWithSubtitleViewScreen extends StatefulWidget {
  const SinglePlayerWithSubtitleViewScreen({Key? key}) : super(key: key);

  @override
  State<SinglePlayerWithSubtitleViewScreen> createState() => _SinglePlayerWithSubtitleViewScreenState();
}

class _SinglePlayerWithSubtitleViewScreenState extends State<SinglePlayerWithSubtitleViewScreen> {
  final Player player = Player();
  VideoController? controller;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      controller = await VideoController.create(
        player,
        enableHardwareAcceleration: enableHardwareAcceleration.value,
      );
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

  List<Widget> get items => [
        for (int i = 0; i < sources.length; i++)
          ListTile(
            title: Text(
              'Video $i',
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              player.open(Media(sources[i]));
            },
          ),
      ];

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('package:media_kit'),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'file',
            tooltip: 'Open [File]',
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.any,
              );
              if (result?.files.isNotEmpty ?? false) {
                await player.open(Media(result!.files.first.path!));
              }
            },
            child: const Icon(Icons.file_open),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            heroTag: 'uri',
            tooltip: 'Open [Uri]',
            onPressed: () => showURIPicker(context, player),
            child: const Icon(Icons.link),
          ),
        ],
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 8.0,
                              clipBehavior: Clip.antiAlias,
                              margin: const EdgeInsets.all(32.0),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Video(
                                    controller: controller,
                                  ),
                                  DefaultTextStyle(
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.yellow,
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: SubtitlesView(player: player)
                                    )
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: PopupMenuButton<SubtitleTrack>(
                                        icon: const Icon(Icons.subtitles, color: Colors.white),
                                        itemBuilder: _subtitleItemBuilder,
                                        onSelected: (final track) async {
                                          await player.setSubtitleTrack(track);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SeekBar(player: player),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1.0, thickness: 1.0),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: items,
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  Video(
                    controller: controller,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                  ),
                  const SizedBox(height: 16.0),
                  SeekBar(player: player),
                  const SizedBox(height: 32.0),
                  const Divider(height: 1.0, thickness: 1.0),
                  ...items,
                ],
              ),
      ),
    );
  }

  List<PopupMenuItem<SubtitleTrack>> _subtitleItemBuilder(final BuildContext context) {
    final currentTrack = player.state.track.subtitle;
    return player.state
        .tracks
        .subtitle
        .map((e) {
          return PopupMenuItem(
            value: e,
            child: RichText(
              text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.check, color: e.id == currentTrack.id ? null : Colors.transparent),
                      ),
                    ),
                    TextSpan(
                      text: e.title == null || e.title?.isEmpty == true ? "Track ${e.id}${e.language == null ? "" : " (${e.language})"}" : e.title!,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ]
              ),
            ),
          );
        })
        .toList(growable: false);
  }
}
