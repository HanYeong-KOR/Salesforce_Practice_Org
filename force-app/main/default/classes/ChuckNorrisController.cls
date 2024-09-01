/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 01-03-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class ChuckNorrisController {
    // Main Methid
    @AuraEnabled
    public static String getRandomChuckNorrisJoke() {
        String apiUrl = 'https://api.chucknorris.io/jokes/random';

        // Set up HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiUrl);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        // Make the HTTP request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Process the response
        if (res.getStatusCode() == 200) {
            String responseBody = res.getBody();
            return responseBody;
        } else {
            System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
            return null;
        }
    }
}