@isTest
private class AccountTriggerHandlerTest {
  @testSetup
  private static void setup(){
    Account acc = new Account(Name='TEST', BillingStreet='Corso Garibaldi 71', BillingPostalCode='20126', BillingCity='Milano', UltimoTentativoNormalizzazione__c=System.now());
    insert acc;
  }

  @isTest
  private static void testResetNormalizzazione(){
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TEST' LIMIT 1];
    acc.BillingStreet = 'Corso Garibaldi 85';
    Test.StartTest();
    update acc;
    Test.StopTest();
    Account upd = [SELECT UltimoTentativoNormalizzazione__c FROM Account WHERE Name = 'TEST' LIMIT 1];
    System.assertEquals(null, upd.UltimoTentativoNormalizzazione__c);
  }
}