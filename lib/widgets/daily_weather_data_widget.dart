import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../utils/date_time_format.dart';

class DailyWeatherDataWidget extends StatelessWidget {
  const DailyWeatherDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dailyList =
        Get.find<HomeController>().weatherData.value.daily?.daily ?? [];

    return Column(
      children: [
        Text("Next Days", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: dailyList.isEmpty
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  itemCount: dailyList.length.clamp(0, 7),
                  itemBuilder: (_, index) {
                    final daily = dailyList[index];
                    return ListTile(
                      leading: Image.asset(
                        "assets/weather/${daily.weather?.firstOrNull?.icon ?? 'unknown'}.png",
                        height: 30,
                        width: 30,
                      ),
                      title: Text(DateTimeFormat.getDay(daily.dt)),
                      trailing: Text(
                        "${daily.temp?.max ?? '--'}°/${daily.temp?.min ?? '--'}°",
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
