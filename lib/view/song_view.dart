// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter/material.dart';
import 'package:song_desk/loader/song.dart';
import 'package:song_desk/player/song_notifier.dart';
import 'package:song_desk/view/screen_adjust.dart';

const _phraseSize = 8.0;
const _chordSize = _phraseSize + 2.0;

/// Displays chords and some words of the current song.
class SongView extends StatelessWidget {
  static const int pageCount = 2; // TODO iff device witch > 400

  const SongView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isPortrait(context)
        ? _buildSinglePage(context)
        : _buildPage(context, 2);
  }

  Widget _buildSinglePage(BuildContext context) {
    final PageController controller = PageController();
    return PageView(
      controller: controller,
      children: <Widget>[
        _buildPage(context, 0),
        _buildPage(context, 1),
      ],
    );
  }

  Widget _buildPage(BuildContext context, int page) {
    final songNotifier = getSongNotifier(context, listen: true);

    if (!songNotifier.isReady) {
      return Container();
    }
    final Song song = songNotifier.currentSong;
    bool portrait = isPortrait(context);

    return Row(children: [
      for (int pageIndex = portrait ? page : 0;
          pageIndex < (portrait ? page + 1 : 2);
          ++pageIndex)
        Expanded(
          child: Column(children: [
            for (int staveIndex = 0;
                staveIndex < _getStaveCount(song);
                ++staveIndex)
              _buildStave(song, staveIndex, pageIndex, getScreenSize(context),
                  portrait),
          ]),
        ),
    ]);
  }

  Widget _buildStave(Song song, int staveIndex, int pageIndex, Size screenSize,
      bool portrait) {
    staveIndex += pageIndex * _getStaveCount(song);

    return SizedBox(
      height: screenSize.height / _getStaveCount(song),
      child:
          //TODO REMOVE listview
          ListView.builder(
        itemCount: 8,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        //TODO REMOVE builder
        itemBuilder: (context, columnIndex) => _buildBar(
            song, staveIndex, columnIndex, screenSize.width, portrait),
      ),
    );
  }

  Widget _buildBar(Song song, int staveIndex, int columnIndex,
      double screenWidth, bool portrait) {
    final int barIndex = staveIndex * 8 + columnIndex;

    double width = screenWidth / (8 * pageCount);

    if (portrait) {
      width *= 2;
    }

    return SizedBox(
      width: width,
      child: Column(
        children: _buildTexts(song, barIndex),
      ),
    );
  }

  List<Widget> _buildTexts(Song song, int barIndex) {
    List<Widget> list = <Widget>[];
    list.add(
      Align(
        alignment: Alignment.topLeft,
        child: Text(
          _getChord(song, barIndex),
          // textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: _chordSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    for (int i = 0; i < 4; ++i) {
      String? phrase = _getPhrase(song, barIndex, i);

      if (phrase != null) {
        list.add(_buildPhrase(song, phrase));
      }
    }
    return list;
  }

  Align _buildPhrase(Song song, String phrase) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.only(right: 13.0),
        child: Text(
          phrase,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: _phraseSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Bar? _getBar(Song song, int barIndex) {
    final bars = song.bars;

    if (barIndex >= bars.length) {
      return null;
    }
    return bars[barIndex];
  }

  String _getChord(Song song, int barIndex) {
    final Bar? bar = _getBar(song, barIndex);
    return bar?.chord ?? "";
  }

  int _getStaveCount(Song song) {
    // int count = (song?.bars.length ?? 0) ~/ 8;
    // return count ~/ pageCount; // TODO maths from Mel
    double count = song.bars.length / 8;
    count = count.ceilToDouble() / pageCount;
    return count.ceil();
  }

  String? _getPhrase(Song song, int barIndex, int verse) {
    final Bar? bar = _getBar(song, barIndex);

    List<String>? phrases = bar?.phrases;
    return (phrases != null && verse < phrases.length) ? phrases[verse] : null;
  }
}
