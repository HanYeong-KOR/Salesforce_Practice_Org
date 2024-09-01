/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-27-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class ForecastChartController {
    @AuraEnabled
    public static Map<String, Object> getLoaded() {
        Map<String, Object> result = new Map<String, Object>();

        try {
            result.put('months',  getMonths());
            result.put('datas',   getChartData('All', 'Stacked'));
            result.put('target',  getTarget());

            return result;

        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void setTarget(Long value) {
        try {
            forecast_target__c  ft = [
                SELECT Id,
                        Target__c
                FROM forecast_target__c
                LIMIT 1
            ];

            ft.Target__c = value;

            update ft;
            
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> setFilter(String chance, String type) {
        try {
            return getChartData(chance, type);
            
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<String> getMonths() {
        List<String> result = new List<String>();

        try {
            result.add('Jan');
            result.add('Feb');
            result.add('Mar');
            result.add('Apr');
            result.add('May');
            result.add('Jun');
            result.add('Jul');
            result.add('Aug');
            result.add('Sep');
            result.add('Oct');
            result.add('Nov');
            result.add('Dec');

            return result;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, Object> getChartData(String chance, String type) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            List<ChartDataWrapper> cdwList = new List<ChartDataWrapper>();

            ChartDataWrapper opFcRow    = new ChartDataWrapper();
            opFcRow.label               = 'Opportunity Forecasting';
            // opFcRow.data                = new List<Long>{200000, 300000, 400000, 500000, 600000, 700000, 800000, 900000, 1000000, 1100000, 1200000, 1300000};
            opFcRow.data                = opptyRowDatas(chance, type);
            opFcRow.backgroundColor     = 'rgba(125, 191, 239, 0.5)';
            opFcRow.stack               = 'Stack';
            
            cdwList.add(opFcRow);

            ChartDataWrapper goalsChart = new ChartDataWrapper();
            goalsChart.label            = 'Target';
            // goalsChart.data             = new List<Long>{10000000, 20000000, 30000000, 40000000, 50000000, 60000000, 70000000, 80000000, 90000000, 100000000, 110000000, 120000000};
            goalsChart.data             = getTargetData(type);
            goalsChart.backgroundColor  = 'rgba(238, 15, 18, 0.9)';
            goalsChart.type             = 'line';

            cdwList.add(goalsChart);
            
            result.put('chartRow', cdwList);

            return result;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<Long> opptyRowDatas(String chance, String type) {
        List<Long> result = new List<Long>();
        for(Long i = 0; i < 12; i++) {
            result.add(0);
        }

        try {
            // List<Opportunity> opptyList = [
            //     SELECT Id,
            //             Amount,
            //             CloseDate
            //     FROM Opportunity
            // ];

            String query = 'SELECT Id, Amount, CloseDate FROM Opportunity';
            if(chance != 'All') {
                query += ' WHERE Probability >= ' + Integer.valueOf(chance);
            }
            List<Opportunity> opptyList = Database.query(query);

            if(!opptyList.isEmpty()) {
                Map<String, Long> amountForMonth = new Map<String, Long>();
                if(type == 'monthType') {
                    String month;
                    for(Opportunity oppty : opptyList) {
                        month = convertMonth(oppty.CloseDate.month());
    
                        if(amountForMonth.keySet().contains(month)) {
                            Long addAmount = amountForMonth.get(month) + (Long) oppty.Amount;
                            amountForMonth.put(month, addAmount);
                        } else {
                            amountForMonth.put(month, (Long) oppty.Amount);
                        }
                    }
                    
                    for(String key : amountForMonth.keySet()) {
                        Integer index = Integer.valueOf(key);
                        result.set(index, amountForMonth.get(key));
                    }
                } else {
                    String month;
                    for (Opportunity oppty : opptyList) {
                        month = convertMonth(oppty.CloseDate.month());
                
                        if (amountForMonth.keySet().contains(month)) {
                            Long addAmount = amountForMonth.get(month) + (Long) oppty.Amount;
                            amountForMonth.put(month, addAmount);
                        } else {
                            amountForMonth.put(month, (Long) oppty.Amount);
                        }
                    }
                    
                    Long cumulativeAmount = 0;
                    for (Integer i = 0; i < 12; i++) {
                        String monthKey = String.valueOf(i);
                        if (amountForMonth.containsKey(monthKey)) {
                            cumulativeAmount += amountForMonth.get(monthKey);
                        }
                        result.set(i, cumulativeAmount);
                    }
                }
            }

            return result;
            
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String convertMonth(Integer month) {
        String result;
        try {
            switch on month {
                when 1 {
                    result = '0';
                }
                when 2 {
                    result = '1';
                }
                when 3 {
                    result = '2';
                }
                when 4 {
                    result = '3';
                }
                when 5 {
                    result = '4';
                }
                when 6 {
                    result = '5';
                }
                when 7 {
                    result = '6';
                }
                when 8 {
                    result = '7';
                }
                when 9 {
                    result = '8';
                }
                when 10 {
                    result = '9';
                }
                when 11 {
                    result = '10';
                }
                when 12 {
                    result = '11';
                }
                
            }

            return result;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<PicklistEntry> getPicklist(String objname, String fields) {
        List<PicklistEntry> result = new List<PicklistEntry>{new PicklistEntry('--None--', '')};

        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{objname});
        for(Schema.DescribeSobjectResult res : results) 
        {    
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fields).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    result.add(new PicklistEntry(entry));  
                }
            }
            
        }
        return result;
    }

    private static Long getTarget() {
        try {
            forecast_target__c ft = [
                SELECT Id,
                        Target__c
                FROM forecast_target__c
                LIMIT 1
            ];

            return (LONG) ft.Target__c;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<Long> getTargetData(String type) {
        List<Long> result = new List<Long>();

        try {
            forecast_target__c ft = [
                SELECT Id,
                        Target__c
                FROM forecast_target__c
                LIMIT 1
            ];

            if(type == 'Stacked') {
                for(Integer i = 0; i < 12; i++) {
                    Decimal value = ft.Target__c / 12 * (i + 1);
                    Long target = (Long) value.setScale(0, RoundingMode.HALF_UP);
                    result.add(target);
                }
            } else {
                for(Integer i = 0; i < 12; i++) {
                    Decimal value = ft.Target__c / 12;
                    Long target = (Long) value.setScale(0, RoundingMode.HALF_UP);
                    result.add(target);
                }
            }

            return result;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
    
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ChartDataWrapper {
        @AuraEnabled public String     label           {get;set;}
        @AuraEnabled public List<Long> data            {get;set;}
        @AuraEnabled public String     backgroundColor {get;set;}
        @AuraEnabled public String     type            {get;set;}
        @AuraEnabled public String     stack           {get;set;}
    }

    public class PicklistEntry {
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}

        public PicklistEntry(Schema.PicklistEntry entry) {
            this.label = entry.getLabel();
            this.value = entry.getValue();
        }

        public PicklistEntry(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}