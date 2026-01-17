import 'package:flutter/material.dart';
import 'package:plezy/widgets/app_icon.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../mpv/mpv.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/formatters.dart';

/// Reusable widget for adjusting sync offsets (audio or subtitle)
class SyncOffsetControl extends StatefulWidget {
  final Player player;
  final String propertyName; // 'audio-delay' or 'sub-delay'
  final int initialOffset;
  final String labelText; // 'Audio' or 'Subtitles'
  final Future<void> Function(int offset) onOffsetChanged;

  const SyncOffsetControl({
    super.key,
    required this.player,
    required this.propertyName,
    required this.initialOffset,
    required this.labelText,
    required this.onOffsetChanged,
  });

  @override
  State<SyncOffsetControl> createState() => _SyncOffsetControlState();
}

class _SyncOffsetControlState extends State<SyncOffsetControl> {
  late double _currentOffset;

  @override
  void initState() {
    super.initState();
    _currentOffset = widget.initialOffset.toDouble();
  }

  @override
  void didUpdateWidget(SyncOffsetControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialOffset != oldWidget.initialOffset) {
      setState(() {
        _currentOffset = widget.initialOffset.toDouble();
      });
    }
  }

  Future<void> _applyOffset(double offsetMs) async {
    // Convert milliseconds to seconds for mpv
    final offsetSeconds = offsetMs / 1000.0;

    // Apply to player using setProperty
    await widget.player.setProperty(widget.propertyName, offsetSeconds.toString());

    // Notify parent and save to settings
    await widget.onOffsetChanged(offsetMs.round());
  }

  void _resetOffset() {
    setState(() {
      _currentOffset = 0;
    });
    _applyOffset(0);
  }

  String _getDescriptionText() {
    if (_currentOffset > 0) {
      return t.videoControls.playsLater(label: widget.labelText);
    } else if (_currentOffset < 0) {
      return t.videoControls.playsEarlier(label: widget.labelText);
    } else {
      return t.videoControls.noOffset;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Current offset display

          // Slider
          Text(
            formatSyncOffset(_currentOffset),
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),

          Text(_getDescriptionText(), style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 4),
          // Step adjustment buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _applyOffset(_currentOffset - 100),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(t.videoControls.minusTime(amount: "100", unit: "ms")),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _applyOffset(_currentOffset - 50),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(t.videoControls.minusTime(amount: "50", unit: "ms")),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _applyOffset(_currentOffset + 50),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(t.videoControls.addTime(amount: "50", unit: "ms")),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _applyOffset(_currentOffset + 100),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(t.videoControls.addTime(amount: "100", unit: "ms")),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Reset button
          ElevatedButton.icon(
            onPressed: _currentOffset != 0 ? _resetOffset : null,
            icon: const AppIcon(Symbols.restart_alt_rounded, fill: 1),
            label: Text(t.videoControls.resetToZero),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[850],
              disabledForegroundColor: Colors.white38,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
