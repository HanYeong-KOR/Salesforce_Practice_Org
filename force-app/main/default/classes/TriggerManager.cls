/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 01-04-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class TriggerManager {
    @TestVisible private static TriggerManager instance = null;
    private final List<TriggerHandler> handlers;
    @TestVisible private Boolean isExecuting;
    @TestVisible private TriggerOperation operationType;
    private Integer currIndex = -1;
    @TestVisible private List<SObject> news;
    @TestVisible private List<SObject> olds;
    @TestVisible private Map<Id, SObject> newMap;
    @TestVisible private Map<Id, SObject> oldMap;
    
    @TestVisible private static Boolean onceRun = true;
    @TestVisible private static Boolean avoidRecursion() {
        if(onceRun) {
            onceRun=false;
            return true;
        } else {
            return onceRun;
        }
    }

    public TriggerManager() {
        handlers = new List<TriggerHandler>();
    }

    public static TriggerManager prepare(){
        instance = new TriggerManager();
        instance.setting();
        return instance;
    } 

    private void setting(){
        this.isExecuting = trigger.isExecuting;
        this.operationType = trigger.operationType;
        this.news = trigger.new;
        this.olds = trigger.old;
        this.newMap = trigger.newMap;
        this.oldMap = trigger.oldMap;
    }

    public TriggerManager bind(TriggerHandler handler) {
        handler.setting(isExecuting, operationType);
        handlers.add(handler);

        return instance;
    }

    private void reset() {
        this.currIndex = -1;
    }

    private Boolean hasNext() {
        return this.currIndex < this.handlers.size() - 1;
    }

    private void next() {
        while (hasNext()) {
            runNext().execute(news, olds, newMap, oldMap);
        }
    }

    public void execute() {
        reset();

        while (hasNext()) {
            runNext().execute(news, olds, newMap, oldMap);
        }
    }

    public TriggerHandler runNext() {
        this.currIndex++;
        TriggerHandler handler = this.handlers[this.currIndex];

        return handler;
    }

}