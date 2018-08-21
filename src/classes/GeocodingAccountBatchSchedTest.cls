@IsTest
private class GeocodingAccountBatchSchedTest {
    @testSetup
    static void setup() {
        Account acc = new Account(Name='Test Acc');
        acc.BillingStreet = 'Corso Garibaldi 71';
        acc.BillingPostalCode = '20126';
        acc.BillingCity = 'Milano';
        insert acc;

        insert new GoogleMapsGeocoding__c(DailyLimit__c = 1);
    }

    @isTest
    static void testBatchGeocodingSched() {
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('GeocodingAccountBatchSchedTest',  CRON_EXP,  new GeocodingAccountBatchSched());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}