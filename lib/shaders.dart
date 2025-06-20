import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';



import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GesturePageSwipeWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeComplete;
  final double swipeThreshold; // Minimum swipe distance to trigger completion
  
  const GesturePageSwipeWidget({
    Key? key,
    required this.child,
    this.onSwipeComplete,
    this.swipeThreshold = 0.3, // 30% of screen width
  }) : super(key: key);

  @override
  State<GesturePageSwipeWidget> createState() => _GesturePageSwipeWidgetState();
}

class _GesturePageSwipeWidgetState extends State<GesturePageSwipeWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;
  
  ui.FragmentShader? _shader;
  ui.Image? _pageImage;
  final GlobalKey _repaintKey = GlobalKey();
  
  double _swipeProgress = 0.0;
  bool _isAnimating = false;
  
  @override
  void initState() {
    super.initState();
    
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
        _swipeProgress = _swipeAnimation.value;
      });
    });
    
    _swipeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimating = false;
        widget.onSwipeComplete?.call();
      } else if (status == AnimationStatus.dismissed) {
        _isAnimating = false;
      }
    });
    
    _loadShader();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capturePageImage();
    });
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
      final RenderRepaintBoundary boundary = 
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      setState(() {
        _pageImage = image;
      });
    } catch (e) {
      print('Error capturing page image: $e');
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (_isAnimating) return;
    _swipeController.stop();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final deltaX = details.delta.dx;
    
    // Only respond to left swipes (negative deltaX)
      setState(() {
        _swipeProgress = (_swipeProgress - deltaX / screenWidth).clamp(0.0, 2.0);
      });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isAnimating) return;
    
    _isAnimating = true;

    
    _swipeController.reset();
    setState(() {
      _swipeProgress = 0.0;
    _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Stack(
        children: [
          // Original page content
          RepaintBoundary(
            key: _repaintKey,
            child: widget.child,
          ),
          
          // Shader overlay (always present but with varying progress)
          if (_shader != null && _pageImage != null && _swipeProgress > 0.0)
            Positioned.fill(
              child: CustomPaint(
                painter: PageSwipeShaderPainter(
                  shader: _shader!,
                  swipeProgress: _swipeProgress,
                  pageImage: _pageImage!,
                  containerSize: MediaQuery.of(context).size,
                  cornerRadius: 12.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _pageImage?.dispose();
    super.dispose();
  }
}

// Example usage widget
class SwipePageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade100,
        appBar: AppBar(
          title: const Text('Swipe Me Left'),
          backgroundColor: Colors.blue.shade300,
        ),
        body:
        
        GesturePageSwipeWidget(
        
              onSwipeComplete: () {
        // Navigate to next page or perform action
        print('Swipe completed!');
              },
            
        child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe_left,
                  size: 100,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  'Swipe left to see the effect!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'The page will curve and reveal as you swipe',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
              ),
    );
  }
}

class PageSwipeWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeComplete;
  
  const PageSwipeWidget({
    Key? key,
    required this.child,
    this.onSwipeComplete,
  }) : super(key: key);

  @override
  State<PageSwipeWidget> createState() => _PageSwipeWidgetState();
}

class _PageSwipeWidgetState extends State<PageSwipeWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;
  
  ui.FragmentShader? _shader;
  ui.Image? _pageImage;
  final GlobalKey _repaintKey = GlobalKey();
  
  bool _isSwipeInProgress = false;
  double _swipeProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _swipeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOutCubic,
    ));
    
    _swipeAnimation.addListener(() {
      setState(() {
        _swipeProgress = _swipeAnimation.value;
      });
    });
    
    _swipeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isSwipeInProgress = false;
        widget.onSwipeComplete?.call();
      }
    });
    
    _loadShader();
    
    // Capture page image after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capturePageImage();
    });
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
      final RenderRepaintBoundary boundary = 
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      setState(() {
        _pageImage = image;
      });
    } catch (e) {
      print('Error capturing page image: $e');
    }
  }

  void _startSwipe() {
    if (!_isSwipeInProgress && _shader != null && _pageImage != null) {
      setState(() {
        _isSwipeInProgress = true;
      });
      _swipeController.forward(from: 0.0);
    }
  }

  void _resetSwipe() {
    _swipeController.reset();
    setState(() {
      _swipeProgress = 0.0;
      _isSwipeInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Original page content
          RepaintBoundary(
            key: _repaintKey,
            child: widget.child,
          ),
          
          // Shader overlay
          if (_isSwipeInProgress && _shader != null && _pageImage != null)
            Positioned.fill(
              child: CustomPaint(
                painter: PageSwipeShaderPainter(
                  shader: _shader!,
                  swipeProgress: _swipeProgress,
                  pageImage: _pageImage!,
                  containerSize: MediaQuery.of(context).size,
                  cornerRadius: 12.0,
                ),
              ),
            ),
          
          // Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startSwipe,
                  child: const Text('Start Swipe'),
                ),
                ElevatedButton(
                  onPressed: _resetSwipe,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _pageImage?.dispose();
    super.dispose();
  }
}


class PageSwipeShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double swipeProgress; // 0.0 to 1.0
  final ui.Image pageImage;
  final Size containerSize;
  final double cornerRadius;

  PageSwipeShaderPainter({
    required this.shader,
    required this.swipeProgress,
    required this.pageImage,
    required this.containerSize,
    this.cornerRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Calculate pointer position based on swipe progress
    // pointer moves from right (containerSize.width) to left (0)
    final pointer = containerSize.width * (1.0 - swipeProgress);
    final origin = containerSize.width; // Starting position (right edge)

    // Container bounds as vec4 (left, top, right, bottom)
    final container = Rect.fromLTWH(0, 0, containerSize.width, containerSize.height);

    // Set shader uniforms in order:
    // uniform vec2 resolution;     - indices 0, 1
    // uniform float pointer;       - index 2
    // uniform float origin;        - index 3
    // uniform vec4 container;      - indices 4, 5, 6, 7
    // uniform float cornerRadius;  - index 8
    // uniform sampler2D image;     - sampler index 0

    shader.setFloat(0, size.width);           // resolution.x
    shader.setFloat(1, size.height);          // resolution.y
    shader.setFloat(2, pointer);              // pointer position
    shader.setFloat(3, origin);               // origin position
    shader.setFloat(4, container.left);       // container.x (left)
    shader.setFloat(5, container.top);        // container.y (top)
    shader.setFloat(6, container.right);      // container.z (right)
    shader.setFloat(7, container.bottom);     // container.w (bottom)
    shader.setFloat(8, cornerRadius);         // cornerRadius
    
    // Set the page image texture
    shader.setImageSampler(0, pageImage);     // image sampler

    paint.shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant PageSwipeShaderPainter oldDelegate) {
    return oldDelegate.swipeProgress != swipeProgress ||
           oldDelegate.pageImage != pageImage ||
           oldDelegate.containerSize != containerSize ||
           oldDelegate.cornerRadius != cornerRadius;
  }
}