/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 01-04-2024
 * @last modified by  : Hanyeong Choi
**/
public virtual with sharing class TriggerHandler {

    private static User currentUser;
    public Boolean isExecuting;
    public TriggerOperation operationType;
    public String currentClassName;
    public static User currentUserInfo;

    public TriggerHandler(){
        if(currentUser == null) TriggerHandler.currentUser = [SELECT Id, Division, Profile.name FROM User WHERE Id = :UserInfo.getUserId()];
        this.currentClassName = String.valueOf(this).split(':')[0];
    }

    public void setting(Boolean isExecuting, TriggerOperation operationType){
        this.isExecuting = isExecuting;
        this.operationType = operationType;
    }

    public void execute( List<SObject> news, List<SObject> olds, Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        try {
            switch on operationType {
                when BEFORE_INSERT {
                    this.onBeforeInsert(news);
                }
                when AFTER_INSERT {
                    this.onAfterInsert(news,  newMap);
                }
                when BEFORE_UPDATE {
                    this.onBeforeUpdate(olds, news, oldMap, newMap);
                }
                when AFTER_UPDATE {
                    this.onAfterUpdate(olds, news, oldMap, newMap);
                }
                when BEFORE_DELETE {
                    this.onBeforeDelete(olds, oldMap);
                }
                when AFTER_DELETE {
                    this.onAfterDelete(olds, oldMap);
                }
            }
        } catch(Exception ex){
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
            System.debug(ex.getTypeName());
            System.debug(currentClassName);
        }
    }

    public virtual void onBeforeInsert(List<sObject> news){}
    public virtual void onBeforeInsert(sObject newRecord){}
                                    
    public virtual void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){}
    public virtual void onBeforeUpdate(sObject oldRecord, sObject newRecord){}

    public virtual void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){}
    public virtual void onBeforeDelete(sObject delRecord){}

    public virtual void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){}
    public virtual void onAfterInsert(sObject newRecord){}
                                                                            
    public virtual void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){}
    public virtual void onAfterUpdate(sObject oldRecord, sObject newRecord){}

    public virtual void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap){}
    public virtual void onAfterDelete(sObject delRecord){}
}