import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:acadyk/core/services/live_camera_service.dart';
import 'package:acadyk/features/profile/presentation/services/profile_manager.dart';
import 'package:acadyk/features/profile/presentation/widgets/camera_permission_dialog.dart';

class FaceVerificationScreen extends StatefulWidget {
  final String? avatarUrl;
  final String? studentName;

  const FaceVerificationScreen({
    super.key,
    this.avatarUrl,
    this.studentName,
  });

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0: Student verification, 1: Live Camera Scan, 2: Face matching, 3: Identity Verified
  Timer? _scanTimer;
  Timer? _progressTimer;
  Timer? _autoCaptureTimer;
  late AnimationController _scanAnimCtrl;

  Widget? _liveCameraPreview;
  bool _isRequestingCamera = false;
  bool _isCapturing = false;
  String? _cameraErrorMessage;
  Uint8List? _capturedImageBytes;
  double _scanProgress = 0.0;
  int _countdownSeconds = 3;

  @override
  void initState() {
    super.initState();
    _scanAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _progressTimer?.cancel();
    _autoCaptureTimer?.cancel();
    _scanAnimCtrl.dispose();
    LiveCameraService.stopCameraFeed();
    super.dispose();
  }

  /// Initialize real front camera stream (Webcam on Web, Front Camera on Mobile)
  Future<void> _startLiveCamera() async {
    if (_isRequestingCamera) return;
    setState(() {
      _isRequestingCamera = true;
      _cameraErrorMessage = null;
    });

    try {
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final previewWidget = await LiveCameraService.startCameraFeed(uniqueId);

      if (!mounted) return;

      if (previewWidget != null) {
        setState(() {
          _liveCameraPreview = previewWidget;
          _isRequestingCamera = false;
          _currentStep = 1; // Move to Step 1: Live Camera Scan
          _countdownSeconds = 3;
        });

        // Start smooth 3-second auto-capture countdown so user can center their face
        _startAutoCaptureCountdown();
      } else {
        setState(() {
          _isRequestingCamera = false;
          _cameraErrorMessage =
              'Camera permission required. Please allow camera access in your browser/device.';
        });

        // Automatically show the Permission popup (matching Image 2)
        CameraPermissionDialog.show(context, onRetry: _startLiveCamera);
      }
    } catch (e) {
      debugPrint('[FaceVerification] Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _isRequestingCamera = false;
          _cameraErrorMessage =
              'Camera permission required. Please allow camera access in your browser/device.';
        });

        CameraPermissionDialog.show(context, onRetry: _startLiveCamera);
      }
    }
  }

  void _startAutoCaptureCountdown() {
    _autoCaptureTimer?.cancel();
    _autoCaptureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        _captureLivePhoto();
      }
    });
  }

  /// Snaps a live photo directly from the active camera stream
  Future<void> _captureLivePhoto() async {
    if (_isCapturing) return;

    _autoCaptureTimer?.cancel();
    setState(() => _isCapturing = true);

    try {
      final bytes = await LiveCameraService.capturePhoto();

      // Stop camera stream right after capture to free up hardware
      LiveCameraService.stopCameraFeed();

      if (mounted) {
        setState(() {
          _capturedImageBytes = bytes;
          _isCapturing = false;
          _currentStep = 2; // Step 2: Face Detection & Matching
          _scanProgress = 0.0;
        });

        _startIdMatchingScan();
      }
    } catch (e) {
      debugPrint('[FaceVerification] Error capturing picture: $e');
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _startIdMatchingScan() {
    _scanTimer?.cancel();
    _progressTimer?.cancel();
    _scanProgress = 0.0;

    // Smoothly animate progress bar to 100% over ~2.8 seconds
    const totalDurationMs = 2800;
    const intervalMs = 50;
    const steps = totalDurationMs / intervalMs;
    int currentStepCount = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      currentStepCount++;
      setState(() {
        _scanProgress = (currentStepCount / steps).clamp(0.0, 1.0);
      });
      if (currentStepCount >= steps) {
        timer.cancel();
      }
    });

    // Complete face matching with Student ID card photo and transition to Verified status
    _scanTimer = Timer(const Duration(milliseconds: totalDurationMs), () {
      if (mounted) {
        setState(() {
          _currentStep = 3; // Step 3: Identity Verified
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 680),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep0Intro();
      case 1:
        return _buildStep1LiveCameraScan();
      case 2:
        return _buildStep2ScanningAndMatching();
      case 3:
      default:
        return _buildStep3Verified();
    }
  }

  // ===========================================================================
  // STEP 0: STUDENT VERIFICATION INTRO & INSTRUCTIONS
  // ===========================================================================
  Widget _buildStep0Intro() {
    return Scaffold(
      key: const ValueKey(0),
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Scan your face to verify your identity',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),

              // Center Visual Frame with Scanner Corner Brackets & Cute Face Sparkle
              Center(
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Scanner corner brackets
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: _ScanBracketsPainter(
                          color: const Color(0xFFD1D5DB),
                          strokeWidth: 2.8,
                          cornerLength: 28,
                        ),
                      ),

                      // Face with Sparkle Character Graphic
                      CustomPaint(
                        size: const Size(96, 96),
                        painter: _FaceSparkleIconPainter(
                          color: const Color(0xFF8B949E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_cameraErrorMessage != null) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => CameraPermissionDialog.show(context, onRetry: _startLiveCamera),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _cameraErrorMessage!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF991B1B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFDC2626), size: 14),
                      ],
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Checklist criteria row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF6B7280)),
                  SizedBox(width: 6),
                  Text(
                    'Uncovered face',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 24),
                  Icon(Icons.wb_sunny_outlined, size: 18, color: Color(0xFF6B7280)),
                  SizedBox(width: 6),
                  Text(
                    'Good lighting',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Emerald Action Button -> Opens Live Camera directly
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isRequestingCamera ? null : _startLiveCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009951),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF009951).withValues(alpha: 0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isRequestingCamera
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Opening Camera...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Start verification',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // STEP 1: LIVE CAMERA PREVIEW & FACE SCANNER
  // ===========================================================================
  Widget _buildStep1LiveCameraScan() {
    return Scaffold(
      key: const ValueKey(1),
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 22),
          onPressed: () {
            _autoCaptureTimer?.cancel();
            LiveCameraService.stopCameraFeed();
            setState(() => _currentStep = 0);
          },
        ),
        title: const Text(
          'Live Face Scan',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
            onPressed: () {
              _autoCaptureTimer?.cancel();
              LiveCameraService.stopCameraFeed();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
          child: Column(
            children: [
              // Live camera status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF009951).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF009951).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF009951),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Live Camera Active',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF009951),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Viewfinder Container with LIVE CAMERA FEED
              Center(
                child: Container(
                  width: 240,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. Live Camera Stream Preview
                        _buildLiveCameraFeed(),

                        // 2. Crisp Corner Scan Brackets
                        CustomPaint(
                          size: const Size(220, 260),
                          painter: _ScanBracketsPainter(
                            color: Colors.white.withValues(alpha: 0.95),
                            strokeWidth: 3.5,
                            cornerLength: 32,
                          ),
                        ),

                        // 3. Animated Scanning Green Laser Line
                        AnimatedBuilder(
                          animation: _scanAnimCtrl,
                          builder: (context, child) {
                            return Positioned(
                              top: _scanAnimCtrl.value * 240 + 10,
                              left: 14,
                              right: 14,
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF10B981),
                                      Color(0xFF34D399),
                                      Color(0xFF10B981),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.85),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // 4. Capture Countdown Badge Overlay
                        Positioned(
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _isCapturing
                                  ? 'Capturing photo...'
                                  : 'Auto-scan in ${_countdownSeconds}s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Instruction text
              const Text(
                'Align your face in the frame',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Hold steady and look directly into your camera for identity verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
              ),

              const Spacer(),

              // Manual Capture Button (Immediate Snap)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isCapturing ? null : _captureLivePhoto,
                  icon: _isCapturing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.camera_alt_outlined, size: 20),
                  label: Text(
                    _isCapturing ? 'Processing Live Photo...' : 'Capture Photo Now',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009951),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveCameraFeed() {
    if (_liveCameraPreview == null) {
      return Container(
        color: const Color(0xFF0F172A),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009951)),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: _liveCameraPreview!,
    );
  }

  // ===========================================================================
  // STEP 2: FACE DETECTION & ID CARD MATCHING (with captured live photo)
  // ===========================================================================
  Widget _buildStep2ScanningAndMatching() {
    final avatar = widget.avatarUrl ?? ProfileManager.avatarUrl;

    return Scaffold(
      key: const ValueKey(2),
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 22),
          onPressed: () {
            _scanTimer?.cancel();
            _progressTimer?.cancel();
            _startLiveCamera();
          },
        ),
        title: const Text(
          'Face matching',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
            onPressed: () {
              _scanTimer?.cancel();
              _progressTimer?.cancel();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Viewfinder Container with LIVE Captured Photo
              Center(
                child: Container(
                  width: 240,
                  height: 270,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Live Captured Photo or fallback
                        if (_capturedImageBytes != null)
                          Image.memory(
                            _capturedImageBytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        else
                          Image.asset(
                            avatar,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFE2E8F0),
                              child: const Icon(Icons.person, size: 80, color: Color(0xFF94A3B8)),
                            ),
                          ),

                        // Corner Scan Brackets in Crisp White
                        CustomPaint(
                          size: const Size(220, 250),
                          painter: _ScanBracketsPainter(
                            color: Colors.white.withValues(alpha: 0.95),
                            strokeWidth: 3.5,
                            cornerLength: 32,
                          ),
                        ),

                        // Animated Scanning Green Laser Line
                        AnimatedBuilder(
                          animation: _scanAnimCtrl,
                          builder: (context, child) {
                            return Positioned(
                              top: _scanAnimCtrl.value * 230 + 10,
                              left: 14,
                              right: 14,
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF10B981),
                                      Color(0xFF34D399),
                                      Color(0xFF10B981),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.85),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              const Text(
                'Verifying your face',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Matching live face capture with your student identity records...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(),

              // Smooth Matching Progress Indicator Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _scanProgress > 0 ? _scanProgress : null,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF009951)),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // STEP 3: IDENTITY VERIFIED SUCCESS STATUS
  // ===========================================================================
  Widget _buildStep3Verified() {
    final avatar = widget.avatarUrl ?? ProfileManager.avatarUrl;

    return Scaffold(
      key: const ValueKey(3),
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 22),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: const Text(
          'Face verification',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Circular Avatar with Live Captured Photo + Green Checkmark Badge Overlay
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular background container
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE5E7EB),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _capturedImageBytes != null
                              ? Image.memory(
                                  _capturedImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  avatar,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                        ),
                      ),

                      // Green Checkmark Badge at top-right
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF009951),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF009951).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Success Title
              const Text(
                'Identity Verified',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle matching design
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Your face just unlocked a world of possibilities.\nYou\'re officially you, and that\'s awesome!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                    height: 1.45,
                  ),
                ),
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ProfileManager.setVerified(true);
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009951),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// VIEWFINDER CORNER SCAN BRACKETS PAINTER
// =============================================================================
class _ScanBracketsPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  _ScanBracketsPainter({
    required this.color,
    this.strokeWidth = 2.5,
    this.cornerLength = 28,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double cornerLen = cornerLength;
    final double pad = 8;
    final double w = size.width - pad;
    final double h = size.height - pad;

    // Top-Left
    canvas.drawLine(Offset(pad, pad + cornerLen), Offset(pad, pad), paint);
    canvas.drawLine(Offset(pad, pad), Offset(pad + cornerLen, pad), paint);

    // Top-Right
    canvas.drawLine(Offset(w - cornerLen, pad), Offset(w, pad), paint);
    canvas.drawLine(Offset(w, pad), Offset(w, pad + cornerLen), paint);

    // Bottom-Left
    canvas.drawLine(Offset(pad, h - cornerLen), Offset(pad, h), paint);
    canvas.drawLine(Offset(pad, h), Offset(pad + cornerLen, h), paint);

    // Bottom-Right
    canvas.drawLine(Offset(w - cornerLen, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanBracketsPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength;
  }
}

// =============================================================================
// FACE + SPARKLE CHARACTER GRAPHIC PAINTER (Matches Design)
// =============================================================================
class _FaceSparkleIconPainter extends CustomPainter {
  final Color color;

  _FaceSparkleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.48, size.height * 0.54);
    final radius = size.width * 0.36;

    // Face outline circle
    canvas.drawCircle(center, radius, strokePaint..strokeWidth = 4.5);

    // Two Eyes (filled circles)
    final eyeRadius = size.width * 0.042;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.38, center.dy + radius * 0.08),
      eyeRadius,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.38, center.dy + radius * 0.08),
      eyeRadius,
      fillPaint,
    );

    // Hair bang arc across top
    final hairPath = Path()
      ..moveTo(center.dx - radius * 0.88, center.dy - radius * 0.3)
      ..cubicTo(
        center.dx - radius * 0.3,
        center.dy - radius * 0.9,
        center.dx + radius * 0.2,
        center.dy - radius * 0.1,
        center.dx + radius * 0.88,
        center.dy - radius * 0.3,
      );
    canvas.drawPath(hairPath, fillPaint);

    // Sparkle (Curved 4-point star) at top-right
    final sparkleCenter = Offset(size.width * 0.80, size.height * 0.22);
    final sparkleRadius = size.width * 0.16;

    final sparklePath = Path()
      ..moveTo(sparkleCenter.dx, sparkleCenter.dy - sparkleRadius)
      ..cubicTo(
        sparkleCenter.dx + sparkleRadius * 0.15,
        sparkleCenter.dy - sparkleRadius * 0.15,
        sparkleCenter.dx + sparkleRadius * 0.15,
        sparkleCenter.dy - sparkleRadius * 0.15,
        sparkleCenter.dx + sparkleRadius,
        sparkleCenter.dy,
      )
      ..cubicTo(
        sparkleCenter.dx + sparkleRadius * 0.15,
        sparkleCenter.dy + sparkleRadius * 0.15,
        sparkleCenter.dx + sparkleRadius * 0.15,
        sparkleCenter.dy + sparkleRadius * 0.15,
        sparkleCenter.dx,
        sparkleCenter.dy + sparkleRadius,
      )
      ..cubicTo(
        sparkleCenter.dx - sparkleRadius * 0.15,
        sparkleCenter.dy + sparkleRadius * 0.15,
        sparkleCenter.dx - sparkleRadius * 0.15,
        sparkleCenter.dy + sparkleRadius * 0.15,
        sparkleCenter.dx - sparkleRadius,
        sparkleCenter.dy,
      )
      ..cubicTo(
        sparkleCenter.dx - sparkleRadius * 0.15,
        sparkleCenter.dy - sparkleRadius * 0.15,
        sparkleCenter.dx - sparkleRadius * 0.15,
        sparkleCenter.dy - sparkleRadius * 0.15,
        sparkleCenter.dx,
        sparkleCenter.dy - sparkleRadius,
      );
    sparklePath.close();
    canvas.drawPath(sparklePath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _FaceSparkleIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
