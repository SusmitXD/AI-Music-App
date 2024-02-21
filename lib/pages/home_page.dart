import 'package:ai_music_app/models/radio.dart';
import 'package:ai_music_app/utils/ai_util.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio>? radios;

  MyRadio? _selectedRadio;
  Color? _selectedColor;
  bool _isplaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        _isplaying = true;
      } else {
        _isplaying = false;
      }
      setState(() {});
    });
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(UrlSource(url));
    _selectedRadio = radios!.firstWhere((element) => url == element.url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      drawer: const Drawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIColors.primaryColor2,
                    _selectedColor ?? AIColors.primaryColor1,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
          if (radios == null)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (radios != null)
            VxSwiper.builder(
              itemCount: radios!.length,
              aspectRatio: 1.0,
              enlargeCenterPage: true,
              onPageChanged: (index) {
                final String colorHex = radios![index].color;
                _selectedColor = Color(int.parse(colorHex));
                setState(() {});
              },
              itemBuilder: (context, index) {
                final rad = radios![index];
                return VxBox(
                  child: ZStack(
                    [
                      Positioned(
                        right: 0,
                        top: 0,
                        child: VxBox(
                                child: rad.category.text.uppercase.white
                                    .make()
                                    .pLTRB(8, 10, 12, 8))
                            .height(40)
                            .black
                            .alignCenter
                            .withRounded(value: 10.0)
                            .make(),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VStack(
                          [
                            rad.name.text.xl3.bold.white.make(),
                            5.heightBox,
                            rad.tagline.text.sm.semiBold.white.make()
                          ],
                          crossAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                      if (!_isplaying)
                        Align(
                            alignment: Alignment.center,
                            child: [
                              const Icon(
                                Icons.play_circle_sharp,
                                color: Colors.white,
                              ),
                              10.heightBox,
                              "Double Tap to Play".text.gray300.make()
                            ].vStack())
                    ],
                  ),
                )
                    .clip(Clip.antiAlias)
                    .bgImage(
                      DecorationImage(
                        image: NetworkImage(rad.image),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3), BlendMode.darken),
                      ),
                    )
                    .border(color: Colors.black, width: 5)
                    .withRounded(value: 60.0)
                    .make()
                    .onInkDoubleTap(() {
                  _playMusic(rad.url);
                }).p16();
              },
            ).centered(),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isplaying)
                "Now Playing - ${_selectedRadio!.name} FM".text.makeCentered(),
              Icon(
                _isplaying ? Icons.stop_circle : Icons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onTap(() {
                if (_isplaying) {
                  _audioPlayer.stop();
                } else {
                  _playMusic(_selectedRadio!.url);
                }
              }),
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
      ),
      appBar: AppBar(
        title: "Resso"
            .text
            .bold
            .xl4
            .white
            .make()
            .shimmer(primaryColor: Vx.purple300, secondaryColor: Vx.white),
        backgroundColor: Colors.transparent,
        elevation: 0.00,
        centerTitle: true,
      ),
    );
  }
}
