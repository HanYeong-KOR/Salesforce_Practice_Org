/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 08-14-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class FoodRecipe {
    @AuraEnabled
    public static List<RecipeWrapper> getFoodRecipe(String foodName, String ingredients, Integer page) {
        List<RecipeWrapper> result = new List<RecipeWrapper>();
        try {
            String apiKey = '8bec30425d8e423bb61989214f8f6362';
            String apiURL = 'https://api.spoonacular.com/recipes/complexSearch?apiKey=' + apiKey;
            apiURL += '&query=' + (foodName == '' ? '' : EncodingUtil.urlEncode(foodName, 'UTF-8'));
            apiURL += '&includeIngredients=' + (ingredients == '' ? '' : EncodingUtil.urlEncode(ingredients, 'UTF-8'));
            apiURL += '&offset=2';
    
            Http http           = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiURL);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
    
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                List<Object> jsonItems = (List<Object>) jsonResponse.get('results');

                for(Object item : jsonItems) {
                    RecipeWrapper recipe = new RecipeWrapper();
                    recipe.title = (String) ((Map<String, Object>)item).get('title');
                    recipe.image = (String) ((Map<String, Object>)item).get('image');
                    result.add(recipe);
                }
            } else {
                System.debug('API 오류: ' + response.getBody());
                throw new AuraHandledException('API 호출 중 오류 발생');
            }
            
            return result;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class RecipeWrapper {
        @AuraEnabled public String title    {get;set;}
        @AuraEnabled public String image    {get;set;}
    }
}