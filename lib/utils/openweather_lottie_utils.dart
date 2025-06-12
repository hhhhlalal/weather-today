class OWMLottieWeather {
  final String lottieFile; // Tên file Lottie (.json)
  final String viDesc;     // Mô tả tiếng Việt
  final String icon;       // Icon code từ OWM
  const OWMLottieWeather(this.lottieFile, this.viDesc, this.icon);
}
OWMLottieWeather getOWMLottieWeather(String code) {
  // lấy 2-3 ký tự đầu để map
  final baseCode = code.toLowerCase();
  final numericCode = code.length > 2 ? code.substring(0, 2) : code;
  switch (baseCode) {
    // Clear Sky - Sunny
    case '01d':
    case '01n':
    case '01':
      return OWMLottieWeather('sunny.json', 'Trời nắng', '01d');
    // Few Clouds - Ít mây
    case '02d':
    case '02n':  
    case '02':
      return OWMLottieWeather('partly-cloudy.json', 'Ít mây', '02d');
    // Scattered Clouds - Mây rải rác
    case '03d':
    case '03n':
    case '03':
      return OWMLottieWeather('cloudy.json', 'Mây rải rác', '03d');
    // Broken Clouds - Nhiều mây
    case '04d':
    case '04n':
    case '04':
      return OWMLottieWeather('overcast.json', 'Nhiều mây', '04d');
    
    // Shower Rain - Mưa rào
    case '09d':
    case '09n':
    case '09':
      return OWMLottieWeather('extreme-rain.json', 'Mưa rào', '09d');
    
    // Rain - Mưa
    case '10d':
    case '10n':
    case '10':
      return OWMLottieWeather('rain.json', 'Mưa', '10d');
    
    // Thunderstorm - Dông bão
    case '11d':
    case '11n':
    case '11':
      return OWMLottieWeather('thunderstorms-rain.json', 'Dông bão', '11d');
    
    // Snow - Tuyết
    case '13d':
    case '13n':
    case '13':
      return OWMLottieWeather('snow.json', 'Tuyết', '13d');
    
    // Mist - Sương mù
    case '50d':
    case '50n':
    case '50':
      return OWMLottieWeather('mist.json', 'Sương mù', '50d');
      
    // Thunderstorm chi tiết
    case '200': return OWMLottieWeather('storm-with-rain.json', 'Dông có mưa nhẹ', '11d');
    case '201': return OWMLottieWeather('storm-with-rain.json', 'Dông có mưa', '11d');
    case '202': return OWMLottieWeather('extreme-storm.json', 'Dông có mưa to', '11d');
    case '210': return OWMLottieWeather('lightning-bolt.json', 'Dông nhẹ', '11d');
    case '211': return OWMLottieWeather('lightning-bolt.json', 'Dông', '11d');
    case '212': return OWMLottieWeather('extreme-storm.json', 'Dông mạnh', '11d');
    case '221': return OWMLottieWeather('scattered-thunderstorms.json', 'Dông rải rác', '11d');
    case '230': return OWMLottieWeather('storm-with-drizzle.json', 'Dông có mưa phùn nhẹ', '11d');
    case '231': return OWMLottieWeather('storm-with-drizzle.json', 'Dông có mưa phùn', '11d');
    case '232': return OWMLottieWeather('storm-with-drizzle.json', 'Dông có mưa phùn to', '11d');
    
    // Drizzle - Mưa phùn
    case '300': return OWMLottieWeather('drizzle.json', 'Mưa phùn nhẹ', '09d');
    case '301': return OWMLottieWeather('drizzle.json', 'Mưa phùn', '09d');
    case '302': return OWMLottieWeather('heavy-drizzle.json', 'Mưa phùn to', '09d');
    case '310': return OWMLottieWeather('drizzle-rain.json', 'Mưa phùn nhẹ có mưa', '09d');
    case '311': return OWMLottieWeather('drizzle-rain.json', 'Mưa phùn có mưa', '09d');
    case '312': return OWMLottieWeather('heavy-drizzle-rain.json', 'Mưa phùn to có mưa', '09d');
    case '313': return OWMLottieWeather('shower-rain.json', 'Mưa rào và mưa phùn', '09d');
    case '314': return OWMLottieWeather('heavy-shower-rain.json', 'Mưa rào to và mưa phùn', '09d');
    case '321': return OWMLottieWeather('shower-drizzle.json', 'Mưa phùn rào', '09d');
    
    // Rain - Mưa
    case '500': return OWMLottieWeather('light-rain.json', 'Mưa nhẹ', '10d');
    case '501': return OWMLottieWeather('rain.json', 'Mưa vừa', '10d');
    case '502': return OWMLottieWeather('heavy-rain.json', 'Mưa to', '10d');
    case '503': return OWMLottieWeather('extreme-rain.json', 'Mưa rất to', '10d');
    case '504': return OWMLottieWeather('extreme-rain.json', 'Mưa cực to', '10d');
    case '511': return OWMLottieWeather('freezing-rain.json', 'Mưa đóng băng', '13d');
    case '520': return OWMLottieWeather('shower-rain.json', 'Mưa rào nhẹ', '09d');
    case '521': return OWMLottieWeather('shower-rain.json', 'Mưa rào', '09d');
    case '522': return OWMLottieWeather('heavy-shower-rain.json', 'Mưa rào to', '09d');
    case '531': return OWMLottieWeather('ragged-shower-rain.json', 'Mưa rào không đều', '09d');
    
    // Snow - Tuyết
    case '600': return OWMLottieWeather('light-snow.json', 'Tuyết nhẹ', '13d');
    case '601': return OWMLottieWeather('snow.json', 'Tuyết', '13d');
    case '602': return OWMLottieWeather('heavy-snow.json', 'Tuyết to', '13d');
    case '611': return OWMLottieWeather('sleet.json', 'Mưa tuyết', '13d');
    case '612': return OWMLottieWeather('light-sleet.json', 'Mưa tuyết nhẹ', '13d');
    case '613': return OWMLottieWeather('shower-sleet.json', 'Mưa tuyết rào', '13d');
    case '615': return OWMLottieWeather('rain-snow.json', 'Mưa và tuyết nhẹ', '13d');
    case '616': return OWMLottieWeather('rain-snow.json', 'Mưa và tuyết', '13d');
    case '620': return OWMLottieWeather('shower-snow.json', 'Tuyết rào nhẹ', '13d');
    case '621': return OWMLottieWeather('shower-snow.json', 'Tuyết rào', '13d');
    case '622': return OWMLottieWeather('heavy-shower-snow.json', 'Tuyết rào to', '13d');
    
    // Atmosphere - Khí quyển
    case '701': return OWMLottieWeather('mist.json', 'Sương mù', '50d');
    case '711': return OWMLottieWeather('smoke.json', 'Khói', '50d');
    case '721': return OWMLottieWeather('haze.json', 'Sương mù nhẹ', '50d');
    case '731': return OWMLottieWeather('dust-wind.json', 'Cát bụi', '50d');
    case '741': return OWMLottieWeather('fog.json', 'Sương mù dày', '50d');
    case '751': return OWMLottieWeather('sand.json', 'Cát', '50d');
    case '761': return OWMLottieWeather('dust.json', 'Bụi', '50d');
    case '762': return OWMLottieWeather('volcanic-ash.json', 'Tro núi lửa', '50d');
    case '771': return OWMLottieWeather('squalls.json', 'Gió giật', '50d');
    case '781': return OWMLottieWeather('tornado.json', 'Lốc xoáy', '50d');
    
    // Clear - Quang đãng
    case '800': return OWMLottieWeather('clear-day.json', 'Trời quang đãng', '01d');
    
    // Clouds - Mây
    case '801': return OWMLottieWeather('partly-cloudy.json', 'Ít mây (11-25%)', '02d');
    case '802': return OWMLottieWeather('scattered-clouds.json', 'Mây rải rác (25-50%)', '03d');
    case '803': return OWMLottieWeather('broken-clouds.json', 'Nhiều mây (51-84%)', '04d');
    case '804': return OWMLottieWeather('overcast.json', 'Mây che phủ (85-100%)', '04d');
    
    default:
      // Fallback dựa trên mã số
      if (numericCode == '01') {
        return OWMLottieWeather('clear-day.json', 'Trời quang đãng', '01d');
      } else if (numericCode == '02') {
        return OWMLottieWeather('partly-cloudy.json', 'Ít mây', '02d');
      } else if (numericCode == '03') {
        return OWMLottieWeather('cloudy.json', 'Mây rải rác', '03d');
      } else if (numericCode == '04') {
        return OWMLottieWeather('overcast.json', 'Nhiều mây', '04d');
      } else if (numericCode == '09') {
        return OWMLottieWeather('extreme-rain.json', 'Mưa rào', '09d');
      } else if (numericCode == '10') {
        return OWMLottieWeather('rain.json', 'Mưa', '10d');
      } else if (numericCode == '11') {
        return OWMLottieWeather('lightning-bolt.json', 'Dông bão', '11d');
      } else if (numericCode == '13') {
        return OWMLottieWeather('snow.json', 'Tuyết', '13d');
      } else if (numericCode == '50') {
        return OWMLottieWeather('mist.json', 'Sương mù', '50d');
      } else {
        return OWMLottieWeather('cloudy.json', 'Không xác định', '04d');
      }
  }
}

String getOWMWeatherDescription(String code) {
  return getOWMLottieWeather(code).viDesc;
}

String getOWMWeatherIcon(String code) {
  return getOWMLottieWeather(code).icon;
}

String getOWMLottieFile(String code) {
  return getOWMLottieWeather(code).lottieFile;
}

// Hàm trợ giúp để lấy thông tin thời tiết theo nhóm
String getWeatherGroup(String code) {
  final numericCode = int.tryParse(code.substring(0, 1)) ?? 0;
  switch (numericCode) {
    case 2: return 'Dông bão';
    case 3: return 'Mưa phùn';  
    case 5: return 'Mưa';
    case 6: return 'Tuyết';
    case 7: return 'Khí quyển';
    case 8: return code == '800' ? 'Quang đãng' : 'Mây';
    default: return 'Khác';
  }
}