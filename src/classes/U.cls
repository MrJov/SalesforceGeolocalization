public class U {
  public static Object getSObjectValue(SObject obj, String field) {
    if(String.isBlank(field) || obj == null) return null;
    else return getSObjectValueWithoutChecks(obj, field, !field.contains('.'));
  }

  private static Map<String, String[]> tokensMap = new Map<String, String[]>();
  private static Object getSObjectValueWithoutChecks(SObject obj, String field, Boolean isPlainField) {
    try {
      if(isPlainField) return obj.get(field);

      SObject subObj = obj;
      if(!tokensMap.containsKey(field)) tokensMap.put(field, field.split('\\.'));
      String[] tokens = tokensMap.get(field);
      for(Integer i = 0; i < tokens.size() - 1; i++) {
        subObj = subObj.getSObject(tokens[i]);
      }
      return subObj.get(tokens[tokens.size() - 1]);
    } catch(Exception e) {
      return null;
    }
  }

  /**
   *  Estrae un set di id da una lista di oggetti
   *  @objList la lista di oggetti
   *  @idField il nome del campo che si vuole estrarre
   */
  public static Set<Id> getIdSet(SObject[] objList, String idField) {
    Set<Id> res = new Set<Id>();
    if(String.isBlank(idField) || objList == null || objList.isEmpty()) return res;
    else {
      Boolean isPlainField = !idField.contains('.');
      for(SObject obj : objList) {
        Object val = getSObjectValueWithoutChecks(obj, idField, isPlainField);
        if(val != null) res.add((Id) val);
      }
      return res;
    }
  }

  /**
   *  Estrae un set di stringhe da una lista di oggetti
   *  @objList la lista di oggetti
   *  @field il nome del campo che si vuole estrarre
   */
  public static Set<String> getSet(SObject[] objList, String field) {
    Set<String> res = new Set<String>();
    if(String.isBlank(field) || objList == null || objList.isEmpty()) return res;
    else {
      Boolean isPlainField = !field.contains('.');
      for(SObject obj : objList) {
        Object val = getSObjectValueWithoutChecks(obj, field, isPlainField);
        if(val != null) res.add((String) val);
      }
      return res;
    }
  }

  /**
   *  Estrae una mappa di SObject la cui chiave è composta da uno o più campi degli oggetti contenuti in objList, e il
   *  valore è l'oggetto. Ne consegue che la chiave della mappa dovrebbe essere univoca, altrimenti come valore sopravvive
   *  solo l'ultimo della lista ad avere tale chiave.
   *  @objList La lista di oggetti da cui si vuole creare la mappa
   *  @keyPattern una stringa contenente uno o più "tag" {nomeCampo} concatenati a piacimento, che rappresenta il formato
   *   che avranno le chiavi della mappa (es: "{name}" , oppure "{firstName}_{lastName}")
   */
  public static Map<String, SObject> keyBy(SObject[] objList, String field) {
    return keyBy(objList, field, false);
  }

  public static Map<String, SObject> keyBy(SObject[] objList, String keyPattern, Boolean useRegex) {
    if(useRegex) return keyByRegex(objList, keyPattern);

    Map<String, SObject> res = new Map<String, SObject>();
    if(objList == null) return res;

    Boolean isPlainField = !keyPattern.contains('.');
    for(SObject obj : objList) {
      String v = (String) getSObjectValueWithoutChecks(obj, keyPattern, isPlainField);
      if(v != null) res.put(v, obj);
    }

    return res;
  }

  public static Map<String, SObject> keyByRegex(SObject[] objList, String keyPattern) {
    Map<String, SObject> res = new Map<String, SObject>();
    if(objList == null) return res;

    Map<String, String> pattern2FieldMap = new Map<String, String>();
    Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
    Matcher m = pat.matcher(keyPattern);
    while(m.find()) {
      System.debug(m.group());
      String f = m.group().substringAfter('{').substringBeforeLast('}');
      pattern2FieldMap.put(m.group(), f);
    }

    for(SObject obj : objList) {
      String compiledPattern = keyPattern;
      for(String p : pattern2FieldMap.keySet()) {
        String value = (String) getSObjectValueWithoutChecks(obj, pattern2FieldMap.get(p), !p.contains('.'));
        if(value != null) {
          compiledPattern = compiledPattern.replace(p, value);
        }
      }
      res.put(compiledPattern, obj);
    }

    return res;
  }

  /**
   *  Estrae una mappa di SObject la cui chiave è composta dal valore di un campo degli oggetti contenuti in objList,
   *  e il valore è la lista di oggetti aventi tale chiave.
   *  @objList La lista di oggetti da cui si vuole creare la mappa
   *  @field il nome del campo che si vuole estrarre
   */
  public static Map<String, SObject[]> groupBy(SObject[] objList, String field) {
    return groupBy(objList, field, false);
  }

  /**
   *  Estrae una mappa di SObject la cui chiave è composta dal valore di un campo (o da una concatenazione del valore
   *  di un numero arbitrario di campi) degli oggetti contenuti in objList, e il valore è la lista di oggetti aventi tale chiave.
   *  @objList La lista di oggetti da cui si vuole creare la mappa
   *  @keyPattern il nome del campo che si vuole estrarre
   *  @useRegex se true keyPattern rappresenta una stringa nella forma {nomeApiCampo}.*{nomeApiCampo2}.*{nomeApiCampoN}
   */
  public static Map<String, SObject[]> groupBy(SObject[] objList, String keyPattern, Boolean useRegex) {
    if(useRegex) return groupByRegex(objList, keyPattern);

    Map<String, SObject[]> res = new Map<String, SObject[]>();
    if(objList == null) return res;

    Boolean isPlainField = !keyPattern.contains('.');
    for(SObject obj : objList) {
      String v = (String) getSObjectValueWithoutChecks(obj, keyPattern, isPlainField);
      addToGMap(res, v != null ? v : 'null', obj);
    }

    return res;
  }

  /**
   *  Estrae una mappa di SObject la cui chiave è composta da una concatenazione del valore di un numero arbitrario di
   *  campi degli oggetti contenuti in objList, e il valore è la lista di oggetti aventi tale chiave.
   *  @objList La lista di oggetti da cui si vuole creare la mappa
   *  @keyPattern una stringa nella forma {nomeApiCampo}.*{nomeApiCampo2}.*{nomeApiCampoN}
   */
  public static Map<String, SObject[]> groupByRegex(SObject[] objList, String keyPattern) {
    Map<String, SObject[]> res = new Map<String, SObject[]>();
    if(objList == null) return res;

    Map<String, String> pattern2FieldMap = new Map<String, String>();

    Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
    Matcher m = pat.matcher(keyPattern);
    while(m.find()) {
      System.debug(m.group());
      String f = m.group().substringAfter('{').substringBeforeLast('}');
      pattern2FieldMap.put(m.group(), f);
    }

    for(SObject obj : objList) {
      String compiledPattern = keyPattern;
      for(String p : pattern2FieldMap.keySet()) {
        String value = (String) getSObjectValueWithoutChecks(obj, pattern2FieldMap.get(p), !p.contains('.'));
        compiledPattern = compiledPattern.replace(p, value == null ? 'null' : value);
      }
      addToGMap(res, compiledPattern, obj);
    }

    return res;
  }

  public static void addToGMap(Map<String, SObject[]> m, String key, SObject value) {
    if(!m.containsKey(key)) m.put(key, new SObject[]{});
    m.get(key).add(value);
  }

  public static Object[] reverse(Object[] objList) {
    Object[] res = objList.clone();
    for(Integer i = 0; i < objList.size(); i++) {
      res[objList.size() - 1 - i] = objList[i];
    }
    return res;
  }

  /**
   *  Filtra la lista di oggetti in input sulla base del valore di un campo
   *  @coll La lista di oggetti
   *  @field Il nome api del campo
   *  @value il valore del campo
   */
  public static SObject[] filter(SObject[] coll, String field, Object value) {
    return filter(coll, field, value, true);
  }

  /**
   *  Filtra la lista di oggetti in input sulla base del valore di un campo
   *  @coll La lista di oggetti
   *  @field Il nome api del campo
   *  @value il valore del campo
   *  @includeOrExclude Se true, l'oggetto è presente nella lista filtrata solo se il valore del campo è uguale a value, se false invece l'oggetto è
   *                    presente solo se il valore del campo NON è uguale a value
   */
  public static SObject[] filter(SObject[] coll, String field, Object value, Boolean includeOrExclude) {
    if(value != null && (value instanceof Set<String> || value instanceof Set<Id>)) {
      return filter(coll, field, (Set<String>) value, includeOrExclude);
    }
    SObject[] res = new SObject[]{};
    if(coll == null) return res;
    for(SObject x : coll) {
      Object val = getSObjectValue(x, field);
      if((value == val && includeOrExclude) || (!includeOrExclude && value != val)) res.add(x);
    }
    return res;
  }

  /**
   *  Filtra la lista di oggetti in input sulla base di uno o più valori di un campo
   *  @coll La lista di oggetti
   *  @field Il nome api del campo
   *  @value L'insieme dei valori da controllare. I valori sono messi in OR
   */
  public static SObject[] filter(SObject[] coll, String field, Set<String> value) {
    return filter(coll, field, value, true);
  }

  /**
   *  Filtra la lista di oggetti in input sulla base di uno o più valori di un campo
   *  @coll La lista di oggetti
   *  @field Il nome api del campo
   *  @value L'insieme dei valori da controllare. I valori sono messi in OR
   *  @includeOrExclude Se true, l'oggetto è presente nella lista filtrata solo se il valore del campo è uguale a value, se false invece l'oggetto è
   *                    presente solo se il valore del campo NON è uguale a value
   */
  public static SObject[] filter(SObject[] coll, String field, Set<String> value, Boolean includeOrExclude) {
    SObject[] res = new SObject[]{};
    if(coll == null) return res;
    for(SObject x : coll) {
      Object val = getSObjectValue(x, field);
      if((includeOrExclude && value.contains((String) val)) || (!includeOrExclude && !value.contains((String) val))) res.add(x);
    }
    return res;
  }

  /**
   *  Restituisce una mappa DeveloperName => RecordType di tutti i recordtypes di un oggetto
   *  @obj Il nome dell'oggetto di cui si vogliono recuperare i recordType
   */
  private static Map<String, Map<String, SObject>> rtCache = new Map<String, Map<String, SObject>>();
  public static Map<String, SObject> getRecordTypes(String sobj) {
    if(!rtCache.containsKey(sobj)) rtCache.put(sobj, keyBy([SELECT
      Id,
      SObjectType,
      Name,
      DeveloperName,
      IsActive,
      Description
      FROM RecordType
      WHERE SObjectType = :sobj
    ], 'DeveloperName'));
    return rtCache.get(sobj);
  }
}