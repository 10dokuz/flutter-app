import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/settings/settings_cubit.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  State<IntroSliderScreen> createState() => _IntroSliderScreenState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen>
    with TickerProviderStateMixin {
  int sliderIndex = 0;

  late AnimationController buttonController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late Animation<double> buttonSqueezeAnimation =
  Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: buttonController,
      curve: Curves.easeInOut,
    ),
  );

  late final List<({String image, String title, String desc})> slideList = [
    (
    image: Assets.onboardingA,
    title: context.tr('title1')!,
    desc: context.tr('description1')!,
    ),
    (
    image: Assets.onboardingB,
    title: context.tr('title2')!,
    desc: context.tr('description2')!,
    ),
    (
    image: Assets.onboardingC,
    title: context.tr('title3')!,
    desc: context.tr('description3')!,
    ),
  ];

  @override
  void initState() {
    super.initState();
    buttonController.forward();
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) => setState(() {
    sliderIndex = index;
  });

  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        slideList.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 10,
          width: sliderIndex == index ? 24 : 10,
          decoration: BoxDecoration(
            color: sliderIndex == index
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSlider() {
    return PageView.builder(
      physics: const BouncingScrollPhysics(),
      onPageChanged: onPageChanged,
      itemCount: slideList.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: context.height * 0.4,
              alignment: Alignment.center,
              child: QImage(imageUrl: slideList[index].image),
            ),
            SizedBox(height: context.height * .02),
            Text(
              slideList[index].title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.height * .02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.width * .1),
              child: Text(
                slideList[index].desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildIntroSlider()),
              _buildPageIndicator(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<SettingsCubit>().changeShowIntroSlider();
                  Navigator.of(context).pushReplacementNamed(Routes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  elevation: 5,
                ),
                child: Text(
                  context.tr('getStarted')!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: context.height * 0.08),
            ],
          ),
        ],
      ),
    );
  }
}
