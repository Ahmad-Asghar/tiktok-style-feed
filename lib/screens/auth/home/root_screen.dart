import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/utils/app_colors.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';


List<IconData> icons = [
  Icons.home_rounded,
  Icons.person_rounded,
];

List<Widget> screens = [
  const HomeScreen(),
  const ProfileScreen(),
];


class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RootProvider>(
      builder: (context, rootProvider, child) {
        return Scaffold(
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: screens[rootProvider.currentIndex],
              ),
              Padding(
                padding: EdgeInsets.only(left: 6.w, right: 6.w, bottom: 2.h),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 3)
                      ]),
                  height: 7.h,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(icons.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          context.read<RootProvider>().switchScreen(index);
                        },
                        child: CircleAvatar(
                          backgroundColor: index == rootProvider.currentIndex
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          child: Icon(
                            icons[index],
                            color: index == rootProvider.currentIndex
                                ? AppColors.white
                                : Colors.grey,
                            size: index == rootProvider.currentIndex ? 20 : 22,
                          ),
                        ),
                      );
                    }),
                  ),

                ),
              )
            ],
          ),
        );
      },
    );
  }
}



class RootProvider with ChangeNotifier {
  int _currentIndex = 1;

  int get currentIndex => _currentIndex;

  void switchScreen(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
