/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-29-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class GoogleNewsController {
    private static final String API_KEY = 'a093281e78f94c1fa9829b8613e62a86';
    private static final String BASE_URL = 'https://newsapi.org/v2/everything';

    @AuraEnabled
    public static List<NewsArticle> fetchNews(String query, Integer pageNumber, Integer pageSize) {
        Integer fromIndex = (pageNumber - 1) * pageSize;
        // String endpoint = BASE_URL + '?q=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&sortBy=publishedAt&apiKey=' + API_KEY;
        String endpoint = BASE_URL + '?q=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&sortBy=publishedAt&pageSize=' + pageSize + '&page=' + pageNumber + '&apiKey=' + API_KEY;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> articles = (List<Object>) results.get('articles');
            System.debug('articles size ::: ' + articles.size());
            List<NewsArticle> newsArticles = new List<NewsArticle>();
            for (Object articleObj : articles) {
                Map<String, Object> article = (Map<String, Object>) articleObj;
                NewsArticle newsArticle = new NewsArticle();
                newsArticle.title       = (String) article.get('title');
                newsArticle.description = (String) article.get('description');
                newsArticle.url         = (String) article.get('url');
                newsArticle.urlToImage  = (String) article.get('urlToImage');
                newsArticle.totalResults  = (Integer) results.get('totalResults');
                newsArticles.add(newsArticle);
            }
            System.debug('newsArticles ::: ' + newsArticles);
            return newsArticles;
        } else {
            System.debug('Failed to fetch news: ' + response.getBody());
            return new List<NewsArticle>();
        }
    }

    @AuraEnabled
    public static List<NewsArticle> fetchAccountNews(Id accountId, Integer pageNumber, Integer pageSize) {
        Account acc = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
        return fetchNews(acc.Name, pageNumber, pageSize);
    }

    public class NewsArticle {
        @AuraEnabled public String title        {get;set;}
        @AuraEnabled public String description  {get;set;}
        @AuraEnabled public String url          {get;set;}
        @AuraEnabled public String urlToImage   {get;set;}
        @AuraEnabled public Integer totalResults {get;set;}
    }
}