import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(Meditation());
}

class Meditation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  late Future<void> _initializeVideoPlayerFuture1;
  late Future<void> _initializeVideoPlayerFuture2;
  bool _isFirstVideoPlaying = true;
  bool _isSecondVideoPlaying = false;

  @override
  void initState() {
    _controller1 = VideoPlayerController.asset('assets/candle1-1.mp4');
    _controller2 = VideoPlayerController.asset('assets/candle1-2.mp4');

    _initializeVideoPlayerFuture1 = _controller1.initialize();
    _initializeVideoPlayerFuture2 = _controller2.initialize();

    _controller1.play();
    _controller1.addListener(_videoListener);
    super.initState();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _videoListener() {
    if (!_controller1.value.isPlaying &&
        _controller1.value.position >= _controller1.value.duration) {
      setState(() {
        _isFirstVideoPlaying = !_isFirstVideoPlaying;
        if (_isFirstVideoPlaying) {
          _controller1.seekTo(Duration.zero);
          _controller1.play();
        } else {
          _controller2.seekTo(Duration.zero);
          _controller2.play();
          _isSecondVideoPlaying = !_isSecondVideoPlaying;
        }
      });
    }
    if (!_controller2.value.isPlaying &&
        _controller2.value.position >= _controller2.value.duration) {
      setState(() {
        _isSecondVideoPlaying = !_isSecondVideoPlaying;
        if (_isSecondVideoPlaying) {
          _controller2.seekTo(Duration.zero);
          _controller2.play();
        } else {
          _controller1.seekTo(Duration.zero);
          _controller1.play();
          _isFirstVideoPlaying = !_isFirstVideoPlaying;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Video Player Demo'),
      ),
      body: Container(
        child: _isFirstVideoPlaying
            ? FutureBuilder(
                future: _initializeVideoPlayerFuture1,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller1.value.aspectRatio,
                      child: VideoPlayer(_controller1),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            : FutureBuilder(
                future: _initializeVideoPlayerFuture2,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller2.value.aspectRatio,
                      child: VideoPlayer(_controller2),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
      ),
    );
  }
}
