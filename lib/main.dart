import 'dart:ui';

import 'package:dream_book_animation/shaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';
import 'dart:ui' as ui;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
       home:  HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(title: "",),
              ),
            );
          },
          child: Text(
            'Animated Book',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _firstPageAnim;
  bool readMode = false; 
  bool _showButtons = true;
  bool _fullScreen = false;
  late AnimationController _swipeUpController;
  late Animation<Offset> _swipeUpAnimation;
  late Animation<Offset> _swipeDownAnimation;
  late AnimationController _bottomSlideController;
  late Animation<double> _bottomSlideAnim;
   late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;
  
  ui.FragmentShader? _shader;
  ui.Image? _pageImage;
  ui.Image? _pageImage2;
  final GlobalKey _repaintKey = GlobalKey();
  final GlobalKey _repaintKey2 = GlobalKey();
  
  double _swipeProgress = 0.0;
  double _swipeDownProgress = 1.4;

 
  @override
  void initState() {
    super.initState();


    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _firstPageAnim = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
  
    _swipeUpController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _bottomSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _bottomSlideAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bottomSlideController,
        curve: Curves.linear,
      ),
    );

    _swipeDownAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, 2),
    ).animate(
      CurvedAnimation(
        parent: _swipeUpController,
        curve: Curves.easeInOut,
      ),
    );

    _swipeUpAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _swipeUpController,
      curve: Curves.easeInOut,
    ));

     _swipeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _swipeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    
    _swipeAnimation.addListener(() {
      setState(() {
        _updateSwipeProgress(_swipeAnimation.value * 2);
      });
    });
    
    
    _loadShader();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 2000), () async { 
        await _capturePageImage();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _swipeUpController.dispose();
    _bottomSlideController.dispose();
    _swipeController.dispose();
    super.dispose();
  }


  Future<void> _onBookTap() async {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
     
     await _controller.forward();

         setState(() {
         _showButtons = false; 
        });


      _controller.reset();

      _firstPageAnim = Tween<double>(begin: 3, end: 3.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
     );

     setState(() {
      readMode = true;
     });
     
     await  _swipeController.forward();
    _swipeUpController.forward();
     await _controller.forward();
  
      setState(() {
      _fullScreen = true;
     });



     //reverse
     Future.delayed(Duration(milliseconds: 300), () async {
         await  Future.delayed(Duration(milliseconds: 300), () async {
     await _bottomSlideController.forward();
     });

      _bottomSlideController.reverse();
    setState(() {
        _fullScreen = false;
      });
       await _controller.reverse();
       
     setState(() {
      readMode = false;
     });


        _firstPageAnim = Tween<double>(begin: 3, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
         setState(() {
         _showButtons = false; 
        });

    _swipeUpController.reverse();
      _controller.forward();

  
     });
    }
  }

  
  Future<void> _loadShader() async {
    try {
      final program = await FragmentProgram.fromAsset('shaders/inkwell.frag');
      setState(() {
        _shader = program.fragmentShader();
      });
    } catch (e) {
      print('Error loading shader: $e');
    }
  }

  Future<void> _capturePageImage() async {
  try {

  await Future.delayed(Duration.zero);
  if (mounted) setState(() {});
  await Future.delayed(Duration(milliseconds: 50));

  final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  final boundary2 = _repaintKey2.currentContext?.findRenderObject() as RenderRepaintBoundary?;


  print("Getting image from boundary 1");
  final image = await boundary!.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio);

  print("Getting image from boundary 2");
  final image2 = await boundary2!.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio);

  print("image2: $image2");

  if (mounted) {
    setState(() => _pageImage = image);
    setState(() => _pageImage2 = image2);
  }
} catch (e, stack) {
  _scheduleImageCapture();
}
}

