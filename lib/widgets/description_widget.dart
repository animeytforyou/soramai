import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:soramai/src/anime/character.dart';

class CharacterDescription extends StatefulWidget {
  final String description;
  const CharacterDescription({required this.description, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CharacterDescriptionState createState() => _CharacterDescriptionState();
}

class _CharacterDescriptionState extends State<CharacterDescription> {
  Set<String> revealedSpoilers = {};

  List<InlineSpan> _parseDescription(String description) {
    final spoilerRegex = RegExp(r'~!(.*?)!~', multiLine: true);
    final linkRegex = RegExp(
        r'\[(.*?)\]\(https:\/\/anilist\.co\/character\/(\d+)\/.+?\)',
        multiLine: true);

    final spans = <InlineSpan>[];
    int currentIndex = 0;

    for (final match in spoilerRegex.allMatches(description)) {
      if (match.start > currentIndex) {
        spans.addAll(_buildTextSpans(
            description.substring(currentIndex, match.start), linkRegex));
      }

      final spoilerText = match.group(1) ?? '';
      if (revealedSpoilers.contains(spoilerText)) {
        spans.addAll(_buildTextSpans(spoilerText, linkRegex));
      } else {
        spans.add(_buildSpoilerSpan(spoilerText));
      }

      currentIndex = match.end;
    }

    if (currentIndex < description.length) {
      spans.addAll(
          _buildTextSpans(description.substring(currentIndex), linkRegex));
    }

    return spans;
  }

  List<InlineSpan> _buildTextSpans(String text, RegExp linkRegex) {
    final spans = <InlineSpan>[];
    int currentIndex = 0;

    for (final match in linkRegex.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      spans.add(_buildLinkSpan(match.group(1) ?? '', match.group(2) ?? ''));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  WidgetSpan _buildSpoilerSpan(String spoilerText) {
    final textStyle = DefaultTextStyle.of(context).style;

    final textPainter = TextPainter(
      text: TextSpan(text: spoilerText, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    return WidgetSpan(
      child: GestureDetector(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Spoiler Alert'),
              content: const Text(
                  'This part contains spoilers. Do you want to reveal it?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Reveal'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            setState(() {
              revealedSpoilers.add(spoilerText);
            });
          }
        },
        child: Container(
          width: textPainter.width,
          height: textPainter.height,
          color: Colors.black,
          child: Center(
            child: Text(
              'spoiler',
              style: textStyle.copyWith(
                color: Colors.black,
                backgroundColor: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextSpan _buildLinkSpan(String displayText, String characterId) {
    return TextSpan(
      text: displayText,
      style: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final id = int.tryParse(characterId);
          if (id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CharacterDetailsPage(characterId: id),
              ),
            );
          }
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: _parseDescription(widget.description),
      ),
    );
  }
}
