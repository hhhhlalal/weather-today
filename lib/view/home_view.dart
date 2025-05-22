import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../widgets/comfort_level_widget.dart';
import '../widgets/current_weather_data_widget.dart';
import '../widgets/daily_weather_data_widget.dart';
import '../widgets/header_information_widget.dart';
import '../widgets/hourly_weather_data_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController(), permanent: true);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.getLocation,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.locationErrorMessage.isNotEmpty) {
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 100),
                children: [
                  const Icon(Icons.location_on_rounded, size: 50),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      controller.locationErrorMessage.value,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              );
            }

            return ListView(
              children: const [
                SizedBox(height: 30),
                HeaderInformationWidget(),
                SizedBox(height: 20),
                CurrentWeatherDataWidget(),
                SizedBox(height: 40),
                HourlyWeatherDataWidget(),
                SizedBox(height: 40),
                DailyWeatherDataWidget(),
                Divider(indent: 25, endIndent: 25),
                SizedBox(height: 30),
                ComfortLevelWidget(),
                SizedBox(height: 30),
              ],
            );
          }),
        ),
      ),
    );
  }
}
