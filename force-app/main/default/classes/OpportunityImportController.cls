/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 06-11-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class OpportunityImportController {
    // Main Method
    @AuraEnabled
    public static List<FieldWrapper> getOpportunityFields() {
        try {
            List<Schema.SObjectField> fields    = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().values();
            List<FieldWrapper> wrappers         = new List<FieldWrapper>();
            for(Schema.SObjectField field : fields) {
                if(field.getDescribe().isUpdateable()) {
                    FieldWrapper wrapper = new FieldWrapper(field.getDescribe().label, field.getDescribe().name);
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
    public static void insertOpportunity(List<Map<String, Object>> tableData) {
        try {
            insertOpportunityWithDML(tableData, new RealDML());
        } catch(Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    static void insertOpportunityWithDML(List<Map<String, Object>> tableData, DMLInterface dmlInterface) {
        try {
            OpportunityConverter converter    = new OpportunityConverter(tableData);
            List<Opportunity> woList          = converter.getOpportunitys();

            dmlInterface.insertRecords(woList);
        } catch(Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Wrapper Class
    public class FieldWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}

        public FieldWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class OpportunityConverter {
        private List<Map<String, Object>>           tableData       {get;set;}
        private SObjectType                         woType          {get;set;}
        private Map<String, Schema.SObjectField>    fieldMap        {get;set;}

        public OpportunityConverter(List<Map<String, Object>> tableData) {
            this.woType             = Schema.getGlobalDescribe().get('Opportunity');
            this.fieldMap           = this.woType.getDescribe().fields.getMap();
            this.tableData          = tableData;
        }

        public List<Opportunity> getOpportunitys() {
            List<Opportunity> woList = new List<Opportunity>();
            for(Map<String, Object> row : this.tableData) {
                Opportunity wo = this.convertDataRowToOpportunity(row);
                woList.add(wo);
            }
            return woList;
        }

        private Opportunity convertDataRowToOpportunity(Map<String, Object> row) {
            SObject wo = this.woType.newSObject();
            for(String fieldName : row.keySet()) {
                if(row.get(fieldName) == null || String.valueOf(row.get(fieldName)) == '') continue;
                Object fieldValue;
                
                Schema.DisplayType fieldType = this.fieldMap.get(fieldName).getDescribe().getType();
                fieldValue = this.castFieldValue(fieldType, row.get(fieldName));
                wo.put(fieldName, fieldValue);
            }
            return (Opportunity) wo;
        }

        private Object castFieldValue(Schema.DisplayType fieldType, Object uncastedValue) {
            if(fieldType == Schema.DisplayType.INTEGER) {
                return Integer.valueOf(uncastedValue);
            } else if (fieldType == Schema.DisplayType.LONG) {
                return Long.valueOf(String.valueOf(uncastedValue));
            } else if (fieldType == Schema.DisplayType.DOUBLE ||
                fieldType == Schema.DisplayType.CURRENCY ||
                fieldType == Schema.DisplayType.PERCENT 
            ) {
                return Double.valueOf(uncastedValue);
            } else if (fieldType == Schema.DisplayType.DATE) {
                String dateStr = String.valueOf(uncastedValue);
                // yyyy.MM.dd 형식인 경우, yyyy-MM-dd 형식으로 변경
                // countMatches에서는 substring으로, replaceAll 에서는 regex로 찾음
                if(dateStr.countMatches('.') == 2) dateStr = dateStr.replaceAll('\\.', '-');
                return String.isBlank(dateStr) ? null : Date.valueOf(dateStr);
            } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                return Boolean.valueOf(uncastedValue);
            } else {
                return String.valueOf(uncastedValue);
            }
        }
    }

    // DML 인터페이스
    public interface DMLInterface {
        void insertRecords(List<Opportunity> sObjectList);
    }

    // 실제 DML 작업 클래스
    public class RealDML implements DMLInterface {
        public void insertRecords(List<Opportunity> sObjectList) {
            insert sObjectList;
        }
    }
}