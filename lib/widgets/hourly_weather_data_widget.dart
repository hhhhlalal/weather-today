import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import 'hourly_detail_container_widget.dart';

class HourlyWeatherDataWidget extends StatelessWidget {
  const HourlyWeatherDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hourlyList =
        Get.find<HomeController>().weatherData.value.hourly?.hourly ?? [];

    return Column(
      children: [
        Text("Today", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: hourlyList.isEmpty
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourlyList.length.clamp(0, 12),
                  itemBuilder: (_, index) {
                    final hourly = hourlyList[index];
                    return HourlyDetailContainerWidget(
                      temp: hourly.temp ?? 0,
                      timeStamp: hourly.dt ?? 0,
                      weatherIcon: hourly.weather?.firstOrNull?.icon ?? 'unknown',
                    );
                  },
                ),
        ),
      ],
    );
  }
}
