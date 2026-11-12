import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import 'image_review_screen.dart';

class CameraScreen extends StatefulWidget {
  final bool openGallery;

  const CameraScreen({super.key, this.openGallery = false});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  static const Color forest = AppTheme.forest;
  static const Color lime = Color(0xFFC6F0A5);
  static const Color sage = Color(0xFFDCE9D6);
  static const Color softGreen = Color(0xFF2A5340);

  final ImagePicker _picker = ImagePicker();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  bool _isInitializing = false;
  bool _isCapturing = false;
  bool _isPickingGallery = false;
  bool _galleryFirstPending = false;

  String? _cameraError;
  int _cameraRequestId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.openGallery) {
      _galleryFirstPending = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openGallery();
        }
      });
    } else {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing || _isCapturing || _isPickingGallery) {
      return;
    }

    final requestId = ++_cameraRequestId;

    setState(() {
      _isInitializing = true;
      _cameraError = null;
    });

    CameraController? newController;

    try {
      final cameras = await availableCameras();

      if (!mounted || requestId != _cameraRequestId) {
        return;
      }

      if (cameras.isEmpty) {
        throw CameraException(
          'NoCamera',
          'No camera was found on this device.',
        );
      }

      _cameras = cameras;

      if (_cameraIndex >= cameras.length) {
        _cameraIndex = 0;
      }

      if (_controller == null && _cameraIndex == 0) {
        final rearIndex = cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );

        if (rearIndex >= 0) {
          _cameraIndex = rearIndex;
        }
      }

      newController = CameraController(
        cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await newController.initialize();

      if (!mounted || requestId != _cameraRequestId) {
        await newController.dispose();
        return;
      }

      final oldController = _controller;
      _controller = newController;
      newController = null;

      if (oldController != null) {
        await oldController.dispose();
      }

      if (!mounted || requestId != _cameraRequestId) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = null;
      });
    } on CameraException catch (error) {
      if (newController != null) {
        await newController.dispose();
      }

      if (!mounted || requestId != _cameraRequestId) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = _friendlyCameraError(error);
      });
    } catch (error) {
      if (newController != null) {
        await newController.dispose();
      }

      if (!mounted || requestId != _cameraRequestId) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = 'Unable to start the camera: $error';
      });
    }
  }

  String _friendlyCameraError(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
        return 'Camera permission was denied. '
            'Please allow camera access to use the scanner.';

      case 'CameraAccessDeniedWithoutPrompt':
        return 'Camera access is disabled. '
            'Enable it in your phone settings.';

      case 'CameraAccessRestricted':
        return 'Camera access is restricted on this device.';

      case 'NoCamera':
        return 'No camera is available on this device.';

      default:
        return 'Camera unavailable: '
            '${error.description ?? error.code}';
    }
  }

  Future<void> _releaseCamera() async {
    ++_cameraRequestId;

    final controller = _controller;
    _controller = null;

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }

    if (controller != null) {
      try {
        await controller.dispose();
      } catch (_) {
        // Camera may already have been released.
      }
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        _isCapturing ||
        _isPickingGallery ||
        _isInitializing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await controller.takePicture();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageReviewScreen(imagePath: photo.path),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to capture photo: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _openGallery() async {
    if (_isPickingGallery || _isCapturing) {
      return;
    }

    setState(() {
      _isPickingGallery = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1600,
      );

      if (!mounted) return;

      if (photo != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageReviewScreen(imagePath: photo.path),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to open gallery: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isPickingGallery = false;
          _galleryFirstPending = false;
        });

        if (_controller == null && !_isInitializing && _cameraError == null) {
          _initializeCamera();
        }
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 ||
        _isInitializing ||
        _isCapturing ||
        _isPickingGallery) {
      return;
    }

    await _releaseCamera();

    if (!mounted) return;

    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _releaseCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (!_galleryFirstPending &&
          !_isInitializing &&
          _controller == null &&
          !_isPickingGallery &&
          !_isCapturing &&
          _cameraError == null) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    ++_cameraRequestId;

    final controller = _controller;
    _controller = null;
    controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: forest,
      appBar: AppBar(
        backgroundColor: forest,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Scan your produce',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.center_focus_strong_rounded,
              color: lime,
              size: 23,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            const Text(
              'FRESHNESS CHECK',
              style: TextStyle(
                color: lime,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Let's take a\ncloser look.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.12,
                letterSpacing: -1,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Position one fruit or vegetable clearly '
              'inside the camera frame.',
              style: TextStyle(color: sage, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 22),

            // LIVE CAMERA
            _buildCameraCard(),

            const SizedBox(height: 18),

            // CAMERA CONTROLS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CameraAction(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: _isCapturing || _isPickingGallery
                      ? null
                      : _openGallery,
                ),

                GestureDetector(
                  onTap: _isCapturing || _isInitializing || _isPickingGallery
                      ? null
                      : _capturePhoto,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lime,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: _isCapturing
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: forest,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: forest,
                            size: 34,
                          ),
                  ),
                ),

                _CameraAction(
                  icon: Icons.cameraswitch_outlined,
                  label: 'Flip',
                  onTap:
                      _cameras.length > 1 &&
                          !_isCapturing &&
                          !_isInitializing &&
                          !_isPickingGallery
                      ? _switchCamera
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 13),

            const Center(
              child: Text(
                'Tap the camera button to capture your photo',
                textAlign: TextAlign.center,
                style: TextStyle(color: sage, fontSize: 12),
              ),
            ),

            const SizedBox(height: 25),

            // PHOTO TIPS
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: softGreen,
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: lime,
                        size: 21,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'For a better scan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  _TipRow(
                    icon: Icons.wb_sunny_outlined,
                    text: 'Use good, natural lighting',
                  ),

                  _TipRow(
                    icon: Icons.center_focus_strong_rounded,
                    text: 'Keep your produce in focus',
                  ),

                  _TipRow(
                    icon: Icons.filter_center_focus_rounded,
                    text: 'Capture one item at a time',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(27),
      child: Container(
        height: 350,
        width: double.infinity,
        color: softGreen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraContent(),

            // FOCUS FRAME OVERLAY
            IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: CustomPaint(painter: _CameraFramePainter()),
              ),
            ),

            Positioned(
              top: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: forest.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE CAMERA',
                  style: TextStyle(
                    color: lime,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraContent() {
    if (_cameraError != null) {
      return _CameraPlaceholder(
        icon: Icons.no_photography_outlined,
        message: _cameraError!,
        actionLabel: 'Try again',
        onAction: _initializeCamera,
      );
    }

    final controller = _controller;

    if (_isInitializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: lime),
            SizedBox(height: 18),
            Text(
              'Preparing your camera...',
              style: TextStyle(color: sage, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final previewSize = controller.value.previewSize;

    if (previewSize == null) {
      return const Center(child: CircularProgressIndicator(color: lime));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewWidth = previewSize.height;
        final previewHeight = previewSize.width;

        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}

class _CameraAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _CameraAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: enabled
                  ? const Color(0xFFC6F0A5)
                  : const Color(0xFF758076),
              size: 27,
            ),

            const SizedBox(height: 6),

            Text(
              label,
              style: TextStyle(
                color: enabled
                    ? const Color(0xFFDCE9D6)
                    : const Color(0xFF758076),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC6F0A5), size: 19),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFDCE9D6),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _CameraPlaceholder({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFC6F0A5), size: 45),

            const SizedBox(height: 15),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFDCE9D6),
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Color(0xFFC6F0A5),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC6F0A5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const corner = 26.0;
    const radius = 18.0;

    final path = Path()
      // TOP LEFT
      ..moveTo(0, corner)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(corner, 0)
      // TOP RIGHT
      ..moveTo(size.width - corner, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, corner)
      // BOTTOM LEFT
      ..moveTo(0, size.height - corner)
      ..lineTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(corner, size.height)
      // BOTTOM RIGHT
      ..moveTo(size.width - corner, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width,
        size.height - radius,
      )
      ..lineTo(size.width, size.height - corner);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
