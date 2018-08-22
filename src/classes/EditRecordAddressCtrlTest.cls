@isTest
private class EditRecordAddressCtrlTest {

  @testSetup
  static void setup() {
    Account acc = new Account(Name='Test Acc');
    acc.BillingStreet = 'Corso Garibaldi 71';
    acc.BillingPostalCode = '20126';
    acc.BillingCity = 'Milano';
    insert acc;
  }

  @isTest
  private static void testSave(){
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Acc' LIMIT 1];
    acc.NormalizzatoCoordinate__Latitude__s = 45.00234;
    acc.NormalizzatoCoordinate__Longitude__s = 41.17770;
    Test.StartTest();
    EditRecordAddressCtrl.save(JSON.serialize(acc), acc.Id);
    Account upd = [SELECT Id, Name, UltimaNormalizzazione__c FROM Account WHERE Name = 'Test Acc' LIMIT 1];
    Test.StopTest();
    System.assertNotEquals(null, upd.UltimaNormalizzazione__c);
  }

  @isTest
  private static void testGetAdminAddress(){
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Acc' LIMIT 1];
    Test.StartTest();
    String address = EditRecordAddressCtrl.getAdminAddress(acc.Id, 'BillingStreet, BillingPostalCode, BillingCity');
    Test.StopTest();
    System.assertEquals('Corso Garibaldi 71 20126 Milano ', address);
  }
}