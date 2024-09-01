/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-23-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class OpportunityTriggerController extends TriggerHandler {
    public static Boolean avoidRecursion = false;

    public override void onBeforeInsert(List<SObject> news) {
        try {
            if(isExecuting && !OpportunityTriggerController.avoidRecursion) {
                System.debug('Opportunity BEFORE INSERT');

            }   
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }
    public override void onBeforeUpdate(List<SObject> olds, List<SObject> news, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        try {
            if(isExecuting && !OpportunityTriggerController.avoidRecursion) {
                System.debug('Opportunity BEFORE UPDATE');

                for (SObject sObj : news) {
                    if((String) sObj.get('StageName') == 'Proposal/Price Quote') {

                    }
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
            System.debug('Opportunity BEFORE DELETE');

            if(isExecuting && !OpportunityTriggerController.avoidRecursion) {

            }   
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }
    public override void onAfterInsert(List<SObject> news, Map<Id, SObject> newMap) {
        try {
            if(isExecuting && !OpportunityTriggerController.avoidRecursion) {
                OpportunityTriggerController.avoidRecursion = true;
                System.debug('Opportunity AFTER INSERT');
            }   
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }	
    public override void onAfterUpdate(List<SObject> olds, List<SObject> news, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        try {
            if(isExecuting && !OpportunityTriggerController.avoidRecursion) {
                OpportunityTriggerController.avoidRecursion = true;
                System.debug('Opportunity AFTER UPDATE');
                
                for(SObject sObj : news) {}
            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    public override void onAfterDelete(List<SObject> dels, Map<Id, SObject> delMap) {
        try {
            if(isExecuting && !OpportunityTriggerController.avoidRecursion) {
                OpportunityTriggerController.avoidRecursion = true;
                System.debug('Opportunity AFTER DELETE');

            }   
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }
}