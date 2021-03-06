import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common_bloc_lyrics/common_bloc_lyrics.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class SongsSearchBloc extends Bloc<SongSearchEvent, SongsSearchState> {
  final LyricsRepository lyricsRepository;
  final SongAddEditBloc songAddEditBloc;

  StreamSubscription addEditBlocSubscription;

  SongsSearchBloc(
      {@required this.lyricsRepository, @required this.songAddEditBloc}) {
    addEditBlocSubscription = songAddEditBloc.listen((songAddEditState) {
      if (state is SearchStateSuccess) {
        if (songAddEditState is EditSongStateSuccess) {
          add(SongUpdated(song: songAddEditState.song));
        } else if (songAddEditState is AddSongStateSuccess) {
          add(SongAdded(song: songAddEditState.song));
        }
      }
    });
  }

  @override
  SongsSearchState get initialState => SearchStateEmpty();

  @override
  Stream<SongsSearchState> transformEvents(Stream<SongSearchEvent> events,
      Stream<SongsSearchState> Function(SongSearchEvent event) next) {
    return super.transformEvents(
      (events as Observable<SongSearchEvent>).debounceTime(
        Duration(milliseconds: DEFAULT_SEARCH_DEBOUNCE),
      ),
      next,
    );
  }

  @override
  Stream<SongsSearchState> mapEventToState(SongSearchEvent event) async* {
    if (event is TextChanged) {
      yield* _mapSongSearchTextChangedToState(event);
    }
    if (event is RemoveSong) {
      yield* _mapSongRemoveToState(event);
    }
    if (event is SongUpdated) {
      yield* _mapSongUpdateToState(event);
    }
    if (event is SongAdded) {
      yield* _mapSongAddedToState(event);
    }
  }

  Stream<SongsSearchState> _mapSongSearchTextChangedToState(
      TextChanged event) async* {
    final String searchQuery = event.query;
    if (searchQuery.isEmpty) {
      yield SearchStateEmpty();
    } else {
      yield SearchStateLoading();
      try {
        final result = await lyricsRepository.searchSongs(searchQuery);
        yield SearchStateSuccess(result, searchQuery);
      } catch (error) {
        print(error.toString());
        yield error is SearchResultError
            ? SearchStateError(error.message)
            : SearchStateError(error.toString());
      }
    }
  }

  Stream<SongsSearchState> _mapSongRemoveToState(RemoveSong event) async* {
    await lyricsRepository.removeSong(event.songID);
    if (state is SearchStateSuccess) {
      SearchStateSuccess searchState = state;
      searchState.songs.removeWhere((song) {
        return song.id == event.songID;
      });
      yield SearchStateSuccess(searchState.songs, searchState.query);
    }
  }

  Stream<SongsSearchState> _mapSongUpdateToState(SongUpdated event) async* {
    if (state is SearchStateSuccess) {
      SearchStateSuccess successState = state;
      List<SongBase> updatedList = successState.songs;
      if (event.song.isInQuery(successState.query)) {
        updatedList = updatedList.map((song) {
          return song.id == event.song.id ? event.song : song;
        }).toList();
      } else {
        updatedList.removeWhere((song) => song.id == event.song.id);
      }
      yield SearchStateSuccess(updatedList, successState.query);
    }
  }

  Stream<SongsSearchState> _mapSongAddedToState(SongAdded event) async* {
    if (state is SearchStateSuccess) {
      SearchStateSuccess successState = state;
      List<SongBase> updatedList = List.from(successState.songs);

      if (event.song.isInQuery(successState.query)) {
        updatedList.insert(0, event.song);
        yield SearchStateSuccess(updatedList, successState.query);
      }
    }
  }

  @override
  void onTransition(Transition<SongSearchEvent, SongsSearchState> transition) {
    print(transition);
  }

  @override
  Future<void> close() {
    addEditBlocSubscription.cancel();
    return super.close();
  }
}
