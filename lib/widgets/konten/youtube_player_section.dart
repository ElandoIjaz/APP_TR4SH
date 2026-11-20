import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:test23/core/app_colors.dart';

class YoutubePlayerSection extends StatefulWidget {
  final String mediaUrl;

  const YoutubePlayerSection({super.key, required this.mediaUrl});

  @override
  State<YoutubePlayerSection> createState() => _YoutubePlayerSectionState();
}

class _YoutubePlayerSectionState extends State<YoutubePlayerSection> {
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _initController(widget.mediaUrl);
  }

  void _initController(String url) {
    final videoId = YoutubePlayerController.convertUrlToId(url);
    if (videoId == null || videoId.isEmpty) {
      _ytController = null;
      return;
    }

    _ytController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant YoutubePlayerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaUrl != widget.mediaUrl) {
      final newVideoId =
          YoutubePlayerController.convertUrlToId(widget.mediaUrl);
      if (newVideoId != null && newVideoId.isNotEmpty) {
        if (_ytController != null) {
          _ytController!.loadVideoById(videoId: newVideoId);
        } else {
          setState(() => _initController(widget.mediaUrl));
        }
      } else {
        _ytController?.close();
        setState(() => _ytController = null);
      }
    }
  }

  @override
  void dispose() {
    _ytController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _ytController;
    if (controller == null) {
      return Container(
        width: double.infinity,
        height: 170,
        decoration: BoxDecoration(
          color: AppColors.darkGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.videocam_rounded, size: 40, color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: YoutubePlayer(
        controller: controller,
        aspectRatio: 16 / 9,
      ),
    );
  }
}