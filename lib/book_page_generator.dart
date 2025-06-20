import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BookPageGeneratorScreen extends StatefulWidget {
  const BookPageGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<BookPageGeneratorScreen> createState() => _BookPageGeneratorScreenState();
}

class _BookPageGeneratorScreenState extends State<BookPageGeneratorScreen> {
  final List<GlobalKey> _repaintKeys = List.generate(10, (_) => GlobalKey());
  final double pageWidth = 215;
  final double pageHeight = 310;
  List<Uint8List?> _images = List.filled(10, null);

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureAllImages());
  }

  Future<void> _captureAllImages() async {
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      await _captureImage(i);
    }
  }

  Future<void> _captureImage(int index) async {
    final boundary = _repaintKeys[index].currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null && boundary.debugNeedsPaint == false) {
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        setState(() {
          _images[index] = byteData.buffer.asUint8List();
        });
      }
    } else {
      // Retry if not ready
      Future.delayed(const Duration(milliseconds: 100), () => _captureImage(index));
    }
  }

  Widget _buildBookPage(int index) {
    return Container(
      width: pageWidth,
      height: pageHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Notebook lines
          ...List.generate(13, (i) {
            double top = 60 + i * 18;
            return Positioned(
              left: 16,
              right: 16,
              top: top,
              child: Container(
                height: 1,
                color: Colors.grey[300],
              ),
            );
          }),
          // Page number
          Positioned(
            top: 12,
            right: 20,
            child: Text(
              'Page ${index + 1}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Date
          Positioned(
            top: 18,
            left: 20,
            child: Text(
              dates[index],
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Note
          Positioned(
            top: 48,
            left: 20,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Page Generator')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: _images[index] != null,
                child: RepaintBoundary(
                  key: _repaintKeys[index],
                  child: _buildBookPage(index),
                ),
              ),
              const SizedBox(height: 8),
              if (_images[index] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_images[index]!, width: pageWidth, height: pageHeight),
                ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
} 