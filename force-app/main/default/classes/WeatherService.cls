/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-28-2024
 * @last modified by  : Hanyeong Choi
**/

public class WeatherService {
    @AuraEnabled
    public static List<WeatherInfoWrapper> getWeather() {
        try {
            String baseUrl = 'http://apis.data.go.kr/1360000/MidFcstInfoService/getMidTa';
            String rainUrl = 'http://apis.data.go.kr/1360000/MidFcstInfoService/getMidLandFcst';
            String serviceKey = 'BHUA%2Fytz9BiDW%2F%2BX9wG1qiDtRlWxd%2Fu4wnQ1UQH1wb3xg2OqK2tixYXq2Q%2BuuSf3yMcRMZYfgGyBYYz1Xxa12g%3D%3D';
            String regId = '11B10101'; // 서울 지역 코드
            String rainRegId = '11B00000'; // 서울 지역 코드
            String tmFc = Datetime.now().format('yyyyMMdd') + '0600'; // 예보 발표 시간 (0600 또는 1800)
    
            String weatherUrl = baseUrl + 
                                '?serviceKey=' + serviceKey +
                                '&numOfRows=10' +
                                '&pageNo=1' +
                                '&dataType=JSON' +
                                '&regId=' + regId +
                                '&tmFc=' + tmFc;
    
            String rainProbUrl = rainUrl + 
                                '?serviceKey=' + serviceKey +
                                '&pageNo=1' +
                                '&numOfRows=10' +
                                '&dataType=JSON' +
                                '&regId=' + rainRegId +
                                '&tmFc=' + tmFc;
    
            Http http = new Http();
            HttpRequest weatherRequest = new HttpRequest();
            weatherRequest.setEndpoint(weatherUrl);
            weatherRequest.setMethod('GET');
            HttpResponse weatherResponse = http.send(weatherRequest);
    
            HttpRequest rainProbRequest = new HttpRequest();
            rainProbRequest.setEndpoint(rainProbUrl);
            rainProbRequest.setMethod('GET');
            HttpResponse rainProbResponse = http.send(rainProbRequest);
    
            List<WeatherInfoWrapper> forecasts = new List<WeatherInfoWrapper>();
    
            if (weatherResponse.getStatusCode() == 200 && rainProbResponse.getStatusCode() == 200) {
                Map<String, Object> weatherResults = (Map<String, Object>) JSON.deserializeUntyped(weatherResponse.getBody());
                Map<String, Object> responseBody = (Map<String, Object>) weatherResults.get('response');
                Map<String, Object> weatherBody = (Map<String, Object>) responseBody.get('body');
                Map<String, Object> weatherItems = (Map<String, Object>) weatherBody.get('items');
                List<Object> weatherItemList = (List<Object>) weatherItems.get('item');
                
                Map<String, Object> rainResults = (Map<String, Object>) JSON.deserializeUntyped(rainProbResponse.getBody());
                responseBody = (Map<String, Object>) rainResults.get('response');
                Map<String, Object> rainBody = (Map<String, Object>) responseBody.get('body');
                Map<String, Object> rainItems = (Map<String, Object>) rainBody.get('items');
                List<Object> rainItemList = (List<Object>) rainItems.get('item');
    
                for (Integer i = 3; i <= 10; i++) { // 3일부터 10일까지의 날씨 정보를 가져옵니다.
                    Map<String, Object> weatherItem = (Map<String, Object>) weatherItemList[0];
                    Map<String, Object> rainItem = (Map<String, Object>) rainItemList[0];
    
                    WeatherInfoWrapper forecast = new WeatherInfoWrapper();
                    Date forecastDate = Date.today().addDays(i); 
                    forecast.forecastDate = Datetime.now().addDays(i).format('yyyy-MM-dd');
                    forecast.yoil = getYoil(forecastDate);
                    forecast.minTemp = Integer.valueOf(String.valueOf(weatherItem.get('taMin' + i)));
                    forecast.maxTemp = Integer.valueOf(String.valueOf(weatherItem.get('taMax' + i)));
                    if(i < 8) {
                        forecast.rainAm = Integer.valueOf(String.valueOf(rainItem.get('rnSt' + i + 'Am')));
                        forecast.rainPm = Integer.valueOf(String.valueOf(rainItem.get('rnSt' + i + 'Pm')));
                        forecast.skyAm = String.valueOf(rainItem.get('wf' + i + 'Am'));
                        forecast.skyPm = String.valueOf(rainItem.get('wf' + i + 'Pm'));
                    } else {
                        forecast.rainAm = Integer.valueOf(String.valueOf(rainItem.get('rnSt' + i)));
                        forecast.rainPm = Integer.valueOf(String.valueOf(rainItem.get('rnSt' + i)));
                        forecast.skyAm = String.valueOf(rainItem.get('wf' + i));
                        forecast.skyPm = String.valueOf(rainItem.get('wf' + i));
                    }
                    System.debug('forecast ::: ' + forecast);
    
                    forecasts.add(forecast);
                }
    
                return forecasts;
            } else {
                throw new AuraHandledException('Failed to fetch weather data');
            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getYoil(Date d) {
        String[] days = new String[] {'일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'};
        Integer dayIndex = d.toStartOfWeek().daysBetween(d);
        return days[dayIndex];
    }

    public class WeatherInfoWrapper {
        @AuraEnabled public String forecastDate { get; set; }
        @AuraEnabled public String yoil { get; set; }
        @AuraEnabled public Integer minTemp { get; set; }
        @AuraEnabled public Integer maxTemp { get; set; }
        @AuraEnabled public Integer rainAm { get; set; }
        @AuraEnabled public Integer rainPm { get; set; }
        @AuraEnabled public String skyAm { get; set; }
        @AuraEnabled public String skyPm { get; set; }
    }
}