void _scheduleImageCapture() {
  if (mounted) {
    Future.delayed(const Duration(milliseconds: 100), _capturePageImage);
  }
}


  void _updateSwipeProgress(double value) {
    var progress = value.clamp(0.0, 2.0);

    if (progress < 2) {
      _swipeProgress = progress;
    }
    if (progress > 1.16) {
      _swipeDownProgress = _swipeDownProgress - (((progress - 1.16)) / 20);
    }
    if(value == 2){
      _swipeDownProgress = 0;
      _swipeProgress = 0;
      _shader = null;
    }
    setState(() {});
  }

  final List<String> dates = [
    'Wednesday, 28 May 2025',
    'Thursday, 29 May 2025',
    'Friday, 30 May 2025',
    'Saturday, 31 May 2025',
    'Sunday, 1 June 2025',
    'Monday, 2 June 2025',
    'Tuesday, 3 June 2025',
    'Wednesday, 4 June 2025',
    'Thursday, 5 June 2025',
    'Friday, 6 June 2025',
  ];

  final List<String> notes = [
    'Released yume in the app store, got 1 million downloads after a week. Then I woke up...',
    'Dreamed of flying over a city of lights. It felt so real!',
    'Met an old friend in a place I have never seen before.',
    'Was running a marathon on clouds. My feet never touched the ground.',
    'Had a conversation with a talking cat about philosophy.',
    'Explored a library with endless bookshelves.',
    'Found a secret garden behind a mirror.',
    'Attended a concert where everyone played invisible instruments.',
    'Walked through a city where it rained colors.',
    'Wrote a letter to my future self and received a reply instantly.',
  ];


