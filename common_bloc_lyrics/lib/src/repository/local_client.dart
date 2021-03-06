import 'package:common_bloc_lyrics/common_bloc_lyrics.dart';

//Mocked repository which works as remote client
class LocalClient {
  final List<SongBase> localSongsList = List();

  Future<SongBase> addSong(SongBase song) async {
    await Future.delayed(Duration(milliseconds: 100));
    SongBase addedSong = song.copyWith(id: localSongsList.length);
    localSongsList.add(addedSong);
    return addedSong;
  }

  Future<SongBase> editSong(SongBase song) async {
    Future.delayed(Duration(milliseconds: 1000));
    localSongsList[song.id] = song;
    return song;
  }

  Future<List<SongBase>> getSongs(String query) async {
    await Future.delayed(Duration(milliseconds: 1000));
    return localSongsList
        .where((song) => song.title.toLowerCase().contains(query))
        .toList();
  }

  Future<void> removeSong(int localID) async {
    await Future.delayed(Duration(milliseconds: 1000));
    localSongsList.removeAt(localID);
  }
}
