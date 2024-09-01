/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-18-2024
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-02-2024   Hanyeong Choi   Initial Version
**/
public with sharing class DN_TicketTrainingController {
    private static final String     sessionId                   = fetchUserSessionId();
    private static final Integer    METADATA_API_VERSION        = Integer.valueOf(createService().endpoint_x.substringAfterLast('/'));
    private static final MetadataService.MetadataPort service   = createService();
    
    /**
     * @Description
     * 	- Ticket List View에 New Ticket 버튼을 누르고 Next버튼을 누를 때 Init
     * @author Hanyeong Choi | 07-02-2024
     * @Parameter
     *  - objectName        : Case
     *  - recordTypeName    : Case의 RecordType Name
    **/ 
    @AuraEnabled
    public static Map<String, Object> getNextInit(String objectName, String recordTypeName) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('retrieveObjectLayout',      retrieveObjectLayout(objectName, recordTypeName));
            // result.put('getRecordTypeId',           getRecordTypeId(recordTypeName));
            result.put('getFormulaFieldCondition',  getFormulaFieldCondition(objectName));
            
            return result;
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- Map정보를 바탕으로 Ticket 레코드 insert
     * @author Hanyeong Choi | 07-02-2024
     * @Parameter
     *  - fieldMap      : Ticket 생성 모달에서 입력한 각 key 필드명, value 필드값 Map
    **/ 
    @AuraEnabled
    public static String saveTicket(String objectName, Map<String, Object> fieldMap, String recordTypeId) {
        String result;
        try {
            Case newRecord = new Case();
        
            // newRecord.put('RecordTypeId', Id.valueOf(recordTypeId));
            for (String fieldName : fieldMap.keySet()) {
                String fieldType = getFieldType(fieldName);

                if(fieldType != 'formula' && fieldMap.get(fieldName) != null) {
                    switch on fieldType {
                        when 'LONG', 'INTEGER'{
                            String IntegerValue = (String) fieldMap.get(fieldName);
                            newRecord.put(fieldName, Integer.valueOf(IntegerValue));
                        }
                        when 'DOUBLE', 'CURRENCY', 'PERCENT'{
                            String decimalValue = (String) fieldMap.get(fieldName);
                            newRecord.put(fieldName, Double.valueOf(decimalValue));
                        }
                        when 'DATE' {
                            String dateValue = (String) fieldMap.get(fieldName);
                            newRecord.put(fieldName, Date.valueOf(dateValue));
                        }
                        when 'DATETIME'  {
                            String datetimeValue = (String) fieldMap.get(fieldName);
    
                            if (datetimeValue.endsWith('Z')) {
                                datetimeValue = datetimeValue.substring(0, datetimeValue.length() - 1);
                            }
                            newRecord.put(fieldName, Datetime.valueOf(datetimeValue.replace('T', ' ')));
                        }
                        when 'BOOLEAN' {
                            String booleanValue = (String) fieldMap.get(fieldName);
                            newRecord.put(fieldName, Boolean.valueOf(booleanValue));
                        }
                        when else {
                            newRecord.put(fieldName, fieldMap.get(fieldName));
                        }
                    }
                }
            }

            insert newRecord;

            result = 'success';
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            result = e.getMessage().substringAfter('error:');
        }
        return result;
    }

    /**
     * @Description
     * 	- lookup 필드의 onchange로 연관되어 있는 formula 필드에 들어갈 값 찾기
     * @author Hanyeong Choi | 07-03-2024
     * @Parameter
     *  - objectName        : Case
     *  - lookupFieldMap    : onchange된 lookup 필드의 Object API, recordId Map
     *  - formulaFieldMap   : Case Object의 formula 필드 API명, formula 조건 Map 
    **/ 
    @AuraEnabled
    public static Map<String, String> setFormulaField(String objectName, Map<String, String> lookupFieldMap, Map<String, String> formulaFieldMap) {
        Map<String, String> resMap = new Map<String, String>();
        
        try {
            Map<String, String> objectIdMap = new Map<String, String>();
            for(String key : lookupFieldMap.keySet()) {
                Id      objectId    = (Id) lookupFieldMap.get(key);
                String  objectAPI   = (String) objectId.getSObjectType().getDescribe().getName();
                objectIdMap.put('object',   objectAPI);
                objectIdMap.put('recordId', (String) objectId);

                String modifiedKey = key;
                if(key.endsWith('Id')) {
                    modifiedKey = key.substring(0, key.length() - 2);
                } else if(key.endsWith('__c')) {
                    modifiedKey = key.substring(0, key.length() - 3) + '__r';
                }
                objectIdMap.put('matchField', modifiedKey);
            }

            System.debug('formulaFieldMap :::' + formulaFieldMap);
            System.debug('objectIdMap :::' + objectIdMap);
            List<String> queryField     = new List<String>();
            List<String> formulaField   = new List<String>();
            for(String key : formulaFieldMap.keySet()) {
                String formulaCondition = formulaFieldMap.get(key);
                if(objectIdMap.get('matchField') == formulaCondition.substringBefore('.')) {
                    queryField.add(formulaCondition.substringAfter('.'));
                    formulaField.add(key);
                }
            }

            if(!queryField.isEmpty()) {
                String  query = 'SELECT ' + String.join(queryField, ', ');
                        query += ' FROM ' + objectIdMap.get('object');
                        query += ' WHERE Id = ' + '\'' + objectIdMap.get('recordId') + '\'';
                        query += ' LIMIT 1';
                
                List<sObject> sObjectList = Database.query(query);

                if(!sObjectList.isEmpty()) {
                    sObject record = sObjectList[0];
                    for (String field : formulaField) {
                        String queryFieldName = formulaFieldMap.get(field).substringAfter('.');
                        if(queryField.contains(queryFieldName)) {
                            resMap.put(field, String.valueOf(record.get(queryFieldName)));
                        }
                    }
                }
            }

            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'fail');
        }
        return resMap;
    }

    /**
     * @Description
     * 	- 해당 Object의 Formula필드 API명, Formula 조건 Map 반환 
     * @author Hanyeong Choi | 07-03-2024
     * @Parameter
     *  - objectName    : Case 
    **/ 
    private static Map<String, String> getFormulaFieldCondition(String objectName) {
        Map<String, String> resMap = new Map<String, String>();

        Map<String, Schema.SObjectField>    objectFields        = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        List<String>                        customFieldNames    = new List<String>();
        
        System.debug('objectFields ::: ' + objectFields);
        for (String fieldName : objectFields.keySet()) {
            if (fieldName.endsWith('__c')) {
                Schema.DescribeFieldResult describeField = objectFields.get(fieldName).getDescribe();
                if (describeField.isCalculated()) {
                    customFieldNames.add(describeField.getName());
                }
            }
        }

        for(String field : customFieldNames) {
            MetadataService.CustomField customField = (MetadataService.CustomField) service.readMetadata(
                'CustomField', new String[] { objectName + '.' + field }
            ).getRecords()[0];

            resMap.put(field, customField.formula);
        }
        
        return resMap;
    }

    /**
     * @Description
     * 	- Case의 RecordType 별 layout정보
     * @author Hanyeong Choi | 07-02-2024
     * @Parameter
     *  - objectName        : Case
     *  - recordTypeName    : Case RecordType Name
    **/ 
    private static PageLayout retrieveObjectLayout(String objectName, String recordTypeName) {
        recordTypeName = 'Case Layout';
        String layoutFullName;
        if(recordTypeName == 'Ticket') {
            layoutFullName = objectName + '-Ticket Layout';
        } else if(recordTypeName == 'VOC') {
            layoutFullName = objectName + '-VOC Layout';
        } else {
            layoutFullName = objectName + '-Case Layout';
        }

        if(!Test.isRunningTest()) {
            MetadataService.Layout layoutMetadata = (MetadataService.Layout) service.readMetadata('Layout', new String[] { layoutFullName }).getRecords()[0];
            PageLayout pageLayout = new PageLayout(layoutMetadata);

            return pageLayout;
        } else {
            PageLayout pageLayout = new PageLayout();
            return pageLayout;
        }
    }

    /**
     * @Description
     * 	- Case의 RecordTypeId
     * @author Hanyeong Choi | 07-02-2024
     * @Parameter
     *  - recordTypeName    : 선택한 Case의 RecordType Name
    **/ 
    private static String getRecordTypeId(String recordTypeName) {
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :recordTypeName
            AND SobjectType = 'Case'
            LIMIT 1
        ];

        return rt.Id;
    }

    /**
     * @Description
     * 	- Case의 Field Type
     * @author Hanyeong Choi | 07-02-2024
     * @Parameter
     *  - fieldName     : 타입을 조회할 Field Name
    **/ 
    private static String getFieldType(String fieldName){
        Schema.DescribeFieldResult  fieldDescribe   = Schema.SObjectType.Case.fields.getMap().get(fieldName).getDescribe();
        Schema.DisplayType          fieldType       = fieldDescribe.getType();
        
        if (fieldDescribe.isCalculated()) {
            return 'formula';
        } else {
            return fieldType.name();
        }
    }

    /**
     * @Description
     * 	- MetadataService를 이용하기 위한 createService
     * @author Hanyeong Choi | 07-02-2024
     * @Parameter
    **/ 
    private static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service    = new MetadataService.MetadataPort();
        service.SessionHeader                   = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId         = sessionId;
        return service;
    }

    /**
     * @Description
     * 	- User Id 조회
     * @author Hanyeong Choi | 07-02-2024
     * @Parameter
    **/ 
    private static String fetchUserSessionId(){
        String sessionId = '';

        if(!Test.isRunningTest()) {
            PageReference   reportPage  = Page.GetSessionIdVF;
            String          vfContent   = reportPage.getContent().toString();
            Integer         startP      = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),

            endP        = vfContent.indexOf('End_Of_Session_Id');
            sessionId   = vfContent.substring(startP, endP);
        } else {
            User user = [SELECT Id FROM User LIMIT 1];
            sessionId = user.id;
        }
        return sessionId;
    }

    /**
     * @Description
     * 	- MetadataServiceException
     * @author Hanyeong Choi | 07-02-2024
    **/ 
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

            this.methodName     = methodName;
            this.errorMessage   = errorMessage;
        }
    }

    /**
     * @Description
     * 	- MetadataService.Layout Wrapper
     * @author Hanyeong Choi | 07-02-2024
    **/ 
    public class PageLayout {
        @AuraEnabled public List<LayoutSection> layoutSectionList{get;set;}

        public PageLayout(){}

        public PageLayout(MetadataService.Layout pageLayout){
            this.layoutSectionList = new List<LayoutSection>();

            if (pageLayout.layoutSections != null) {
                Integer i = 1;
                for (MetadataService.LayoutSection section : pageLayout.layoutSections) {
                    if (section.style != 'CustomLinks') {
                        this.layoutSectionList.add(new LayoutSection(section.label, i, section.detailHeading, section.style, section));
                        i++;
                    }
                }
            }
        }
    }

    /**
     * @Description
     * 	- MetadataService.Layout의 LayoutSection Wrapper
     * @author Hanyeong Choi | 07-02-2024
    **/ 
    public class LayoutSection {
        @AuraEnabled public String              sectionLabel        {get;set;}
        @AuraEnabled public String              sectionStyle        {get;set;}
        @AuraEnabled public String              indexId             {get;set;}
        @AuraEnabled public Integer             sectionIndex        {get;set;}
        @AuraEnabled public Boolean             detailHeading       {get;set;}
        @AuraEnabled public List<layoutColumn>  layoutColumnList    {get;set;}

        public LayoutSection(){}

        public LayoutSection(String sectionLabel, Integer index, Boolean detailHeading, String sectionStyle, MetadataService.LayoutSection section){
            this.sectionLabel       = sectionLabel;
            this.sectionStyle       = sectionStyle;
            this.sectionIndex       = index;
            this.indexId            = 'section' + index;
            this.detailHeading      = detailHeading;
            this.layoutColumnList   = new List<layoutColumn>();

            if (section.layoutColumns != null) {
                Integer i = 1;
                for (MetadataService.LayoutColumn column : section.layoutColumns) {
                    this.layoutColumnList.add(new LayoutColumn(i, column, this.indexId));
                    i++;
                }
            }

        }
    }

    /**
     * @Description
     * 	- LayoutSection의 LayoutColumn Wrapper
     * @author Hanyeong Choi | 07-02-2024
    **/ 
    public class LayoutColumn {
        @AuraEnabled public String              indexId         {get;set;}
        @AuraEnabled public Integer             columnIndex     {get;set;}
        @AuraEnabled public List<LayoutItem>    layoutItemList  {get;set;}

        public LayoutColumn(){}

        public LayoutColumn(Integer index, MetadataService.LayoutColumn column, String indexId){
            this.indexId        = indexId + '-column' + index;
            this.columnIndex    = index;
            this.layoutItemList = new List<LayoutItem>();

            if (column.layoutItems != null) {
                Integer i = 1;
                for (MetadataService.LayoutItem item : column.layoutItems) {
                    this.layoutItemList.add(new LayoutItem(i, item, this.indexId));
                    i++;   
                }
            }
        }
    }

    /**
     * @Description
     * 	- LayoutColumn의 LayoutItem Wrapper
     * @author Hanyeong Choi | 07-02-2024
    **/ 
    public class LayoutItem {
        @AuraEnabled public String  item        {get;set;}
        @AuraEnabled public String  indexId     {get;set;}
        @AuraEnabled public Integer itemIndex   {get;set;}
        @AuraEnabled public String  itemType    {get;set;}
        @AuraEnabled public String  itemLabel   {get;set;}

        public LayoutItem(){}
        
        public LayoutItem(Integer index, MetadataService.LayoutItem item, String indexId){
            this.item       = item.field;
            this.indexId    = indexId + '-item' + index;
            this.itemIndex  = index;
            this.itemType   = getItemType(item.field);
            this.itemLabel  = getItemLabel(item.field);
        }

        private String getItemType(String fieldName){
            Schema.DescribeFieldResult  fieldDescribe   = Schema.SObjectType.Case.fields.getMap().get(fieldName).getDescribe();
            Schema.DisplayType          fieldType       = fieldDescribe.getType();
            
            if (fieldDescribe.isCalculated()) {
                return 'formula';
            } else {
                return fieldType.name();
            }
        }

        private String getItemLabel(String fieldName) {
            Schema.DescribeFieldResult fieldDescribe = Schema.SObjectType.Case.fields.getMap().get(fieldName).getDescribe();
            return fieldDescribe.getLabel();
        }
    }
}