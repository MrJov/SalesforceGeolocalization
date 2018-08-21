public with sharing class EditAccountAddressCtrl {

  @AuraEnabled
  public static String save(String jsonRec, String recordId) {
    String sobjectType = String.valueOf(((Id)recordId).getSobjectType());
    SObject rec = (SObject)JSON.deserialize(jsonRec, Type.forName(sobjectType));
    try {
      if(rec.get('NormalizzatoCoordinate__Latitude__s') != null) {
        rec.put('UltimoTentativoNormalizzazione__c', System.now());
        rec.put('UltimaNormalizzazione__c', System.now());
      }
      Database.SaveResult sr = Database.update(rec);
      if (sr.isSuccess()) return 'Indirizzo normalizzato aggiornato con successo.';
      else return sr.getErrors()[0].getMessage();
    } catch(Exception ex){
      return ex.getMessage();
    }
  }

  @AuraEnabled
  public static Map<String, String> init(String recordId){
    String sobjectType = String.valueOf(((Id)recordId).getSobjectType());
    String[] fields = new List<String>(Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap().keySet());
    Map<String, String> labelMap = new Map<String, String>();
    for(String field : fields){
      labelMap.put(field, Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap().get(field).getDescribe().getLabel());
    }
    return labelMap;
  }

  @AuraEnabled
  public static String getRecord(String recordId){
    String sobjectType = String.valueOf(((Id)recordId).getSobjectType());
    String soql = 'SELECT Id, NormalizzatoIndirizzo__c, NormalizzatoCivico__c, '+
                  'NormalizzatoLocalita__c, NormalizzatoCodiceNazione__c, NormalizzatoCap__c, ' +
                  'NormalizzatoAmministrativoLiv1__c, NormalizzatoAmministrativoLiv2__c, '+
                  'NormalizzatoCoordinate__Latitude__s, NormalizzatoCoordinate__Longitude__s, ' +
                  'NormalizzatoIndirizzoEsteso__c, UltimoTentativoNormalizzazione__c, UltimaNormalizzazione__c ';
    if(sobjectType == 'Event')
      soql+=', Subject';
    else
      soql+=', Name';
    soql += ' FROM '+sobjectType+' WHERE Id = \'' + recordId + '\'';
    // System.debug('SOQL RECORD'+soql);
    try {
      Sobject rec = Database.query(soql);
      return JSON.serialize(rec);
    } catch(Exception ex){
      System.debug(ex.getMessage());
      return ex.getMessage();
    }
  }

  @AuraEnabled
  public static String getAdminAddress(String recordId, String fieldsString){
    try {
      String sobjectType = String.valueOf(((Id)recordId).getSobjectType());
      Set<String> fieldSet = new Set<String>{'Id'};
      for(String fld : fieldsString.split(',')){
        fieldSet.add(fld.trim());
      }
      System.debug(fieldSet);
      String fields = String.join(new List<String>(fieldSet), ', ');
      String soql = 'SELECT '+fields+' FROM '+sobjectType+' WHERE Id = \''+recordId+'\'';
      System.debug('QUERY SOQL '+soql);
      SObject obj = (SObject)Database.query(soql);
      String completeAddress = '';
      System.debug(obj);
      for(String fld : fieldsString.split(',')){
        System.debug(fld);
        if(String.isNotBlank((String)obj.get(fld.trim()))){
          completeAddress += (String)obj.get(fld.trim())+' ';
        }
      }
      System.debug('COMPLETE ADDRESS '+completeAddress);
      return completeAddress;
    } catch (Exception ex){
      System.debug('ECCEZIONE '+ex.getMessage());
      return 'ERRORE - '+ex.getMessage();
    }
  }
}