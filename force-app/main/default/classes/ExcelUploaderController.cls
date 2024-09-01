/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 06-13-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class ExcelUploaderController {
    @AuraEnabled
    public static void uploadExcelFile(List<Map<String, Object>> data, String objectApiName) {
        try {
            SObjectType sObjectType     = Schema.getGlobalDescribe().get(objectApiName);
            ObjectImportController.SObjectConverter converter  = new ObjectImportController.SObjectConverter(data, sObjectType);
            List<SObject> sObjectList   = converter.getSObjects();

            insert sObjectList;

        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<OpportunityImportController.FieldWrapper> getObjectFields(String objectApiName) {
        try {
            List<Schema.SObjectField> fields    = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().values();
            List<OpportunityImportController.FieldWrapper> wrappers = new List<OpportunityImportController.FieldWrapper>();
            for(Schema.SObjectField field : fields) {
                if(field.getDescribe().isUpdateable()) {
                    OpportunityImportController.FieldWrapper wrapper = new OpportunityImportController.FieldWrapper(field.getDescribe().label, field.getDescribe().name);
                    wrappers.add(wrapper);
                }
            }

            return wrappers;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<LookupController.ObjectInfoWrapper> obtainObjectList(String searchKeyWord) {
        try {
            return LookupController.obtainObjectList(searchKeyWord);
            
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }
}