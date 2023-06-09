
import 'package:ai_radio/model/radio.dart';
import 'package:ai_radio/utils/ai_utils.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  // const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio>? radios;
  MyRadio? _selectedRadio;
  Color?  _selectedColor;
  bool _isPlaying = false;
  final sugg = [

    "play",
    "Stop",
    "Play 107 FM",
    "Play next",
    "Pause",
    "Play previous",
    



  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   setupAlan();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }

      setState(() {});
    });
  }

  
  _playmusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios!.firstWhere((element) => element.url == url);
    print(_selectedRadio!.name);
    setState(() {});
  }


  setupAlan()
  {
    AlanVoice.addButton(
        "36fec4f354b77edfbd2df01eb2365e922e956eca572e1d8b807a3e2338fdd0dc/stage" ,

        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT,
  
        
        
        );
        AlanVoice.callbacks.add((command){


          _handlecommand(command.data);
        });


  }


  _handlecommand(Map<String,dynamic> response)
  {
    switch(response["command"]){

      case "play":
        _playmusic(_selectedRadio!.url);
        break;
      case "play_channel":
        final id = response["id"];
        //_audioPlayer.pause();
        MyRadio newRadio1 = radios!.firstWhere((element) => element.id==id);
        radios!.remove(newRadio1);
         radios!.insert(0, newRadio1);
        _playmusic(newRadio1.url); 
        break;  
      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _selectedRadio!.id;
        MyRadio newRadio;
          if(index +1 > radios!.length)
          {
            newRadio = radios!.firstWhere((element) => element.id==1);
            radios!.remove(newRadio);
            radios!.insert(0, newRadio);


          }
          else{

             newRadio = radios!.firstWhere((element) => element.id==index+1);
            radios!.remove(newRadio);
            radios!.insert(0, newRadio);

          }

          _playmusic(newRadio.url);

        break;
      case "prev":
        final index = _selectedRadio!.id;
        MyRadio newRadio;
          if(index -1  <= 0)
          {
            newRadio = radios!.firstWhere((element) => element.id==1);
            radios!.remove(newRadio);
            radios!.insert(0, newRadio);


          }
          else{

             newRadio = radios!.firstWhere((element) => element.id==index-1);
            radios!.remove(newRadio);
            radios!.insert(0, newRadio);

          }

          _playmusic(newRadio.url);
        break;
      default:
        print("command was ${response["command"]}");
        break;



    }
    
  }

  fetchRadios() async {
    final radiojson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radiojson).radios;
    _selectedRadio = radios![0];
    _selectedColor = Color(int.tryParse(_selectedRadio!.color)!);
    print(radios);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
    
          child: Container(
    
            color: _selectedColor ?? AIColors.primaryColor2,
            child: radios != null ?
    
            [
              "ALL Channels".text.xl.white.semiBold.make().p16(),
              20.heightBox,
              ListView(
    
                padding: Vx.m0,
                shrinkWrap: true,
    
                children: radios!.map((e) => ListTile(
    
                    leading: CircleAvatar(backgroundImage: NetworkImage(e.icon) ,) ,
    
                    title: "${e.name} FM".text.white.make(),
                    subtitle: e.tagline.text.white.make(),
    
    
                )).toList(),
    
              ).expand(),
    
    
    
            ].vStack(
              crossAlignment: CrossAxisAlignment.start
            ) 
            
            
             : const Offstage(), 
                   
          ),
        ),
        body: Stack(
          
          children: [
            VxAnimatedBox()
                .size(context.screenWidth, context.screenHeight)
                .withGradient(LinearGradient(
                    colors: [AIColors.primaryColor2,
                   _selectedColor ?? AIColors.primaryColor1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight))
                .make(),
            [AppBar(
              title: "AI Radio".text.xl4.bold.white.make().shimmer(
                    primaryColor: Vx.purple300,
                    secondaryColor: Vx.white,
                  ),
                   //automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(50).p16(),
            "Start with - Hey Alan".text.white.italic.semiBold.make(),
            //10.heightBox,
            VxSwiper.builder(itemCount: sugg.length, height: 50.0,

            viewportFraction: 0.35,
            autoPlay: true,
            autoPlayAnimationDuration: 3.seconds,
            autoPlayCurve: Curves.linear,
            enableInfiniteScroll: true,
            
            itemBuilder:
            
            (context , index){
    
              final s = sugg[index];
    
              return Chip(label:s.text.make(),
    
              backgroundColor: Vx.randomColor ,

    
              
              );
    
    
    
    
            },
            
            
             )      
            
            
            ].vStack(),
            //20.heightBox,
            radios != null
                ? VxSwiper.builder(
                    enlargeCenterPage: true,
                    itemCount: radios!.length,
                    onPageChanged: (index){
                      _selectedRadio = radios![index];

      
                      final colorHex = radios![index].color;
                      _selectedColor = Color(int.tryParse(colorHex)!);
                      setState(() {
                        
                      });
      
      
      
                    } ,
                    aspectRatio: 1.0,
                    itemBuilder: (context, index) {
                      final rad = radios![index];
      
                      return VxBox(
                        child: ZStack(
                          [
                            Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: VxBox(
                                child: rad.category.text.uppercase.white
                                    .make()
                                    .px16(),
                              )
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
                                  rad.name.text.xl3.white.bold.make(),
                                  5.heightBox,
                                  rad.tagline.text.sm.white.semiBold.make(),
                                ],
                                crossAlignment: CrossAxisAlignment.center,
                              ),
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: [
                                  Icon(
                                    CupertinoIcons.play_circle,
                                    color: Colors.white,
                                  ),
                                  10.heightBox,
                                  "Double tap to play".text.gray300.make(),
                                ].vStack()),
                          ],
                        ),
                      )
                          .clip(Clip.antiAlias)
                          .bgImage(DecorationImage(
                            image: NetworkImage(rad.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3), BlendMode.darken),
                          ))
                          .border(color: Colors.black, width: 5.0)
                          .withRounded(value: 60.0)
                          .make()
                          .onInkDoubleTap(() {
                        _playmusic(rad.url);
                      }).p16();
                    },
                  ).centered()
                : Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: [
                if (_isPlaying)
                  "Playing Now - ${_selectedRadio!.name} FM".text.makeCentered(),
                Icon(
                  _isPlaying
                      ? CupertinoIcons.stop_circle
                      : CupertinoIcons.play_circle,
                  color: Colors.white,
                  size: 50.0,
                ).onInkTap(() {
                  if (_isPlaying) {
                    _audioPlayer.stop();
                  } else {
                    _playmusic(_selectedRadio!.url);
                  }
                }),
              ].vStack(),
            ).pOnly(bottom: context.percentHeight * 12),
          ],
          fit: StackFit.expand,
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
  }
}
