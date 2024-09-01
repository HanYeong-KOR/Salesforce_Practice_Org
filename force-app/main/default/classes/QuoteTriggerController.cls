/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-28-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class QuoteTriggerController extends TriggerHandler {
    public static Boolean avoidRecursion = false;

    public override void onBeforeInsert(List<SObject> news) {
        try {
            if(isExecuting && !QuoteTriggerController.avoidRecursion) {
                System.debug('Quote BEFORE INSERT');

                for (SObject sObj : news) {

                }
            }   
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    public override void onBeforeUpdate(List<SObject> olds, List<SObject> news, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        try {
            if(isExecuting && !QuoteTriggerController.avoidRecursion) {
                System.debug('Quote BEFORE UPDATE');

                for (SObject sObj : news) {

                }
            }   
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public override void onBeforeDelete(List<SObject> dels, Map<Id, SObject> delMap) {
        try {
            System.debug('Quote BEFORE DELETE');

            if(isExecuting && !QuoteTriggerController.avoidRecursion) {

            }   
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    public override void onAfterInsert(List<SObject> news, Map<Id, SObject> newMap) {
        try {
            if(isExecuting && !QuoteTriggerController.avoidRecursion) {
                QuoteTriggerController.avoidRecursion = true;
                System.debug('Quote AFTER INSERT');

                for(SObject sObj : news) {

                }
            }   
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }	

    public override void onAfterUpdate(List<SObject> olds, List<SObject> news, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        try {
            if(isExecuting && !QuoteTriggerController.avoidRecursion) {
                QuoteTriggerController.avoidRecursion = true;
                System.debug('Quote AFTER UPDATE');
                
                for(SObject sObj : news) {
                    if((String) sObj.get('Status') == 'Accepted' && (Boolean) sObj.get('IsSyncing') == true) {
                        ConvertToContractController.setConvert((String) sObj.get('Id'));
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    public override void onAfterDelete(List<SObject> dels, Map<Id, SObject> delMap) {
        try {
            if(isExecuting && !QuoteTriggerController.avoidRecursion) {
                QuoteTriggerController.avoidRecursion = true;
                System.debug('Quote AFTER DELETE');

            }   
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }
}