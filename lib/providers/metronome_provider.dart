import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MetronomeState {
  final int repSeconds;
  final int totalSets;
  final int restSeconds;
  final int currentSet;   // 1-based
  final bool isResting;
  final int phaseSeconds; // duration of current phase (set or rest)
  final int remainingSeconds;
  final bool isRunning;
  final bool isFinished;

  const MetronomeState({
    required this.repSeconds,
    required this.totalSets,
    required this.restSeconds,
    required this.currentSet,
    required this.isResting,
    required this.phaseSeconds,
    required this.remainingSeconds,
    required this.isRunning,
    required this.isFinished,
  });

  factory MetronomeState.idle() => const MetronomeState(
        repSeconds: 0,
        totalSets: 1,
        restSeconds: 0,
        currentSet: 1,
        isResting: false,
        phaseSeconds: 0,
        remainingSeconds: 0,
        isRunning: false,
        isFinished: false,
      );

  bool get isIdle => repSeconds == 0 && !isRunning && !isFinished;

  double get progress =>
      phaseSeconds > 0 ? (phaseSeconds - remainingSeconds) / phaseSeconds : 0;

  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  MetronomeState copyWith({
    int? repSeconds,
    int? totalSets,
    int? restSeconds,
    int? currentSet,
    bool? isResting,
    int? phaseSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isFinished,
  }) =>
      MetronomeState(
        repSeconds: repSeconds ?? this.repSeconds,
        totalSets: totalSets ?? this.totalSets,
        restSeconds: restSeconds ?? this.restSeconds,
        currentSet: currentSet ?? this.currentSet,
        isResting: isResting ?? this.isResting,
        phaseSeconds: phaseSeconds ?? this.phaseSeconds,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        isRunning: isRunning ?? this.isRunning,
        isFinished: isFinished ?? this.isFinished,
      );
}

final metronomeProvider =
    NotifierProvider.autoDispose<MetronomeNotifier, MetronomeState>(
        () => MetronomeNotifier());

class MetronomeNotifier extends Notifier<MetronomeState> {
  Timer? _countdownTimer;
  Timer? _metronomeTimer;
  int _bpm = 0;

  final List<AudioPlayer> _players = [];
  int _playerIndex = 0;
  bool _audioReady = false;
  Future<void>? _initFuture;

  @override
  MetronomeState build() {
    ref.onDispose(_disposeAll);
    _initFuture = _initAudio();
    return MetronomeState.idle();
  }

  Future<void> _initAudio() async {
    try {
      for (int i = 0; i < 2; i++) {
        final p = AudioPlayer();
        // Low-latency mode is backed by SoundPool (Android) / a comparable
        // low-overhead path on other platforms, giving consistent timing for
        // rapid, repeated short clips. The default mode (MediaPlayer/ExoPlayer)
        // has variable per-play startup latency, which caused audible jitter
        // between beats.
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setVolume(1.0);
        await p.setSource(AssetSource('audio/tick.wav'));
        _players.add(p);
      }
      _audioReady = true;
    } catch (_) {
      _audioReady = false;
    }
  }

  void _tick() {
    if (!_audioReady || _players.isEmpty) return;
    final player = _players[_playerIndex % _players.length];
    _playerIndex++;
    // Guard against resume() being called after _disposeAll clears _audioReady.
    player.stop().then((_) { if (_audioReady) player.resume(); });
  }

  Future<void> start(int repSeconds, int totalSets, int restSeconds, int bpm) async {
    await _initFuture;
    _cancelTimers();
    _bpm = bpm;
    _enableWakelock();
    state = MetronomeState(
      repSeconds: repSeconds,
      totalSets: totalSets,
      restSeconds: restSeconds,
      currentSet: 1,
      isResting: false,
      phaseSeconds: repSeconds,
      remainingSeconds: repSeconds,
      isRunning: true,
      isFinished: false,
    );
    _startPhaseCountdown(repSeconds, bpm);
  }

  void _startPhaseCountdown(int seconds, int bpm) {
    _cancelTimers();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.remainingSeconds - 1;
      if (remaining <= 0) {
        _onPhaseComplete();
      } else {
        state = state.copyWith(remainingSeconds: remaining);
      }
    });

    if (bpm > 0) {
      _tick();
      final interval = Duration(milliseconds: (60000 / bpm).round());
      _metronomeTimer = Timer.periodic(interval, (_) => _tick());
    }
  }

  void _onPhaseComplete() {
    _cancelTimers();

    if (state.isResting) {
      // Rest done → start next set
      final nextSet = state.currentSet + 1;
      state = state.copyWith(
        currentSet: nextSet,
        isResting: false,
        phaseSeconds: state.repSeconds,
        remainingSeconds: state.repSeconds,
        isRunning: true,
      );
      _startPhaseCountdown(state.repSeconds, _bpm);
    } else if (state.currentSet >= state.totalSets) {
      // Last set done → finished
      _disableWakelock();
      state = state.copyWith(
        remainingSeconds: 0,
        isRunning: false,
        isFinished: true,
      );
    } else if (state.restSeconds > 0) {
      // Set done, rest before next
      state = state.copyWith(
        isResting: true,
        phaseSeconds: state.restSeconds,
        remainingSeconds: state.restSeconds,
        isRunning: true,
      );
      _startPhaseCountdown(state.restSeconds, 0); // no metronome during rest
    } else {
      // Set done, no rest → next set immediately
      final nextSet = state.currentSet + 1;
      state = state.copyWith(
        currentSet: nextSet,
        isResting: false,
        phaseSeconds: state.repSeconds,
        remainingSeconds: state.repSeconds,
        isRunning: true,
      );
      _startPhaseCountdown(state.repSeconds, _bpm);
    }
  }

  void pause() {
    _cancelTimers();
    _disableWakelock();
    state = state.copyWith(isRunning: false);
  }

  void resume(int bpm) {
    if (state.isFinished || state.remainingSeconds <= 0) return;
    _bpm = bpm;
    _enableWakelock();
    state = state.copyWith(isRunning: true);
    _startPhaseCountdown(
        state.remainingSeconds, state.isResting ? 0 : bpm);
  }

  void reset() {
    _cancelTimers();
    state = MetronomeState.idle();
  }

  void _enableWakelock() {
    try { WakelockPlus.enable(); } catch (_) {}
  }

  void _disableWakelock() {
    try { WakelockPlus.disable(); } catch (_) {}
  }

  void handleAppLifecycle(bool active) {
    if (!active && state.isRunning) pause();
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _metronomeTimer?.cancel();
    _countdownTimer = null;
    _metronomeTimer = null;
  }

  void _disposeAll() {
    _cancelTimers();
    _disableWakelock();
    for (final p in _players) {
      p.dispose();
    }
    _players.clear();
    _audioReady = false;
  }
}
