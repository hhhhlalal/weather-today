import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/selected_city_provider.dart';
import '../utils/openweather_utils.dart';

class SearchCityScreen extends StatefulWidget {
  const SearchCityScreen({super.key});

  @override
  State<SearchCityScreen> createState() => _SearchCityScreenState();
}

class _SearchCityScreenState extends State<SearchCityScreen> {
  final Map<String, Map<String, double>> _cityCoordinates = {
    'Ha Noi': {'lat': 21.0285, 'lon': 105.8542},
    'Ho Chi Minh City': {'lat': 10.8231, 'lon': 106.6297},
    'Da Nang': {'lat': 16.0471, 'lon': 108.2068},
    'Hai Phong': {'lat': 20.8449, 'lon': 106.6881},
    'Can Tho': {'lat': 10.0452, 'lon': 105.7469},
    'Nha Trang': {'lat': 12.2388, 'lon': 109.1967},
    'Vung Tau': {'lat': 10.4113, 'lon': 107.1362},
    'Cam Ranh': {'lat': 11.9214, 'lon': 109.1593},
    'Phan Thiet': {'lat': 10.9280, 'lon': 108.1020},
    'Phan Rang-Thap Cham': {'lat': 11.5845, 'lon': 108.9829},
    'Buon Ma Thuot': {'lat': 12.6667, 'lon': 108.0500},
    'My Tho': {'lat': 10.3600, 'lon': 106.3600},
    'Quy Nhon': {'lat': 13.7831, 'lon': 109.2191},
    'Rach Gia': {'lat': 10.0120, 'lon': 105.0802},
    'Long Xuyen': {'lat': 10.3833, 'lon': 105.4333},
    'Ha Giang': {'lat': 22.8230, 'lon': 104.9784},
    'Cao Bang': {'lat': 22.6666, 'lon': 106.2639},
    'Bac Kan': {'lat': 22.1474, 'lon': 105.8348},
    'Tuyen Quang': {'lat': 21.8236, 'lon': 105.2175},
    'Lao Cai': {'lat': 22.4856, 'lon': 103.9707},
    'Dien Bien': {'lat': 21.3951, 'lon': 103.0136},
    'Lai Chau': {'lat': 22.3964, 'lon': 103.4705},
    'Son La': {'lat': 21.3256, 'lon': 103.9188},
    'Yen Bai': {'lat': 21.7229, 'lon': 104.9113},
    'Hoa Binh': {'lat': 20.8133, 'lon': 105.3381},
    'Thai Nguyen': {'lat': 21.5928, 'lon': 105.8253},
    'Lang Son': {'lat': 21.8539, 'lon': 106.7611},
    'Bac Giang': {'lat': 21.2731, 'lon': 106.1946},
    'Phu Tho': {'lat': 21.4010, 'lon': 105.2280},
    'Vinh Phuc': {'lat': 21.3609, 'lon': 105.6057},
    'Bac Ninh': {'lat': 21.1864, 'lon': 106.0763},
    'Ha Nam': {'lat': 20.5835, 'lon': 105.9230},
    'Hung Yen': {'lat': 20.6464, 'lon': 106.0512},
    'Nam Dinh': {'lat': 20.4344, 'lon': 106.1675},
    'Thai Binh': {'lat': 20.4500, 'lon': 106.3400},
    'Ninh Binh': {'lat': 20.2506, 'lon': 105.9756},
    'Thanh Hoa': {'lat': 19.8069, 'lon': 105.7851},
    'Nghe An': {'lat': 18.6769, 'lon': 105.6820},
    'Ha Tinh': {'lat': 18.3421, 'lon': 105.9069},
    'Quang Binh': {'lat': 17.4739, 'lon': 106.6234},
    'Quang Tri': {'lat': 16.7427, 'lon': 107.1856},
    'Thua Thien Hue': {'lat': 16.4637, 'lon': 107.5909},
    'Quang Nam': {'lat': 15.5394, 'lon': 108.0191},
    'Quang Ngai': {'lat': 15.1214, 'lon': 108.8044},
    'Binh Dinh': {'lat': 13.7831, 'lon': 109.2191},
    'Phu Yen': {'lat': 13.0881, 'lon': 109.0928},
    'Khanh Hoa': {'lat': 12.2388, 'lon': 109.1967},
    'Ninh Thuan': {'lat': 11.5845, 'lon': 108.9829},
    'Binh Thuan': {'lat': 10.9280, 'lon': 108.1020},
    'Kon Tum': {'lat': 14.3497, 'lon': 107.9651},
    'Gia Lai': {'lat': 13.9833, 'lon': 108.0000},
    'Dak Lak': {'lat': 12.6667, 'lon': 108.0500},
    'Dak Nong': {'lat': 12.2646, 'lon': 107.6098},
    'Lam Dong': {'lat': 11.9404, 'lon': 108.4583},
    'Binh Phuoc': {'lat': 11.7511, 'lon': 106.7234},
    'Tay Ninh': {'lat': 11.3100, 'lon': 106.0983},
    'Binh Duong': {'lat': 11.3254, 'lon': 106.4773},
    'Dong Nai': {'lat': 10.9524, 'lon': 106.8365},
    'Dong Thap': {'lat': 10.4938, 'lon': 105.6881},
    'Long An': {'lat': 10.6956, 'lon': 106.2431},
    'Tien Giang': {'lat': 10.3600, 'lon': 106.3600},
    'Ben Tre': {'lat': 10.2433, 'lon': 106.3755},
    'Vinh Long': {'lat': 10.2397, 'lon': 105.9571},
    'Tra Vinh': {'lat': 9.9347, 'lon': 106.2997},
    'Hau Giang': {'lat': 9.7840, 'lon': 105.6412},
    'Soc Trang': {'lat': 9.6003, 'lon': 105.9739},
    'An Giang': {'lat': 10.3833, 'lon': 105.4333},
    'Kien Giang': {'lat': 10.0120, 'lon': 105.0802},
    'Bac Lieu': {'lat': 9.2945, 'lon': 105.7244},
    'Ca Mau': {'lat': 9.1768, 'lon': 105.1524},
  };

