/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 06-10-2024
 * @last modified by  : Hanyeong Choi
**/
// public with sharing class ObjectImportController {
    
//     // Main Method
//     @AuraEnabled
//     public static List<FieldWrapper> getObjectFields(String objectApiName) {
//         try {
//             List<Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().values();
//             List<FieldWrapper> wrappers = new List<FieldWrapper>();
//             for(Schema.SObjectField field : fields) {
//                 if(field.getDescribe().isUpdateable()) {
//                     FieldWrapper wrapper = new FieldWrapper(field.getDescribe().label, field.getDescribe().name);
//                     wrappers.add(wrapper);
//                 }
//             }

//             return wrappers;
//         } catch (Exception e) {
//             System.debug('Error : '       + e.getMessage());
//             System.debug('Line Number : ' + e.getLineNumber());
            
//             throw new AuraHandledException(e.getMessage());
//         }
//     }

//     @AuraEnabled
//     public static void insertSObjects(List<Map<String, Object>> tableData, String objectApiName) {
//         try {
//             SObjectType sObjectType     = Schema.getGlobalDescribe().get(objectApiName);
//             SObjectConverter converter  = new SObjectConverter(tableData, sObjectType);
//             List<SObject> sObjectList   = converter.getSObjects();

//             insert sObjectList;
//         } catch(Exception e) {
//             System.debug('Error : '       + e.getMessage());
//             System.debug('Line Number : ' + e.getLineNumber());
            
//             throw new AuraHandledException(e.getMessage());
//         }
//     }

//     // Wrapper Class
//     public class FieldWrapper {
//         @AuraEnabled public String label {get;set;}
//         @AuraEnabled public String value {get;set;}

//         public FieldWrapper(String label, String value) {
//             this.label = label;
//             this.value = value;
//         }
//     }

//     public class SObjectConverter {
//         private List<Map<String, Object>>           tableData   {get;set;}
//         private SObjectType                         sObjectType {get;set;}
//         private Map<String, Schema.SObjectField>    fieldMap    {get;set;}

//         public SObjectConverter(List<Map<String, Object>> tableData, SObjectType sObjectType) {
//             this.sObjectType    = sObjectType;
//             this.fieldMap       = this.sObjectType.getDescribe().fields.getMap();
//             this.tableData      = tableData;
//         }

//         public List<SObject> getSObjects() {
//             List<SObject> sObjectList = new List<SObject>();
//             for(Map<String, Object> row : this.tableData) {
//                 SObject obj = this.convertDataRowToSObject(row);
//                 sObjectList.add(obj);
//             }
//             return sObjectList;
//         }

//         private SObject convertDataRowToSObject(Map<String, Object> row) {
//             SObject obj = this.sObjectType.newSObject();
//             for(String fieldName : row.keySet()) {
//                 if(row.get(fieldName) == null || String.valueOf(row.get(fieldName)) == '') continue;
                
//                 Object fieldValue;    
//                 Schema.DisplayType fieldType    = this.fieldMap.get(fieldName).getDescribe().getType();
//                 fieldValue                      = this.castFieldValue(fieldType, row.get(fieldName));
//                 obj.put(fieldName, fieldValue);
//             }
//             return obj;
//         }

//         private Object castFieldValue(Schema.DisplayType fieldType, Object uncastedValue) {
//             if(fieldType == Schema.DisplayType.INTEGER) {
//                 return Integer.valueOf(uncastedValue);
//             } else if (fieldType == Schema.DisplayType.LONG) {
//                 return Long.valueOf(String.valueOf(uncastedValue));
//             } else if (fieldType == Schema.DisplayType.DOUBLE ||
//                 fieldType == Schema.DisplayType.CURRENCY ||
//                 fieldType == Schema.DisplayType.PERCENT 
//             ) {
//                 return Double.valueOf(uncastedValue);
//             } else if (fieldType == Schema.DisplayType.DATE) {
//                 String dateStr = String.valueOf(uncastedValue);
//                 // yyyy.MM.dd 형식인 경우, yyyy-MM-dd 형식으로 변경
//                 // countMatches에서는 substring으로, replaceAll 에서는 regex로 찾음
//                 if(dateStr.countMatches('.') == 2) dateStr = dateStr.replaceAll('\\.', '-');
//                 return String.isBlank(dateStr) ? null : Date.valueOf(dateStr);
//             } else if (fieldType == Schema.DisplayType.BOOLEAN) {
//                 return Boolean.valueOf(uncastedValue);
//             } else {
//                 return String.valueOf(uncastedValue);
//             }
//         }
//     }
// }

public with sharing class ObjectImportController {
    
    // Main Method
    @AuraEnabled
    public static List<FieldWrapper> getObjectFields(String objectApiName) {
        try {
            List<Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().values();
            List<FieldWrapper> wrappers = new List<FieldWrapper>();
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
    public static void insertSObjects(List<Map<String, Object>> tableData, String objectApiName) {
        insertSObjectsWithDML(tableData, objectApiName, new RealDML());
    }

    @TestVisible
    static void insertSObjectsWithDML(List<Map<String, Object>> tableData, String objectApiName, DMLInterface dmlInterface) {
        try {
            SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            SObjectConverter converter = new SObjectConverter(tableData, sObjectType);
            List<SObject> sObjectList = converter.getSObjects();

            dmlInterface.insertRecords(sObjectList);
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

    public class SObjectConverter {
        private List<Map<String, Object>> tableData {get;set;}
        private SObjectType sObjectType {get;set;}
        private Map<String, Schema.SObjectField> fieldMap {get;set;}

        public SObjectConverter(List<Map<String, Object>> tableData, SObjectType sObjectType) {
            this.sObjectType = sObjectType;
            this.fieldMap = this.sObjectType.getDescribe().fields.getMap();
            this.tableData = tableData;
        }

        public List<SObject> getSObjects() {
            List<SObject> sObjectList = new List<SObject>();
            for(Map<String, Object> row : this.tableData) {
                SObject obj = this.convertDataRowToSObject(row);
                sObjectList.add(obj);
            }
            return sObjectList;
        }

        private SObject convertDataRowToSObject(Map<String, Object> row) {
            SObject obj = this.sObjectType.newSObject();
            for(String fieldName : row.keySet()) {
                if(row.get(fieldName) == null || String.valueOf(row.get(fieldName)) == '') continue;
                
                Object fieldValue;    
                Schema.DisplayType fieldType = this.fieldMap.get(fieldName).getDescribe().getType();
                fieldValue = this.castFieldValue(fieldType, row.get(fieldName));
                obj.put(fieldName, fieldValue);
            }
            return obj;
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
        void insertRecords(List<SObject> sObjectList);
    }

    // 실제 DML 작업 클래스
    public class RealDML implements DMLInterface {
        public void insertRecords(List<SObject> sObjectList) {
            insert sObjectList;
        }
    }
}