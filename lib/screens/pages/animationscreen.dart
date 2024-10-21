import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:todo/screens/auth/login_screen.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late VideoPlayerController _controller;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    print('IntroScreen est en cours');

    _controller = VideoPlayerController.asset('assets/animation.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
        print('Video est en cours');

        // Écouteurs pour la vidéo après la lecture
        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }
          }
        });
      });

    // Redirection après 5 secondes si la vidéo ne se termine pas
    _sessionTimer = Timer(Duration(seconds: 5), () {
      if (Navigator.of(context).canPop()) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _sessionTimer?.cancel(); // Annule le timer ici si nécessaire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(), // Loader pendant l'initialisation
      ),
    );
  }
}
