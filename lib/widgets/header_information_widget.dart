import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import '../controller/home_controller.dart';
import '../utils/date_time_format.dart';

class HeaderInformationWidget extends StatelessWidget {
  const HeaderInformationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Obx(() => Text(
                        controller.city.value,
                        style: Theme.of(context).textTheme.headlineLarge,
                      )),
                  const SizedBox(width: 10),
                  const Icon(Icons.location_on, size: 25),
                ],
              ),
              Text(
                DateTimeFormat.currentDate,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          Obx(() => DayNightSwitcher(
                isDarkModeEnabled: controller.isDarkMode.value,
                onStateChanged: (_) => controller.toggleTheme(),
              )),
        ],
      ),
    );
  }
}
