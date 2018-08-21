global class GeocodingAccountBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global final String query;

    global GeocodingAccountBatch() {
        Decimal dailyLimit = GoogleMapsGeocoding__c.getOrgDefaults().DailyLimit__c;
        query = 'SELECT Id FROM Account WHERE UltimoTentativoNormalizzazione__c = null LIMIT ' + String.valueOf(dailyLimit.intValue());
        System.debug('Batch query: ' + query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for(SObject sObj : scope) { 
            Account acc = (Account)sObj;
            GeocodingUtils.geoCodeAccount(acc.Id);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}