import 'package:flutter/material.dart';
import 'package:soramai/classes/anime.dart';
import 'package:soramai/classes/custom_navbar_controller.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({
    super.key,
    required this.navBarController,
    required this.anime,
    required this.animeRes,
  });

  final CustomNavBarController navBarController;
  final Anime anime;
  final AnimeSearchResult animeRes;

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  goHome() {
    setState(() {
      widget.navBarController.setCurrentScreen(0);
    });
  }

  goToEpisodes() {
    setState(() {
      widget.navBarController.setCurrentScreen(1);
    });
  }

  Color _hexToColor(String hexColor) {
    if (hexColor == "") {
      return const Color(0xffcdcdcd);
    }
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.substring(1);
    }
    int colorValue = int.parse(hexColor, radix: 16);
    return Color(colorValue).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final ambientColor = _hexToColor(widget.anime.cover.color);
    return Padding(
      padding: const EdgeInsetsDirectional.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * .2,
        height: 50,
        decoration: BoxDecoration(
          color: ambientColor.withOpacity(.2),
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.25),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: goHome,
                child: Text("Details", style: TextStyle(color: ambientColor)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: goToEpisodes,
                child: Text(
                    widget.anime.type == AnimeType.Anime ? "Watch" : "Read",
                    style: TextStyle(color: ambientColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
