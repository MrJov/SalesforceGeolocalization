public class AccountTriggerHandler {
  public static boolean skipTrigger = false;
  private final static String[] adminAddressFields = new String[]{'BillingStreet', 'BillingCity', 'BillingPostalCode', 'BillingState', 'BillingCountry'};

  public static void beforeUpdate(T triggerWrapper){
    normalizeAddress(triggerWrapper);
  }

  private static void normalizeAddress(T triggerWrapper){
    List<Account> changedAddresses = triggerWrapper.getChanged(adminAddressFields);
    for(Account acc : changedAddresses){
      acc.UltimoTentativoNormalizzazione__c = null;
    }
  }
}