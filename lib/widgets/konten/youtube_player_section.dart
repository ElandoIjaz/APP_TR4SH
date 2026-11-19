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
  late YoutubePlayerController _ytController;
  bool _hasValidVideo = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.mediaUrl) ?? '';
    _hasValidVideo = videoId.isNotEmpty;
    if (_hasValidVideo) {
      _ytController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_hasValidVideo) {
      _ytController.dispose(); // Membersihkan memori & mencegah memory leak/lag
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidVideo) {
      return Container(
        height: 170,
        color: AppColors.darkGreen,
        child: const Center(
          child: Icon(Icons.videocam_rounded, size: 40, color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: YoutubePlayer(
        controller: _ytController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.limeAccent,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.darkGreen,
          handleColor: AppColors.limeAccent,
        ),
      ),
    );
  }
}