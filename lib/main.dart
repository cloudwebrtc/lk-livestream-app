import 'package:flutter/material.dart';
import 'package:livekit_components/livekit_components.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: LiveKitTheme().buildThemeData(context),
      home: const MyHomePage(),
    );
  }
}

class StreamPageView extends StatelessWidget {
  final String url;
  final String token;
  const StreamPageView({
    super.key,
    required this.url,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return LivekitRoom(
      roomContext: RoomContext(
        url: url,
        token: token,
        connect: true,
      ),
      builder: (context, roomCtx) {
        return Center(
            child: Stack(
          children: [
            RoomParticipants(
              builder: (context, participants) {
                var remoteParticipant = participants
                    .where(
                        (p) => p.identity != roomCtx.localParticipant?.identity)
                    .firstOrNull;

                if (remoteParticipant != null) {
                  var videoTrack =
                      remoteParticipant.videoTrackPublications.firstOrNull;
                  return ParticipantTrack(
                    participant: remoteParticipant,
                    track: videoTrack,
                    builder: (BuildContext context) {
                      return Stack(
                        children: [
                          /// video track widget in the background

                          IsSpeakingIndicator(
                            builder: (context, isSpeaking) {
                              return isSpeaking != null
                                  ? IsSpeakingIndicatorWidget(
                                      isSpeaking: isSpeaking,
                                      child: const VideoTrackWidget(),
                                    )
                                  : const VideoTrackWidget();
                            },
                          ),

                          /// focus toggle button at the top right
                          const Positioned(
                            left: 0,
                            right: 0,
                            top: 80,
                            child: ParticipantStatusBar(),
                          ),

                          /// track stats at the top left
                          const Positioned(
                            top: 100,
                            left: 0,
                            child: TrackStatsWidget(),
                          ),
                        ],
                      );
                    },
                  );
                }

                return Container(
                  color: Colors.black,
                );
              },
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                  child: Container(
                width: 80,
                height: 24,
                color: Colors.grey,
                child: Text(
                  roomCtx.roomName ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              )),
            ),
          ],
        ));
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String url = 'ws://192.168.2.141:7880';
  final tokens = [
    'token1',
    'token2',
    'token3',
    'token4',
    'token5',
  ];
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
    viewportFraction: 1.0,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        pageSnapping: true,
        children: [
          for (var i = 0; i < tokens.length; i++)
            StreamPageView(
              url: url,
              token: tokens[i],
            ),
        ],
      ),
    );
    /*return */
  }
}
