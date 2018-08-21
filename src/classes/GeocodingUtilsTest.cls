@IsTest
private class GeocodingUtilsTest {

    @testSetup
    static void setup() {
        Account acc = new Account(Name='Test Acc');
        acc.BillingStreet = 'Corso Garibaldi 71';
        acc.BillingPostalCode = '20126';
        acc.BillingCity = 'Milano';
        insert acc;
        Account acc2 = new Account(Name='Test Acc 2');
        acc2.ShippingStreet = 'Corso Garibaldi 71';
        acc2.ShippingPostalCode = '20126';
        acc2.ShippingCity = 'Milano';
        insert acc2;
        Contact cont = new Contact(LastName='Test Cont', AccountId = acc.Id);
        cont.MailingStreet = 'Corso Garibaldi 71';
        cont.MailingPostalCode = '20126';
        cont.MailingCity = 'Milano';
        insert cont;
    }

    @isTest
    static void testGeocodingAccount() {
        Test.startTest();
        GeocodingUtils.geoCodeAccount([SELECT Id FROM Account WHERE Name = 'Test Acc' LIMIT 1].Id);
        GeocodingUtils.geoCodeAccount([SELECT Id FROM Account WHERE Name = 'Test Acc 2' LIMIT 1].Id);
        Test.stopTest();
        System.assertEquals('Milano', [SELECT NormalizzatoLocalita__c FROM Account WHERE Name = 'Test Acc' LIMIT 1].NormalizzatoLocalita__c);
        System.assertEquals('Milano', [SELECT NormalizzatoLocalita__c FROM Account WHERE Name = 'Test Acc 2' LIMIT 1].NormalizzatoLocalita__c);
    }
}