import 'package:Medito/components/components.dart';
import 'package:Medito/constants/constants.dart';
import 'package:Medito/models/models.dart';
import 'package:Medito/routes/routes.dart';
import 'package:Medito/view_model/audio_player/audio_player_viewmodel.dart';
import 'package:Medito/view_model/background_sounds/background_sounds_viewmodel.dart';
import 'package:Medito/view_model/player/audio_completion_viewmodel.dart';
import 'package:Medito/view_model/player/audio_downloader_viewmodel.dart';
import 'package:Medito/view_model/player/audio_play_pause_viewmodel.dart';
import 'package:Medito/view_model/session/session_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'components/artist_title_component.dart';
import 'components/background_image_component.dart';
import 'components/bottom_actions/bottom_action_component.dart';
import 'components/duration_indicatior_component.dart';
import 'components/player_buttons_component.dart';

class PlayerView extends ConsumerStatefulWidget {
  const PlayerView({super.key, required this.sessionModel, required this.file});
  final SessionModel sessionModel;
  final SessionFilesModel file;
  @override
  ConsumerState<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends ConsumerState<PlayerView> {
  SessionModel? downloadedSession;
  late int sessionId, fileId;
  @override
  void initState() {
    sessionId = widget.sessionModel.id;
    fileId = widget.file.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(
              getSpecificSessionsProvider(sessionId: sessionId, fileId: fileId)
                  .future)
          .then((value) {
        downloadedSession = value;
        loadSessionAndBackgroundSound();
        ref.read(audioPlayPauseStateProvider.notifier).state =
            PLAY_PAUSE_AUDIO.PLAY;
      });
    });
    super.initState();
  }

  void loadSessionAndBackgroundSound() {
    final _audioPlayerNotifier = ref.read(audioPlayerNotifierProvider);
    var isPlaying = _audioPlayerNotifier.sessionAudioPlayer.playerState.playing;
    var _currentPlayingFileId =
        _audioPlayerNotifier.currentlyPlayingSession?.id;

    if (!isPlaying || _currentPlayingFileId != fileId) {
      setSessionAudio(_audioPlayerNotifier);
      setBackgroundSound(_audioPlayerNotifier);
    }
  }

  void setSessionAudio(AudioPlayerNotifier _audioPlayerNotifier) {
    var checkDownloadedFile = ref.read(audioDownloaderProvider).getSessionAudio(
        '$sessionId-$fileId.${widget.file.path.substring(widget.file.path.lastIndexOf('.') + 1)}');
    checkDownloadedFile.then((value) {
      _audioPlayerNotifier.setSessionAudio(widget.file, filePath: value);
      _audioPlayerNotifier.currentlyPlayingSession = widget.file;
    });
  }

  void setBackgroundSound(AudioPlayerNotifier _audioPlayerNotifier) {
    if (widget.sessionModel.hasBackgroundSound) {
      final _provider = ref.read(backgroundSoundsNotifierProvider);
      _provider.getBackgroundSoundFromPref().then((_) {
        if (_provider.selectedBgSound != null) {
          _audioPlayerNotifier.setBackgroundAudio(_provider.selectedBgSound!);
        }
      });
      _provider.getVolumeFromPref().then((_) {
        _audioPlayerNotifier.setBackgroundSoundVolume(_provider.volume);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(audioCompletionProvider(widget.file.duration));
    return Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BackgroundImageComponent(imageUrl: widget.sessionModel.coverUrl),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CloseButtonComponent(
                  onPressed: () => router.pop(),
                  bgColor: ColorConstants.walterWhite,
                  icColor: ColorConstants.almostBlack,
                ),
                Spacer(),
                ArtistTitleComponent(sessionModel: widget.sessionModel),
                Spacer(),
                PlayerButtonsComponent(
                  file: widget.file,
                  sessionModel: widget.sessionModel,
                ),
                height16,
                DurationIndicatorComponent(file: widget.file),
                height16,
                BottomActionComponent(
                  sessionModel: widget.sessionModel,
                  file: widget.file,
                  isDownloaded: false,
                ),
                height16,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
