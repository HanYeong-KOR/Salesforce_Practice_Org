/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-22-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class PapagoController {
    // Main Method
    @AuraEnabled
    public static Map<String, Object> getInitDatas(String question) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('getTranslateInfo', translateInfo(question));

            return result;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string translateJoke(String question) {
        String result;

        try {
            String apiURL = 'https://openapi.naver.com/v1/papago/n2mt';

            // Named Credentials를 사용하여 연결 설정
            Http http           = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');

            String clientId     = 'ySLPXaJR2S3kbiXU9cRg'; // 애플리케이션 클라이언트 아이디값
            String clientSecret = 'tLha6KLV4f'; // 애플리케이션 클라이언트 시크릿값

            // API 요청 바디 설정
            String requestBody = 'source=en&target=ko&text=' + EncodingUtil.urlEncode(question, 'UTF-8');
            request.setHeader('X-Naver-Client-Id', clientId);
            request.setHeader('X-Naver-Client-Secret', clientSecret);
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
            request.setHeader('Accept', '*/*');
            request.setBody(requestBody);

            // API 호출 및 응답 처리
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                Map<String, Object> jsonResponse    = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                Map<String, Object> jsonMessage     = (Map<String, Object>) jsonResponse.get('message');
                Map<String, Object> jsonResult      = (Map<String, Object>) jsonMessage.get('result');
                result = (String) jsonResult.get('translatedText');

                return result;
            } else {
                System.debug('API 오류: ' + response.getBody());
                throw new AuraHandledException('API 호출 중 오류 발생');
            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Object> naverSearch(String question) {
        try {
            String clientId = 'GnMmjnfwWV4tQIAcchIW';
            String clientSecret = 'VJCWWUpaU6';
            
            String encodedQuestion = EncodingUtil.urlEncode(question, 'UTF-8');

            String apiURL = 'https://openapi.naver.com/v1/search/book.json?query=' + encodedQuestion;

            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiURL);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-Naver-Client-Id', clientId);
            request.setHeader('X-Naver-Client-Secret', clientSecret);
            request.setHeader('Accept', '*/*');

            Http http = new Http();
            HttpResponse response;
            response = http.send(request);
            
            Map<String, Object> jsonResponse    = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> jsonitems    = (List<Object>) jsonResponse.get('items');
            return jsonitems;
            
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());

            throw new AuraHandledException(e.getMessage());
        }
    }

    // Utill Method
    private static string translateInfo(String question) {
        String result;

        try {
            String apiURL = 'https://openapi.naver.com/v1/papago/n2mt';

            // Named Credentials를 사용하여 연결 설정
            Http http           = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');

            String clientId     = 'ySLPXaJR2S3kbiXU9cRg'; // 애플리케이션 클라이언트 아이디값
            String clientSecret = 'tLha6KLV4f'; // 애플리케이션 클라이언트 시크릿값

            // API 요청 바디 설정
            String requestBody = 'source=ko&target=en&text=' + EncodingUtil.urlEncode(question, 'UTF-8');
            request.setHeader('X-Naver-Client-Id', clientId);
            request.setHeader('X-Naver-Client-Secret', clientSecret);
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
            request.setHeader('Accept', '*/*');
            request.setBody(requestBody);

            // API 호출 및 응답 처리
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                Map<String, Object> jsonResponse    = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                Map<String, Object> jsonMessage     = (Map<String, Object>) jsonResponse.get('message');
                Map<String, Object> jsonResult      = (Map<String, Object>) jsonMessage.get('result');
                result = (String) jsonResult.get('translatedText');

                return result;
            } else {
                System.debug('API 오류: ' + response.getBody());
                throw new AuraHandledException('API 호출 중 오류 발생');
            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }
}