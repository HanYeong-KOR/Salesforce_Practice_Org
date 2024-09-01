/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-28-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class GuessNumberGameController {
    private static final String sessionId = fetchUserSessionId();
    private static final MetadataService.MetadataPort service = createService();

    @AuraEnabled
    public static String checkGuess(Integer randomResult, Integer guess, String player, Integer chance) {
        if(guess != null && guess != 0) {
            if (guess < randomResult) {
                return '보다 큽니다.';
            } else if (guess > randomResult) {
                return '보다 작습니다.';
            } else {
                saveScore(player, chance);
                return '정답입니다!';
            }
        } else {
            return '빈값';
        }
    }

    @AuraEnabled
    public static void saveResult(Integer randomNumber) {
        List<MetadataService.CustomMetadata> customMetadataToInsert = new List<MetadataService.CustomMetadata>();
        MetadataService.CustomMetadata customMetadata = new MetadataService.CustomMetadata();

        try {
            customMetadata.fullName = 'result__mdt.result';
            customMetadata.label = 'result';
            customMetadata.values = new List<MetadataService.CustomMetadataValue>();
            customMetadata.values.add(generateMetadataValue('result__c', String.valueOf(randomNumber)));
            customMetadataToInsert.add(customMetadata);

            if( customMetadataToInsert.size() > 0) {
                List<MetadataService.SaveResult> results = service.createMetadata(customMetadataToInsert);
                if(!Test.isRunningTest()) for(MetadataService.SaveResult sr : results) { handleSaveResults(sr); }
            }

        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteResult() {
        List<String> customMetadataListToDelete = new List<String>();

        try {
            List<result__mdt> result = [SELECT Id FROM result__mdt];
            if(!result.isEmpty()) {
                customMetadataListToDelete.add('result__mdt.result');
            }

            if (customMetadataListToDelete.size() > 0) {
                List<MetadataService.DeleteResult> deleteResults = service.deleteMetadata('CustomMetadata', customMetadataListToDelete);
                if(!Test.isRunningTest()) for(MetadataService.DeleteResult dr : deleteResults){ handleDeleteResults(dr); }
            }

        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void savePlayer(String player) {
        try {
            List<PlayerInfo__c> players = [SELECT Id, Name, Score__c, GameCount__c, Success__c, Fail__c FROM PlayerInfo__c WHERE Name =: player];

            if(players.isEmpty()) {
                PlayerInfo__c pi = new PlayerInfo__c();
                pi.Name = player;
                pi.Score__c = 0;
                pi.GameCount__c = 1;
                pi.Success__c = 0;
                pi.Fail__c = 0;
                
                insert pi;
            } else {
                players[0].GameCount__c += 1;

                update players[0];
            }

        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void failScore(String player) {
        try {
            List<PlayerInfo__c> players = [SELECT Id, Name, Fail__c FROM PlayerInfo__c WHERE Name =: player LIMIT 1];

            if(!players.isEmpty()) {
                players[0].Fail__c += 1;

                update players[0];
            }

        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void saveScore(String player, Integer chance) {
        try {
            List<PlayerInfo__c> players = [SELECT Id, Name, Success__c, Score__c FROM PlayerInfo__c WHERE Name =: player LIMIT 1];

            if(!players.isEmpty()) {
                players[0].Success__c += 1;
                players[0].Score__c += ((chance - 1) * 10) + 10;

                update players[0];
            }

        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static MetadataService.CustomMetadataValue generateMetadataValue(String mdtFieldName, String mdtFieldValue){
        MetadataService.CustomMetadataValue mdtValue = new MetadataService.CustomMetadataValue();
        mdtValue.field = mdtFieldName;
        mdtValue.value = mdtFieldValue;
        return mdtValue;
    }

    private static void handleSaveResults(MetadataService.SaveResult saveResult){
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0 && !Test.isRunningTest())
                throw new MetadataServiceException('handleSaveResults', String.join(messages, ' '));

        }
        if(!saveResult.success && !Test.isRunningTest())
            throw new MetadataServiceException('handleSaveResults', 'Request failed with no specified error.');
    }

    private static void handleDeleteResults(MetadataService.DeleteResult deleteResult){
        // Nothing to see?
        if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0 && !Test.isRunningTest())
                throw new MetadataServiceException('handleDeleteResults', String.join(messages, ' '));
        }
        if(!deleteResult.success && !Test.isRunningTest())
            throw new MetadataServiceException('handleDeleteResults', 'Request failed with no specified error.');
    }

    private static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;

        return service;
    }

    private static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page 
        PageReference reportPage = Page.GetSessionIdVF;
        // Get the content of the VF page
        if(!Test.isRunningTest()){
            String vfContent = reportPage.getContent().toString();
        
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
            // Get the Session Id
            sessionId = vfContent.substring(startP, endP);
        } else {
            User user = [SELECT Id FROM User LIMIT 1];
            sessionId = user.Id;
        }        
        // Return Session Id
        return sessionId;
    }

    public class MetadataServiceException extends Exception {
        public String methodName;
        public String errorMessage;

        public MetadataServiceException(
            String methodName,
            String errorMessage
        ){
            System.debug('MetadataServiceException');
            System.debug('methodName ::: ' + methodName);
            System.debug('errorMessage ::: ' + errorMessage);

            this.methodName = methodName;
            this.errorMessage = errorMessage;
        }
    }
}