  final List<String> _cities = [
    'Ha Noi', 'Ho Chi Minh City', 'Da Nang', 'Hai Phong', 'Can Tho', 'Nha Trang',
    'Vung Tau', 'Cam Ranh', 'Phan Thiet', 'Phan Rang-Thap Cham', 'Buon Ma Thuot',
    'My Tho', 'Quy Nhon', 'Rach Gia', 'Long Xuyen',
    'Ha Giang', 'Cao Bang', 'Bac Kan', 'Tuyen Quang', 'Lao Cai', 'Dien Bien',
    'Lai Chau', 'Son La', 'Yen Bai', 'Hoa Binh', 'Thai Nguyen', 'Lang Son',
    'Bac Giang', 'Phu Tho', 'Vinh Phuc', 'Bac Ninh', 'Ha Nam', 'Hung Yen',
    'Nam Dinh', 'Thai Binh', 'Ninh Binh', 'Thanh Hoa', 'Nghe An', 'Ha Tinh',
    'Quang Binh', 'Quang Tri', 'Thua Thien Hue', 'Quang Nam', 'Quang Ngai',
    'Binh Dinh', 'Phu Yen', 'Khanh Hoa', 'Ninh Thuan', 'Binh Thuan', 'Kon Tum',
    'Gia Lai', 'Dak Lak', 'Dak Nong', 'Lam Dong', 'Binh Phuoc', 'Tay Ninh',
    'Binh Duong', 'Dong Nai', 'Dong Thap', 'Long An', 'Tien Giang', 'Ben Tre',
    'Vinh Long', 'Tra Vinh', 'Hau Giang', 'Soc Trang', 'An Giang', 'Kien Giang',
    'Bac Lieu', 'Ca Mau'
  ];

  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    const itemHeight = 56.0;
    final offset = (_selectedIndex * itemHeight) - 150;
    _scrollController.animateTo(
      math.max(0.0, offset),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _selectCity(int index) async {
    final selectedCity = _cities[index];
    final coordinates = _cityCoordinates[selectedCity];
    
    if (coordinates != null) {
      // Lưu thông tin thành phố đã chọn vào Provider
      final selectedCityProvider = Provider.of<SelectedCityProvider>(context, listen: false);
      selectedCityProvider.setCity(
        selectedCity, 
        coordinates['lat']!, 
        coordinates['lon']!
      );
      
      // Quay lại màn hình trước (Current Weather Screen)
      Navigator.of(context).pop();
    } else {
      // Hiển thị thông báo lỗi nếu không tìm thấy tọa độ thành phố
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy tọa độ của $selectedCity'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      if (_selectedIndex < _cities.length - 1) {
        setState(() => _selectedIndex++);
        _scrollToSelected();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (_selectedIndex > 0) {
        setState(() => _selectedIndex--);
        _scrollToSelected();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
      _selectCity(_selectedIndex);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn thành phố'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // Xóa thành phố đã chọn và quay lại màn hình current với vị trí hiện tại
              final selectedCityProvider = Provider.of<SelectedCityProvider>(context, listen: false);
              selectedCityProvider.clear();
              Navigator.of(context).pop();
            },
            tooltip: 'Về vị trí hiện tại',
          ),
        ],
      ),
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedIndex;
              return Container(
                color: isSelected ? Colors.blue.withOpacity(0.2) : null,
                child: ListTile(
                  title: Text(
                    _cities[index],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : null,
                    ),
                  ),
                  selected: isSelected,
                  trailing: isSelected
                      ? const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16)
                      : null,
                  onTap: () => _selectCity(index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}