public with sharing class EditRecordAddressCtrl {

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
      if (sr.isSuccess()) 
        return 'Indirizzo normalizzato aggiornato con successo.';
      else 
        return sr.getErrors()[0].getMessage();
    } catch(Exception ex){
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
      String fields = String.join(new List<String>(fieldSet), ', ');
      String soql = 'SELECT '+fields+' FROM '+sobjectType+' WHERE Id = \''+recordId+'\'';
      SObject obj = (SObject)Database.query(soql);
      String completeAddress = '';
      for(String fld : fieldsString.split(',')){
        if(String.isNotBlank((String)obj.get(fld.trim()))){
          completeAddress += (String)obj.get(fld.trim())+' ';
        }
      }
      return completeAddress;
    } catch (Exception ex){
      System.debug('ECCEZIONE '+ex.getMessage());
      return 'ERRORE - '+ex.getMessage();
    }
  }
}