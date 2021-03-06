import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_bloc_lyrics/feature/song/details/web_song_details.dart';
import 'package:common_bloc_lyrics/common_bloc_lyrics.dart';

import 'local_song_details.dart';

class SongDetailsScreen extends StatelessWidget {
  final SongBase song;

  SongDetailsScreen(this.song);

  @override
  Widget build(BuildContext context) {
    return song.lyricsURL == null
        ? LocalSongDetails(song: song)
        : WebSongDetails(songDetailsURL: song.lyricsURL);
  }
}