Widget _buildBookPage(int index,bool top) {
    return AnimatedContainer(
      padding: EdgeInsets.only(left: _fullScreen ? 30 : 0),
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(16),bottomRight: Radius.circular(16)) ,
        color:  Color(0xffBBB8BB),
      ),
      child: Transform.flip(
        flipY: true,
        child: Transform.rotate(
          angle: pi * 0.5,
          child: Stack(
            children: [
              // Notebook lines
              AnimatedOpacity(
                   opacity: _fullScreen ? 0.0 : 1.0,
                   duration: Duration(milliseconds: 500),
                    child: Stack(
                      alignment: Alignment.center,
                         children: [
         ...List.generate(6, (i) {
                double top = (60 + i * 18) + 60;
                return Positioned(
                  left: 0,
                  right: 0,
                  top: top,
                  child: Container(
                    height: 1,
                    color: Color.fromARGB(255, 153, 148, 149),
                  ),
                );
              }),
    ]
  )),
             
            if(top == true)
              Positioned(
                top: 16 + 50,
                right: 0,
                child: Text(
                  'Page ${index + 1}',
                  style: TextStyle(
                    color: Color.fromARGB(255, 78, 77, 79),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Date
            if(top == true)
              Positioned(
                top: 18+ 50,
                left: 0,
                child: Text(
                  dates[index],
                  style: TextStyle(
                    color: Color(0xff5B595C),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Note
            if(top == true)
              Positioned(
                top: 40 + 60,
                left: 5,
                right: 20,
                child: Text(
                  notes[index],
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF232025),
      body:
       SafeArea(
        child:  Column(
              children: [         
                SlideTransition(
                  position: _swipeUpAnimation,
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Wednesday, 28 May',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'Here, your dreams\ncome to life',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              
                     GestureDetector(
                       onTap: _onBookTap,
                       child: Container(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_firstPageAnim, _bottomSlideAnim]),
                          builder: (context, child) {
                                    final isFlipped = _firstPageAnim.value > pi / 2;
                                 
                                    final bookImage = Transform(
                                      alignment: Alignment.centerLeft,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(_firstPageAnim.value * 0.9),
                                      child: AnimatedContainer(height: _fullScreen ? size.width : 310,width: _fullScreen ? size.height * 0.5 : 215,duration: Duration(milliseconds: 300),child: Image.asset('assets/book.png', color:  isFlipped ? Color(0xff3E3C3F) : null,fit: BoxFit.fill,)),
                                    );
                                 
                                    final bookBackImage = Transform(
                                      alignment: Alignment.centerLeft,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(_firstPageAnim.value * 0.01),
                                      child: AnimatedContainer(height: _fullScreen ? size.width : 310,width: _fullScreen ? size.height * 0.5 : 215,duration: Duration(milliseconds: 300),child: Image.asset('assets/book.png', color:Color(0xff3E3C3F),fit: BoxFit.fill,)),
                                    );
                                 
                                     final lastPageImage = Transform(
                                      alignment: Alignment.centerLeft,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(_firstPageAnim.value * 0.01),
                                      child: RepaintBoundary(key: _repaintKey,child: AnimatedContainer(height: _fullScreen ? size.width : 310,width: _fullScreen ? size.height * 0.5 : 210,duration: Duration(milliseconds: 300),child: _buildBookPage(1,false))),
                                    );
                                 
                                    final FirstPageImage = Transform(
                                      alignment: Alignment.centerLeft,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(_firstPageAnim.value *  0.9),
                                      child: RepaintBoundary(key:_repaintKey2,child: AnimatedContainer(height: _fullScreen ? size.width : 310,width: _fullScreen ? size.height * 0.5 : 210,duration: Duration(milliseconds: 300),child: _buildBookPage(_shader == null ||_swipeProgress > 0.8? 3: 2,true))),
                                    );
                                 
                                    final SecondPageImage = Transform(
                                      alignment: Alignment.centerLeft,
                                      transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..rotateY(_firstPageAnim.value * 0.87),
                                      child: AnimatedContainer(height: _fullScreen ? size.width : 310,width: _fullScreen ? size.height * 0.5 : 210,duration: Duration(milliseconds: 300),child: _buildBookPage(3,false)),
                                    );
                     
                                    
                                  final pageSwipeShader = _shader == null || _pageImage2 == null || _swipeProgress ==  0.0 ? SizedBox() : Transform(
                                     alignment: Alignment.centerLeft,
                                      transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..rotateY(_firstPageAnim.value *  0.9),
                                    child: SizedBox(
                                        height: 310,
                                  width: 210,
                                      child: CustomPaint(
                                          painter: PageSwipeShaderPainter(
                                          shader: _shader!,
                                          swipeProgress: _swipeProgress,
                                          pageImage: _pageImage2!,
                                          containerSize: MediaQuery.of(context).size,
                                          // cornerRadius: 12.0,
                                          ),
                                        ),
                                    ),
                                  );
                     
                                     final pageSwipeDownShader = _shader == null || _pageImage == null ? SizedBox() : Transform(
                                     alignment: Alignment.centerLeft,
                                      transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                           ..rotateY(readMode ? 0 :_firstPageAnim.value * 0.87),
                                    child: SizedBox(
                                        height: 310,
                                  width: 215,
                                      child: CustomPaint(
                                          painter: PageSwipeShaderPainter(
                                          shader: _shader!,
                                          swipeProgress: _swipeDownProgress,
                                          pageImage: _pageImage!,
                                          containerSize: MediaQuery.of(context).size,
                                          // cornerRadius: 12.0,
                                          ),
                                        ),
                                    ),
                                  );
                     
                                    final centerShadow = Positioned(
                                      left: 0,
                                      child: AnimatedOpacity(
                                        opacity: _fullScreen ? 0.0 : 1.0,
                                        duration: Duration(milliseconds: 300),
                                        child: Container(
                                          width: 8,
                                          height: 310,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(255, 169, 164, 166),
                                          ),
                                        ),
                                      ),
                                    );
                       
                            return Padding(
                              padding: EdgeInsets.only(top: _firstPageAnim.value * 50 + (_bottomSlideAnim.value * 200)),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                ..rotateZ(readMode ?1.65 * (3 / pi) :1.65 * (_firstPageAnim.value / pi)),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                       Stack(
                                        alignment: Alignment.center,
                                        children: isFlipped
                                         ? [bookBackImage,lastPageImage,bookImage,
                                      
                                       SecondPageImage  ,FirstPageImage,
                                            (_shader != null && _pageImage != null && _swipeProgress > 0.0) ?
                                        pageSwipeShader : SizedBox(),
                                            (_shader != null && _pageImage != null && _swipeProgress > 1.16) ?
                                        pageSwipeDownShader : SizedBox()
                                         ,centerShadow] // book image at the back
                                            : [bookBackImage,lastPageImage,FirstPageImage,SecondPageImage,bookImage], // 
                                      ),
                                ],
                              ),
                                                  ),
                            );}
                        )
                                       ),
                     ),
               
                   Spacer(),
                  SlideTransition(
                    position: _swipeDownAnimation,
                    child: Column(
                      children: [
                              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Add a dream by simply recording a\nvoice message or typing it out',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  ),
                                
                              
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.mic, size: 28),
                                  label: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text(
                                      'Record',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF353238),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.smart_toy, size: 28),
                                  label: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text(
                                      'Type',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF353238),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
               
                ],
        ),
       )
    );
  }
}
