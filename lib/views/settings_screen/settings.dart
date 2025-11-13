import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:n_back/constants/colors.dart';
import 'package:n_back/viewmodel/settings_viewmodel.dart';
import 'package:n_back/viewmodel/auth_viewmodel.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsViewModel, AuthViewModel>(
      builder: (context, settingsViewModel, authViewModel, _) {
        if (settingsViewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final mediaQuery = MediaQuery.of(context);
        final h = mediaQuery.size.height;
        final w = mediaQuery.size.width;
        final isMobile = w < 600;
        final isTablet = w >= 600 && w < 1200;

        final bool stimuliBtn1 = settingsViewModel.stimuliValue == 1;
        final bool stimuliBtn2 = settingsViewModel.stimuliValue == 2;

        return Scaffold(
          backgroundColor: blue,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.white,
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
          body: Padding(
            padding: EdgeInsets.symmetric(
              vertical: h * 0.02,
              horizontal: w * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Number of Stimuli',
                  style: TextStyle(color: Colors.white, fontSize: h * 0.025),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          stimuliBtn1 ? blue : Colors.white,
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          stimuliBtn1 ? Colors.white : blue,
                        ),
                      ),
                      onPressed: () => settingsViewModel.setStimuli(1),
                      child: const Text('1'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          stimuliBtn2 ? blue : Colors.white,
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          stimuliBtn2 ? Colors.white : blue,
                        ),
                      ),
                      onPressed: () => settingsViewModel.setStimuli(2),
                      child: const Text('2'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose N',
                  style: TextStyle(color: Colors.white, fontSize: h * 0.025),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          settingsViewModel.nValue == 1 ? blue : Colors.white,
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          settingsViewModel.nValue == 1 ? Colors.white : blue,
                        ),
                      ),
                      onPressed: () => settingsViewModel.setNValue(1),
                      child: const Text('1'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          settingsViewModel.nValue == 2 ? blue : Colors.white,
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          settingsViewModel.nValue == 2 ? Colors.white : blue,
                        ),
                      ),
                      onPressed: () => settingsViewModel.setNValue(2),
                      child: const Text('2'),
                    ),
                  ],
                ),
                Text(
                  'Choose Size of Grid',
                  style: TextStyle(color: Colors.white, fontSize: h * 0.025),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          settingsViewModel.gridValue == 1
                              ? blue
                              : Colors.white,
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          settingsViewModel.gridValue == 1
                              ? Colors.white
                              : blue,
                        ),
                      ),
                      onPressed: () => settingsViewModel.setGridValue(1),
                      child: const Text('1'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          settingsViewModel.gridValue == 2
                              ? blue
                              : Colors.white,
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          settingsViewModel.gridValue == 2
                              ? Colors.white
                              : blue,
                        ),
                      ),
                      onPressed: () => settingsViewModel.setGridValue(2),
                      child: const Text('2'),
                    ),
                  ],
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: h * 0.02),
                    child: TextButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(blue),
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(h * 0.01 / 2),
                        child: Text(
                          'Save Settings',
                          style: TextStyle(color: blue, fontSize: h * 0.03),
                        ),
                      ),
                      onPressed: () async {
                        await settingsViewModel.saveAllSettings();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings saved')),
                          );
                          Navigator.pushReplacementNamed(context, '/play');
                        }
                      },
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: h * 0.02),
                    child: TextButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(blue),
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(h * 0.01 / 2),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(color: blue, fontSize: h * 0.03),
                        ),
                      ),
                      onPressed: () async {
                        await authViewModel.signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sign Out Successful!'),
                            ),
                          );
                          Navigator.pushReplacementNamed(context, '/signin');
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
