import 'package:dream_book_animation/pageCurl.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_shaders/flutter_shaders.dart';
void main() async{
    // final ui.FragmentProgram program =
    //   await ui.FragmentProgram.fromAsset('shaders/inkwell.frag');
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
       home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(title: 'Flutter Demo Home Page'),
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _firstPageAnim;
  late Animation<double> _secondPageAnim;
  late Animation<double> _thirdPageAnim;
  bool readMode = false; 
  bool _showButtons = true;
  bool _fullScreen = false;
  late AnimationController _swipeUpController;
  late Animation<Offset> _swipeUpAnimation;
  late Animation<Offset> _swipeDownAnimation;
  late AnimationController _bottomSlideController;
  late Animation<double> _bottomSlideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
      duration: const Duration(milliseconds: 300),
    );

    _bottomSlideAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bottomSlideController,
        curve: Curves.linear,
      ),
    );

    _swipeDownAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, 0.3),
    ).animate(
      CurvedAnimation(
        parent: _swipeUpController,
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _swipeUpAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _swipeUpController,
      curve: Curves.easeInOut,
    ));
    
  }

  @override
  void dispose() {
    _controller.dispose();
    _swipeUpController.dispose();
    _bottomSlideController.dispose();
    super.dispose();
  }

  Future<void> _onBookTap() async {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
     
    _swipeUpController.forward();
     await _controller.forward();

      print('Animation completed');

         setState(() {
         _showButtons = false; 
        });

      print("_showButtons $_showButtons");

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
     
   
     await _controller.forward();

      setState(() {
      _fullScreen = true;
     });



     //reverse
     Future.delayed(Duration(milliseconds: 1000), () async {
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

      // _controller.reset();

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF232025),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                        print(_firstPageAnim.value);
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
                                    ..rotateY(readMode ? 0.3 - (_firstPageAnim.value * 0.1) : _firstPageAnim.value * 0.1),
                                  child: AnimatedContainer(height: _fullScreen ? size.width : 310,width: _fullScreen ? size.height * 0.5 : 215,duration: Duration(milliseconds: 300),child: Image.asset('assets/book.png', color:Color(0xff3E3C3F),fit: BoxFit.fill,)),
                                );

                                 final lastPageImage = Transform(
                                  alignment: Alignment.centerLeft,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(readMode ?  0 :_firstPageAnim.value * 0.1),
                                  child: AnimatedContainer(height: _fullScreen ? size.width : 310,width: _fullScreen ? size.height * 0.5 : 210,duration: Duration(milliseconds: 300),child: Image.asset('assets/book.png', color:Color(0xffBFBCBE),fit: BoxFit.fill,)),
                                );

                                final FirstPageImage = Transform(
                                  alignment: Alignment.centerLeft,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(_firstPageAnim.value *  0.9),
                                  child: AnimatedContainer(height: _fullScreen ? size.width : 310,width: _fullScreen ? size.height * 0.5 : 210,duration: Duration(milliseconds: 300),child: Image.asset('assets/book.png', color: Color(0xffBFBCBE),fit: BoxFit.fill,)),
                                );

                                final SecondPageImage = PageCurlWidget(
                                  child: Transform(
                                    alignment: Alignment.centerLeft,
                                    transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(readMode ? 0 :_firstPageAnim.value * 0.87),
                                    child: AnimatedContainer(height: _fullScreen ? size.width : 310,width: _fullScreen ? size.height * 0.5 : 210,duration: Duration(milliseconds: 300),child: Image.asset('assets/book.png', color: Colors.red,fit: BoxFit.fill,)),
                                  ),
                                );

                                final centerShadow = Positioned(
                                  left: 0,
                                  child: Container(
                                    width: 8,
                                    height: 310,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 169, 164, 166),
                                    
                                    ),
                                  ),
                                );
                                // final page3 = Transform(
                                //   alignment: Alignment.centerLeft,
                                //   transform: Matrix4.identity()
                                //     ..setEntry(3, 2, 0.001)
                                //      ..translate(_firstPageAnim.value * 8),
                                //   child: Image.asset('assets/book.png', color: Color(0xffBFBCBE),height: 340,),
                                  
                                // );
                   
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
                                        // ? [bookBackImage,page3,bookImage, page1, page2,] // book image at the back
                                        // : [bookBackImage,page3,page1, page2, bookImage,], // book image on top
                                     ? [bookBackImage,lastPageImage,bookImage,FirstPageImage,SecondPageImage,centerShadow] // book image at the back
                                        : [bookBackImage,lastPageImage,FirstPageImage,SecondPageImage,bookImage], // 
                                  ),
                            ],
                          ),
                                              ),
                        );}
                    )
                                   ),
                 ),
            const Spacer(),
           
       
            if (_showButtons)
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
        ),
    );
  }
}
