import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:n_back/constants/colors.dart';
import 'package:n_back/viewmodel/leaderboard_viewmodel.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh leaderboard when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardViewModel>().loadAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardViewModel>(
      builder: (context, leaderboardViewModel, _) {
        final mediaQuery = MediaQuery.of(context);
        final h = mediaQuery.size.height;
        final w = mediaQuery.size.width;
        final isMobile = w < 600;
        final isTablet = w >= 600 && w < 1200;

        return Scaffold(
          backgroundColor: blue,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: Colors.white),
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
          ),
          body: leaderboardViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ListView.builder(
                    itemCount: leaderboardViewModel.allUsers.length,
                    itemBuilder: (context, index) {
                      final user = leaderboardViewModel.allUsers[index];

                      // Name & email fallbacks
                      final name = user.name.isEmpty ? 'No Name' : user.name;
                      final email = user.email.isEmpty
                          ? 'No Email'
                          : user.email;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: h * 0.01,
                          horizontal: w * 0.03,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(email),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Pos: ${user.bestPosHits}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Audio: ${user.bestAudioHits}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(w * 0.02),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: w * 0.03,
                            vertical: h * 0.01,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
