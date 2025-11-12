import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:n_back/constants/colors.dart';
import 'package:n_back/viewmodel/play_viewmodel.dart';
import 'package:n_back/viewmodel/auth_viewmodel.dart';

class NBackGamePage extends StatefulWidget {
  const NBackGamePage({super.key});

  @override
  State<NBackGamePage> createState() => _NBackGamePageState();
}

class _NBackGamePageState extends State<NBackGamePage> {
  @override
  void initState() {
    super.initState();
    // Refresh settings when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayViewModel>().refreshSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayViewModel>(
      builder: (context, playViewModel, _) {
        if (playViewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final mediaQuery = MediaQuery.of(context);
        final h = mediaQuery.size.height;
        final w = mediaQuery.size.width;
        final isMobile = w < 600;
        final isTablet = w >= 600 && w < 1200;

        return Scaffold(
          backgroundColor: blue,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/leaderboard');
              },
              icon: Icon(Icons.leaderboard, color: Colors.white),
            ),
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: blue,
            title: Text(
              'N-Back Game',
              style: TextStyle(
                fontSize: isMobile
                    ? h * 0.03
                    : isTablet
                    ? h * 0.05
                    : h * 0.07,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pos Hits: ${playViewModel.posHits}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Audio Hits: ${playViewModel.audioHits}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Round: ${playViewModel.seqIndex < 0 ? 0 : playViewModel.seqIndex + 1}/${PlayViewModel.numTrials}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      padding: const EdgeInsets.all(16),
                      crossAxisCount: playViewModel.gridSize,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: List.generate(
                        playViewModel.totalCells,
                        (index) =>
                            _buildGridTile(context, playViewModel, index),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.green,
                              ),
                            ),
                            onPressed: playViewModel.playing
                                ? null
                                : () => playViewModel.startSession(),
                            child: const Text('Start'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.red,
                              ),
                            ),
                            onPressed: playViewModel.playing
                                ? () => playViewModel.stopSession()
                                : null,
                            child: const Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildControls(playViewModel),
                  const SizedBox(height: 12),
                ],
              ),
              if (playViewModel.preStartCountdown > 0)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: Center(
                      child: Text(
                        '${playViewModel.preStartCountdown}',
                        style: const TextStyle(
                          fontSize: 96,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridTile(
    BuildContext context,
    PlayViewModel playViewModel,
    int index,
  ) {
    final bool active =
        playViewModel.stimulusVisible && (playViewModel.currentPos == index);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: active ? pink : purple,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: pink, width: 2),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: Colors.transparent,
            fontWeight: FontWeight.bold,
            fontSize: (playViewModel.gridSize == 3) ? 24 : 18,
          ),
        ),
      ),
    );
  }

  Widget _buildControls(PlayViewModel playViewModel) {
    final bool posEnabled =
        playViewModel.stimulusVisible && playViewModel.playing;
    final bool audioEnabled =
        (playViewModel.stimuliValue == 2) &&
        playViewModel.stimulusVisible &&
        playViewModel.playing;

    final Color defaultFg = Colors.white;
    final Color defaultBg = pink;
    final Color pressedFg = Colors.white;
    final Color pressedBg = Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  playViewModel.pressedPosThisStim ? pressedFg : defaultFg,
                ),
                backgroundColor: WidgetStatePropertyAll(
                  playViewModel.pressedPosThisStim ? pressedBg : defaultBg,
                ),
              ),
              onPressed: posEnabled
                  ? () => playViewModel.onPressPosition()
                  : null,
              child: const Text('Position'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  playViewModel.pressedAudioThisStim ? pressedFg : defaultFg,
                ),
                backgroundColor: WidgetStatePropertyAll(
                  playViewModel.pressedAudioThisStim ? pressedBg : defaultBg,
                ),
              ),
              onPressed: audioEnabled
                  ? () => playViewModel.onPressAudio()
                  : null,
              child: const Text('Audio'),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authViewModel = context.read<AuthViewModel>();
              await authViewModel.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/signin');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
