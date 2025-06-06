import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchCityScreen extends StatefulWidget {
  const SearchCityScreen({super.key});
  @override
  State<SearchCityScreen> createState() => _SearchCityScreenState();
}

class _SearchCityScreenState extends State<SearchCityScreen> {
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
  final FocusNode _listFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Đặt focus ngay vào danh sách khi màn hình xuất hiện
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _listFocusNode.requestFocus();
    });
  }

  KeyEventResult _handleListKey(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    if (_cities.isEmpty) return KeyEventResult.handled;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_selectedIndex < _cities.length - 1) {
        setState(() => _selectedIndex++);
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_selectedIndex > 0) {
        setState(() => _selectedIndex--);
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select) {
      // Đảm bảo luôn pop về đúng city khi enter hoặc remote OK
      Navigator.pop(context, _cities[_selectedIndex]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn thành phố'),
        automaticallyImplyLeading: false, // Không hiện nút back
      ),
      body: SafeArea(
        child: Focus(
          focusNode: _listFocusNode,
          autofocus: true,
          onKey: _handleListKey,
          child: ListView.builder(
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, _cities[index]);
                },
                child: Container(
                  color: isSelected ? Colors.blue.withOpacity(0.2) : null,
                  child: ListTile(
                    title: Text(_cities[index]),
                    selected: isSelected,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
