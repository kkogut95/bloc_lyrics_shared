import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_bloc_lyrics/common_bloc_lyrics.dart';
import 'package:flutter_mobile_bloc_lyrics/resources/langs/strings.dart';

class SearchBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _songSearchController = TextEditingController();
  SongsSearchBloc _songSearchBloc;

  @override
  void initState() {
    super.initState();
    _songSearchBloc = BlocProvider.of<SongsSearchBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
    data: data,
     child:TextField(
      controller: _songSearchController,
      onChanged: (text) {
        _songSearchBloc.add(TextChanged(query: text));
      },
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: AppLocalizations.of(context).tr(S.SEARCH_LYRICS)),
    ));
  }

  @override
  void dispose() {
    _songSearchController.dispose();
    super.dispose();
  }
}
