global class GeocodingAccountBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global final String query;  
    global final static String[] adminAddressFields = new String[]{'BillingStreet', 'BillingCity', 'BillingPostalCode', 'BillingState', 'BillingCountry'};

    global GeocodingAccountBatch(){
        Decimal dailyLimit = GoogleMapsGeocoding__c.getOrgDefaults().DailyLimit__c;
        query = 'SELECT Id, '+String.join(adminAddressFields, ', ')+' FROM Account WHERE UltimoTentativoNormalizzazione__c = null LIMIT ' + String.valueOf(dailyLimit.intValue());
        System.debug('Batch query: ' + query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(SObject sObj : scope){ 
            Account acc = (Account)sObj;
            GeocodingUtils.geoCodeObject(acc, 'Account', adminAddressFields);
        }
    }

    global void finish(Database.BatchableContext BC){}
}