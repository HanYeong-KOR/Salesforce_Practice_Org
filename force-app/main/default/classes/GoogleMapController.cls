/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 01-03-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class GoogleMapController {
    // Main Method
    @AuraEnabled
    public static Map<String, Object> getInitDatas(String recordId) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            result.put('getInitDatas', getLocataion(recordId));
        
            return result;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Utill Method
    private static List<LocationWrapper> getLocataion(String recordId) {
        List<LocationWrapper> result = new List<LocationWrapper>();

        try {
            List<Account> accList = [
                SELECT  Id,
                        Name,
                        Description,
                        BillingState,
                        BillingCity,
                        BillingStreet,
                        BillingPostalCode
                FROM    Account
                WHERE   Id = :recordId
                LIMIT   1
            ];

            if(!accList.isEmpty()) {
                LocationInfoWrapper locationInfoWrapper = new LocationInfoWrapper(accList[0].BillingStreet, accList[0].BillingCity, accList[0].BillingState);
                LocationWrapper locationWrapper = new LocationWrapper(locationInfoWrapper, accList[0].BillingPostalCode, accList[0].Name, accList[0].Description);

                result.add(locationWrapper);
            }
        
            return result;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Wrapper Class
    public class LocationWrapper {
        @AuraEnabled public LocationInfoWrapper location    {get;set;}
        @AuraEnabled public String              postalCode  {get;set;}
        @AuraEnabled public String              title       {get;set;}
        @AuraEnabled public String              description {get;set;}

        public LocationWrapper() {}

        public LocationWrapper(LocationInfoWrapper location, String postalCode, String title, String description) {
            this.location       = location;
            this.postalCode     = postalCode;
            this.title          = title;
            this.description    = description;
        }
    }

    public class LocationInfoWrapper {
        @AuraEnabled public String Street   {get;set;}
        @AuraEnabled public String City     {get;set;}
        @AuraEnabled public String State    {get;set;}

        public LocationInfoWrapper() {}

        public LocationInfoWrapper(String Street, String City, String State) {
            this.Street = Street;
            this.City   = City;
            this.State  = State;
        }
    }
}