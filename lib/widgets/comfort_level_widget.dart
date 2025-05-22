import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../controller/home_controller.dart';
import '../utils/app_color.dart';

class ComfortLevelWidget extends StatelessWidget {
  const ComfortLevelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final weatherDataCurrent = controller.weatherData.value.current?.current;

    return Column(
      children: [
        Text("Comfort Level", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        SleekCircularSlider(
          min: 0,
          max: 100,
          initialValue: weatherDataCurrent?.humidity?.toDouble() ?? 0.0,
          appearance: CircularSliderAppearance(
            size: 140,
            customWidths: CustomSliderWidths(
              handlerSize: 0,
              trackWidth: 12,
              progressBarWidth: 12,
            ),
            infoProperties: InfoProperties(
              bottomLabelText: "Humidity",
              mainLabelStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColor.secondaryText,
                  ),
              bottomLabelStyle: Theme.of(context).textTheme.labelLarge,
            ),
            animationEnabled: true,
            customColors: CustomSliderColors(
              hideShadow: true,
              trackColor: AppColor.firstGradientColor.withAlpha(100),
              progressBarColors: [
                AppColor.firstGradientColor,
                AppColor.secondGradientColor
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Feels Like: ${weatherDataCurrent?.feelsLike ?? 0}°",
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(width: 30),
            Text("UV Index: ${weatherDataCurrent?.uvIndex ?? 0}",
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}
