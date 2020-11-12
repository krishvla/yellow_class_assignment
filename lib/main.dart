import 'dart:math';
import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:draggable_widget/draggable_widget.dart';

void main() {
  runApp(
    VideoPlayerApp(),
  );
}

class VideoPlayerApp extends StatefulWidget {
  VideoPlayerApp({this.title = 'Video Player App'});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerAppState();
  }
}

class _VideoPlayerAppState extends State<VideoPlayerApp> {
  DragController dragController = DragController();
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;
  CameraController _controller;
  List<CameraDescription> _cameras;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double top = 0;
  double left = 0;

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[1], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    this.initializePlayer();
    this._initCamera();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 = VideoPlayerController.network(
        'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_1MB.mp4');
    await _videoPlayerController1.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      fullScreenByDefault: true,
      showControlsOnInitialize: true,
      autoInitialize: true,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: ThemeData.light().copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
        body: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              _builtVideoPlayer(),
              _buildCameraPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _builtVideoPlayer() {
    return Center(
      child: _chewieController != null &&
              _chewieController.videoPlayerController.value.initialized
          ? Chewie(
              controller: _chewieController,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading'),
              ],
            ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        DraggableWidget(
          bottomMargin: 150,
          intialVisibility: true,
          horizontalSapce: 0,
          shadowBorderRadius: 50,
          initialPosition: AnchoringPosition.bottomLeft,
          dragController: dragController,
          child: Transform.rotate(
            angle: 11,
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.all(5),
              width: 100,
              height: 100,
              child: CameraPreview(_controller),
              decoration: new BoxDecoration(
                color: Color.fromARGB(255, 75, 131, 243),
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.circular(8.0),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    // offset: new Offset(0.0, 10.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
