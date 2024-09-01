/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-30-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class naverNewsController {
    @AuraEnabled
    public static List<NaverNewsArticle> fetchNaverNews(String query, Integer pageNumber, Integer pageSize) {
        List<NaverNewsArticle> result = new List<NaverNewsArticle>();

        try {
            String clientId     = 'GnMmjnfwWV4tQIAcchIW'; // 애플리케이션 클라이언트 아이디값
            String clientSecret = 'VJCWWUpaU6'; // 애플리케이션 클라이언트 시크릿값

            String apiURL = 'https://openapi.naver.com/v1/search/news.json?sort=date&start=' + (pageNumber * 10 + 1) + '&query=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&display=' + pageSize;

            Http http           = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiURL);
            request.setMethod('GET');

            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-Naver-Client-Id', clientId);
            request.setHeader('X-Naver-Client-Secret', clientSecret);
            request.setHeader('Accept', '*/*');

            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                Map<String, Object> jsonResponse    = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                List<Object> jsonItems = (List<Object>) jsonResponse.get('items');
                for(Object item : jsonItems) {
                    Map<String, Object> article = (Map<String, Object>) item;
                    NaverNewsArticle newsArticle = new NaverNewsArticle();

                    newsArticle.title = decodeHtml(removeHtmlTags((String) article.get('title')));
                    newsArticle.description = decodeHtml(removeHtmlTags((String) article.get('description')));
                    newsArticle.url = (String) article.get('link');
                    newsArticle.totalResults = (Integer) jsonResponse.get('total');

                    result.add(newsArticle);
                }
                
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
    public static List<NaverNewsArticle> fetchAccountNews(Id accountId, Integer pageNumber, Integer pageSize) {
        Account acc = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
        return fetchNaverNews(acc.Name, pageNumber, pageSize);
    }

    private static String removeHtmlTags(String html) {
        return html.replaceAll('<.*?>', '');
    }

    private static String decodeHtml(String text) {
        if (text == null) return null;
    
        Map<String, String> htmlEntities = new Map<String, String>{
            '&quot;' => '"',
            '&amp;' => '&',
            '&lt;' => '<',
            '&gt;' => '>',
            '&nbsp;' => ' ',
            '&iexcl;' => '¡',
            '&cent;' => '¢',
            '&pound;' => '£',
            '&curren;' => '¤',
            '&yen;' => '¥',
            '&brvbar;' => '¦',
            '&sect;' => '§',
            '&uml;' => '¨',
            '&copy;' => '©',
            '&ordf;' => 'ª',
            '&laquo;' => '«',
            '&not;' => '¬',
            '&shy;' => '­',
            '&reg;' => '®',
            '&macr;' => '¯',
            '&deg;' => '°',
            '&plusmn;' => '±',
            '&sup2;' => '²',
            '&sup3;' => '³',
            '&acute;' => '´',
            '&micro;' => 'µ',
            '&para;' => '¶',
            '&middot;' => '·',
            '&cedil;' => '¸',
            '&sup1;' => '¹',
            '&ordm;' => 'º',
            '&raquo;' => '»',
            '&frac14;' => '¼',
            '&frac12;' => '½',
            '&frac34;' => '¾',
            '&iquest;' => '¿',
            '&Agrave;' => 'À',
            '&Aacute;' => 'Á',
            '&Acirc;' => 'Â',
            '&Atilde;' => 'Ã',
            '&Auml;' => 'Ä',
            '&Aring;' => 'Å',
            '&AElig;' => 'Æ',
            '&Ccedil;' => 'Ç',
            '&Egrave;' => 'È',
            '&Eacute;' => 'É',
            '&Ecirc;' => 'Ê',
            '&Euml;' => 'Ë',
            '&Igrave;' => 'Ì',
            '&Iacute;' => 'Í',
            '&Icirc;' => 'Î',
            '&Iuml;' => 'Ï',
            '&ETH;' => 'Ð',
            '&Ntilde;' => 'Ñ',
            '&Ograve;' => 'Ò',
            '&Oacute;' => 'Ó',
            '&Ocirc;' => 'Ô',
            '&Otilde;' => 'Õ',
            '&Ouml;' => 'Ö',
            '&times;' => '×',
            '&Oslash;' => 'Ø',
            '&Ugrave;' => 'Ù',
            '&Uacute;' => 'Ú',
            '&Ucirc;' => 'Û',
            '&Uuml;' => 'Ü',
            '&Yacute;' => 'Ý',
            '&THORN;' => 'Þ',
            '&szlig;' => 'ß',
            '&agrave;' => 'à',
            '&aacute;' => 'á',
            '&acirc;' => 'â',
            '&atilde;' => 'ã',
            '&auml;' => 'ä',
            '&aring;' => 'å',
            '&aelig;' => 'æ',
            '&ccedil;' => 'ç',
            '&egrave;' => 'è',
            '&eacute;' => 'é',
            '&ecirc;' => 'ê',
            '&euml;' => 'ë',
            '&igrave;' => 'ì',
            '&iacute;' => 'í',
            '&icirc;' => 'î',
            '&iuml;' => 'ï',
            '&eth;' => 'ð',
            '&ntilde;' => 'ñ',
            '&ograve;' => 'ò',
            '&oacute;' => 'ó',
            '&ocirc;' => 'ô',
            '&otilde;' => 'õ',
            '&ouml;' => 'ö',
            '&divide;' => '÷',
            '&oslash;' => 'ø',
            '&ugrave;' => 'ù',
            '&uacute;' => 'ú',
            '&ucirc;' => 'û',
            '&uuml;' => 'ü',
            '&yacute;' => 'ý',
            '&thorn;' => 'þ',
            '&yuml;' => 'ÿ'
        };
    
        for (String key : htmlEntities.keySet()) {
            text = text.replace(key, htmlEntities.get(key));
        }
    
        return text;
    }

    public class NaverNewsArticle {
        @AuraEnabled public String title        {get;set;}
        @AuraEnabled public String description  {get;set;}
        @AuraEnabled public String url          {get;set;}
        @AuraEnabled public Integer totalResults {get;set;}
    }
}