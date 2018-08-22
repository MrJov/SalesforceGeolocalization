/**
 * Classe di utilità per metodi relativi ai trigger
 */
public class T {
  public enum TMode {xINSERT, xDELETE, xUPDATE}

  public SObject[] triggerNew;
  public Map<Id, SObject> oldMap;

  private TMode mode {
    get {
      if(mode == null) {
        if(oldMap == null) mode = TMode.xINSERT;
        else if(triggerNew == null) mode = TMode.xDELETE;
        else mode = TMode.xUPDATE;
      }
      return mode;
    }
    set;
  }

  private Schema.DescribeSObjectResult describeInfo {
    get {
      if(describeInfo == null) {
        SObject target;
        if(mode == TMode.xDELETE && !oldMap.isEmpty()) target = oldMap.values()[0];
        else if(!triggerNew.isEmpty()) target = triggerNew[0];
        else return null;
        describeInfo = target.getSObjectType().getDescribe();
      }
      return describeInfo;
    }
    set;
  }

  public T(SObject[] triggerNew, Map<Id, SObject> oldMap) {
    this.triggerNew = triggerNew;
    this.oldMap = oldMap;
  }

  private T(SObject[] triggerNew, Map<Id, SObject> oldMap, Schema.DescribeSObjectResult describeInfo) {
    this(triggerNew, oldMap);
    this.describeInfo = describeInfo;
  }

  public static T getInstance() {
    return new T(Trigger.new, Trigger.oldMap);
  }

  public Map<String, Schema.SObjectField> getFields() {
    return describeInfo == null ? null : describeInfo.fields.getMap();
  }

  public String getObjectName() {
    return describeInfo == null ? null : describeInfo.getName();
  }

  public SObject[] getChanged(String fieldToCheck) {
    return getChanged(new String[]{fieldToCheck}, false);
  }

  public SObject[] getChanged(String fieldToCheck, Boolean skipCheck) {
    return getChanged(new String[]{fieldToCheck}, skipCheck);
  }

  public SObject[] getChanged(String[] fieldsToCheck) {
    return getChanged(fieldsToCheck, false);
  }

  public SObject[] getChanged(String[] fieldsToCheck, Boolean skipCheck) {
    if(mode == TMode.xINSERT || (mode == TMode.xUPDATE && skipCheck)) return triggerNew;
    else if(mode == TMode.xDELETE) return new SObject[]{};

    SObject[] res = new SObject[]{};
    Map<String, Schema.SObjectField> objFields = getFields();
    for(SObject obj : triggerNew) {
      for(String field : fieldsToCheck) {
        if(!objFields.containsKey(field)) continue;
        if(obj.get(field) != oldMap.get(obj.id).get(field)) {
          res.add(obj);
          break;
        }
      }
    }
    return res;
  }

  public T filter(String field, Object value) {
    return filter(field, value, true);
  }

  public T filter(String field, Object value, Boolean includeOrExclude) {
    SObject[] res = new SObject[]{};
    if(!getFields().containsKey(field)) return new T(res, oldMap, describeInfo);
    return new T(U.filter(triggerNew, field, value, includeOrExclude), oldMap, describeInfo);
  }

  public T filterByOld(String field, Object value) {
    return filterByOld(field, value, true);
  }

  public T filterByOld(String field, Object value, Boolean includeOrExclude) {
    SObject[] res = new SObject[]{};

    if(mode != TMode.xUPDATE && !includeOrExclude) return this;
    if(mode != TMode.xUPDATE || !getFields().containsKey(field)) return new T(res, oldMap, describeInfo);

    SObject[] filteredOlds = U.filter(oldMap.values(), field, value, includeOrExclude);
    Map<Id, SObject> newMap = new Map<Id, SObject>(triggerNew);
    for(SObject o : filteredOlds) {
      if(newMap.containsKey(o.Id)) res.add(newMap.get(o.Id));
    }
    return new T(res, oldMap, describeInfo);
  }

  /**
   * Shorthands vari
   */
  public static Boolean isAfterUpdate(){
    return (Trigger.isAfter && Trigger.isUpdate);
  }
  public static Boolean isBeforeUpdate(){
    return (Trigger.isBefore && Trigger.isUpdate);
  }
  public static Boolean isBeforeInsert(){
    return (Trigger.isBefore && Trigger.isInsert);
  }
  public static Boolean isAfterInsert(){
    return (Trigger.isAfter && Trigger.isInsert);
  }
  public static Boolean isBeforeDelete(){
    return (Trigger.isBefore && Trigger.isDelete);
  }
  public static Boolean isAfterDelete(){
    return (Trigger.isAfter && Trigger.isDelete);
  }

}