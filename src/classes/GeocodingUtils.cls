public class GeocodingUtils {
    // Address fields order: street, city, zipcode, country
    public static SObject geocodeObject(SObject obj, String sObjectType, String[] orderderAddressFields){
        String apiKey = GoogleMapsGeocoding__c.getOrgDefaults().ServerKey__c;
        String address = GeocodingUtils.returnFullAddress(obj, orderderAddressFields);

        String addressEncoded = EncodingUtil.urlEncode(address, 'UTF-8');
        String endpointUrl = 'https://maps.googleapis.com/maps/api/geocode/json?language=it&key=' + apiKey + '&address=' + addressEncoded;

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(endpointUrl);
        req.setMethod('GET');

        try {
            if(!Test.isRunningTest()) {
                res = http.send(req);
            } else {
                res.setBody(GeocodeBeanTest.getJson());
            }
        } catch(System.CalloutException e) {
            System.debug('Exception: ' + e);
        }
        
        GeocodeBean bean = (GeocodeBean) System.JSON.deserialize(res.getBody(), GeocodeBean.class);
        if(bean.results.size() == 1) {
            obj.put('NormalizzatoIndirizzo__c', '');
            obj.put('NormalizzatoCivico__c', '');
            obj.put('NormalizzatoCap__c', '');
            obj.put('NormalizzatoLocalita__c', '');
            obj.put('NormalizzatoAmministrativoLiv1__c', '');
            obj.put('NormalizzatoAmministrativoLiv2__c', '');
            obj.put('NormalizzatoCodiceNazione__c', '');
            obj.put('NormalizzatoIndirizzoEsteso__c', '');
            obj.put('NormalizzatoCoordinate__Latitude__s', null);
            obj.put('NormalizzatoCoordinate__Longitude__s', null);

            for(GeocodeBean.Address_components comp : bean.results[0].address_components) {
                if((new Set<String>(comp.types)).contains('route')) {
                    obj.put('NormalizzatoIndirizzo__c', comp.short_name);
                }
                if((new Set<String>(comp.types)).contains('street_number')) {
                    obj.put('NormalizzatoCivico__c', comp.short_name);
                }
                if((new Set<String>(comp.types)).contains('locality')) {
                    obj.put('NormalizzatoLocalita__c', comp.short_name);
                }
                if((new Set<String>(comp.types)).contains('postal_code')) {
                    obj.put('NormalizzatoCap__c', comp.short_name);
                }
                if((new Set<String>(comp.types)).contains('administrative_area_level_1')) {
                    obj.put('NormalizzatoAmministrativoLiv1__c', comp.short_name);
                }
                if((new Set<String>(comp.types)).contains('administrative_area_level_2')) {
                    obj.put('NormalizzatoAmministrativoLiv2__c', comp.short_name);
                }
                if((new Set<String>(comp.types)).contains('country')) {
                    obj.put('NormalizzatoCodiceNazione__c', comp.short_name);
                }
            }
            obj.put('NormalizzatoIndirizzoEsteso__c', bean.results[0].formatted_address);
            obj.put('NormalizzatoCoordinate__Latitude__s', bean.results[0].geometry.location.lat);
            obj.put('NormalizzatoCoordinate__Longitude__s', bean.results[0].geometry.location.lng);
            obj.put('UltimaNormalizzazione__c', System.now());
        }
        obj.put('UltimoTentativoNormalizzazione__c', System.now());
        update obj;
        return obj;
    }

    public static String returnFullAddress(SObject obj, String[] addressFields) {
        String address = '';
        for(String field : addressFields){
            if(String.isNotBlank((String)obj.get(field))) {
                address += (String)obj.get(field) + ' ';
            }
        }
        return address;
    }
}