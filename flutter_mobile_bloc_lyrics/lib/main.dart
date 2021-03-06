import 'package:common_bloc_lyrics/common_bloc_lyrics.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_bloc_lyrics/feature/song/search/ui/search_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  final LyricsRepository _lyricsRepository =
      LyricsRepository(LyricsClient(), LocalClient());

  runApp(
      EasyLocalization(child: LyricsApp(lyricsRepository: _lyricsRepository)));
}

class LyricsApp extends StatelessWidget {
  final LyricsRepository lyricsRepository;

  const LyricsApp({Key key, @required this.lyricsRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;

    return EasyLocalizationProvider(
      data: data,
      child: MultiBlocProvider(
          providers: [
            BlocProvider<SongAddEditBloc>(
              builder: (context) =>
                  SongAddEditBloc(lyricsRepository: lyricsRepository),
            ),
            BlocProvider<SongsSearchBloc>(
              builder: (context) => SongsSearchBloc(
                  lyricsRepository: lyricsRepository,
                  songAddEditBloc: BlocProvider.of<SongAddEditBloc>(context)),
            ),
          ],
          child: MaterialApp(
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                EasylocaLizationDelegate(
                    locale: data.locale, path: 'lib/resources/langs'),
              ],
              supportedLocales: [
                Locale('en', 'US')
              ],
              locale: data.savedLocale,
              theme: ThemeData(primaryColor: Colors.blue),
              home: SearchScreen())),
    );
  }
}
