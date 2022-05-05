// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/loader/song.dart';

const backColor = Color(0xffFFFFFF);
const chordColor = Colors.black;
const phraseColor = chordColor;
const darkColor = Color(0xff121212);
const phraseSize = 8.0;
const chordSize = phraseSize + 2.0;

class SongView extends StatelessWidget {
  static const int pageCount = 2; // TODO iff device witch > 400

  final String name;
  const SongView({required this.name, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Persist>(
      builder: (BuildContext context, value, Widget? child) {
        final border = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),//TODO calc total padding
        );
        const padding = EdgeInsets.only(left :0.0);//TODO calc total padding
        var children = <Widget>[];

        for (int pageIndex = 0; pageIndex < pageCount; ++pageIndex) {
          children.add(
            Expanded(
              child: Padding(
                padding: padding,
                child: Card(
                  shape: border,
                  color: backColor,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _getStaveCount(context),
                    itemBuilder: (context, staveIndex) =>
                        _buildStave(context, staveIndex, pageIndex),
                  ),
                ),
              ),
            ),
          );
        }
        return Row(
          // mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }

  Widget _buildStave(BuildContext context, int staveIndex, int pageIndex) {
    staveIndex += pageIndex * _getStaveCount(context);

    final m = MediaQuery.of(context);
    //TODO calc total padding
    double height = m.size.height - m.padding.top - 44;

    return SizedBox(
      height: height / _getStaveCount(context),
      child: ListView.builder(
        itemCount: 8,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, columnIndex) =>
            _buildBar(context, staveIndex, columnIndex),
      ),
    );
  }

  Widget _buildBar(BuildContext context, int staveIndex, int columnIndex) {
    final size = MediaQuery.of(context).size;
    double width = size.width;

    int barIndex = staveIndex * 8 + columnIndex;
    return SizedBox(
      width: width / (8 * pageCount),
      child: Column(
        children: _buildTexts(context, barIndex),
      ),
    );
  }

  List<Widget> _buildTexts(BuildContext context, int barIndex) {
    List<Widget> list = <Widget>[];
    list.add(
      Align(
        alignment: Alignment.topLeft,
        child: Text(
          _getChord(context, barIndex),
          // textAlign: TextAlign.left,
          style: const TextStyle(
            color: chordColor,
            fontSize: chordSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    for (int i = 0; i < 4; ++i) {
      String? phrase = _getPhrase(context, barIndex, i);

      if (phrase != null) {
        list.add(_buildPhrase(context, phrase));
      }
    }
    return list;
  }

  Align _buildPhrase(BuildContext context, String phrase) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.only(right: 13.0),
        child: Text(
          phrase,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: phraseSize,
            // fontFamily: 'Roboto',
            color: phraseColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Bar? _getBar(BuildContext context, int barIndex) {
    Song? song = context.watch<Persist>().songs[name];
    final bars = song?.bars;

    if (bars == null) {
      return null;
    }
    if (barIndex >= bars.length) {
      return null;
    }
    return bars[barIndex];
  }

  String _getChord(BuildContext context, int barIndex) {
    final Bar? bar = _getBar(context, barIndex);
    return bar?.chord ?? "";
  }

  int _getStaveCount(BuildContext context) {
    Song? song = context.watch<Persist>().songs[name];
    // int count = (song?.bars.length ?? 0) ~/ 8;
    // return count ~/ pageCount; // TODO maths from Mel
    double count = (song?.bars.length ?? 0) / 8;
    count = count.ceilToDouble() / pageCount;
    return count.ceil();
  }

  String? _getPhrase(BuildContext context, int barIndex, int verse) {
    final Bar? bar = _getBar(context, barIndex);

    List<String>? phrases = bar?.phrases;
    return (phrases != null && verse < phrases.length) ? phrases[verse] : null;
  }
}
