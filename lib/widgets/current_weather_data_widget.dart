import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../utils/app_color.dart';

class CurrentWeatherDataWidget extends StatelessWidget {
  const CurrentWeatherDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final weatherDataCurrent = controller.weatherData.value.current?.current;

    if (weatherDataCurrent == null) {
      return const Center(child: Text("No current weather data available"));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(
              height: 80,
              width: 80,
              "assets/weather/${weatherDataCurrent.weather?.firstOrNull?.icon ?? 'unknown'}.png",
              errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 50),
            ),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: "${weatherDataCurrent.temp ?? '--'}°",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                TextSpan(
                  text: weatherDataCurrent.weather?.firstOrNull?.description ?? "N/A",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColor.secondaryText),
                ),
              ]),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMoreDetailsWidget(
              context: context,
              imageUrl: "assets/icons/windspeed.png",
              data: "${weatherDataCurrent.windSpeed ?? '--'} km/h",
            ),
            _buildMoreDetailsWidget(
              context: context,
              imageUrl: "assets/icons/clouds.png",
              data: "${weatherDataCurrent.clouds ?? '--'}%",
            ),
            _buildMoreDetailsWidget(
              context: context,
              imageUrl: "assets/icons/humidity.png",
              data: "${weatherDataCurrent.humidity ?? '--'}%",
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMoreDetailsWidget({required BuildContext context, String? imageUrl, String? data}) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.asset(imageUrl ?? ''),
        ),
        const SizedBox(height: 10),
        Text(data ?? '--', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
