import 'package:flutter/material.dart';

/// In-App Media Player Widget for audio and video media files.
class MediaPlayerWidget extends StatefulWidget {
  final String fileUrl;
  final String? localFilePath;
  final String fileName;
  final bool isAudio;

  const MediaPlayerWidget({
    super.key,
    required this.fileUrl,
    this.localFilePath,
    required this.fileName,
    this.isAudio = false,
  });

  @override
  State<MediaPlayerWidget> createState() => _MediaPlayerWidgetState();
}

class _MediaPlayerWidgetState extends State<MediaPlayerWidget> {
  bool _isPlaying = false;
  double _currentSeconds = 0;
  final double _totalSeconds = 120.0; // Simulated timeline

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
  }

  String _formatDuration(double seconds) {
    final s = seconds.toInt();
    final mins = s ~/ 60;
    final remSecs = s % 60;
    return '${mins.toString().padLeft(2, '0')}:${remSecs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFF0B1120);

    return Container(
      color: bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Media Icon / Visualizer
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (widget.isAudio ? const Color(0xFFEC4899) : const Color(0xFF0284C7)).withValues(alpha: 0.18),
                  border: Border.all(
                    color: (widget.isAudio ? const Color(0xFFEC4899) : const Color(0xFF0284C7)).withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  widget.isAudio ? Icons.graphic_eq_rounded : Icons.play_circle_fill_rounded,
                  size: 48,
                  color: widget.isAudio ? const Color(0xFFEC4899) : const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                widget.fileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                widget.isAudio ? 'Audio Recording' : 'Video Clip',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 28),

              // Seek bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: widget.isAudio ? const Color(0xFFEC4899) : const Color(0xFF0284C7),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  trackHeight: 3,
                ),
                child: Slider(
                  value: _currentSeconds,
                  min: 0,
                  max: _totalSeconds,
                  onChanged: (val) {
                    setState(() => _currentSeconds = val);
                  },
                ),
              ),

              // Time labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_currentSeconds), style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    Text(_formatDuration(_totalSeconds), style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Controls: Play / Pause
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 28),
                    onPressed: () {
                      setState(() {
                        _currentSeconds = (_currentSeconds - 10).clamp(0, _totalSeconds);
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    backgroundColor: widget.isAudio ? const Color(0xFFEC4899) : const Color(0xFF0284C7),
                    elevation: 4,
                    onPressed: _togglePlay,
                    child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 28),
                    onPressed: () {
                      setState(() {
                        _currentSeconds = (_currentSeconds + 10).clamp(0, _totalSeconds);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
