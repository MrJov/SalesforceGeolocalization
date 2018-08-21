public class GeocodingUtils {
    public static Account geocodeAccount(Id accId) {

        String apiKey = GoogleMapsGeocoding__c.getOrgDefaults().ServerKey__c;
        Account acc = [SELECT Name, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountry, BillingStreet, BillingCity, BillingPostalCode, BillingCountry FROM Account WHERE Id = :accId];
        String address = GeocodingUtils.returnFullAddress(acc);
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
        System.debug(bean);
        if(bean.results.size() == 1) {
            acc.NormalizzatoIndirizzo__c = '';
            acc.NormalizzatoCivico__c = '';
            acc.NormalizzatoCap__c = '';
            acc.NormalizzatoLocalita__c = '';
            acc.NormalizzatoAmministrativoLiv1__c = '';
            acc.NormalizzatoAmministrativoLiv2__c = '';
            acc.NormalizzatoCodiceNazione__c = '';
            acc.NormalizzatoIndirizzoEsteso__c = '';
            acc.NormalizzatoCoordinate__Latitude__s = null;
            acc.NormalizzatoCoordinate__Longitude__s = null;

            for(GeocodeBean.Address_components comp : bean.results[0].address_components) {
                if((new Set<String>(comp.types)).contains('route')) {
                    acc.NormalizzatoIndirizzo__c = comp.short_name;
                }
                if((new Set<String>(comp.types)).contains('street_number')) {
                    acc.NormalizzatoCivico__c = comp.short_name;
                }
                if((new Set<String>(comp.types)).contains('locality')) {
                    acc.NormalizzatoLocalita__c = comp.short_name;
                }
                if((new Set<String>(comp.types)).contains('postal_code')) {
                    acc.NormalizzatoCap__c = comp.short_name;
                }
                if((new Set<String>(comp.types)).contains('administrative_area_level_1')) {
                    acc.NormalizzatoAmministrativoLiv1__c = comp.short_name;
                }
                if((new Set<String>(comp.types)).contains('administrative_area_level_2')) {
                    acc.NormalizzatoAmministrativoLiv2__c = comp.short_name;
                }
                if((new Set<String>(comp.types)).contains('country')) {
                    acc.NormalizzatoCodiceNazione__c = comp.short_name;
                }
            }
            acc.NormalizzatoIndirizzoEsteso__c = bean.results[0].formatted_address;
            acc.NormalizzatoCoordinate__Latitude__s = bean.results[0].geometry.location.lat;
            acc.NormalizzatoCoordinate__Longitude__s = bean.results[0].geometry.location.lng;
            acc.UltimaNormalizzazione__c = System.now();
        }
        acc.UltimoTentativoNormalizzazione__c = System.now();
        update acc;
        return acc;
    }

    public static String returnFullAddress(Account acc) {
        String address = '';
        // Provo prima con lo shipping address
        // Sostituito Indirizzo__c con ShippingStreet
        if(String.isNotBlank(acc.ShippingStreet)) {
            address += acc.ShippingStreet + ' ';
        }
        // Sostituito Localita__c con ShippingCity
        if(String.isNotBlank(acc.ShippingCity)) {
            address += acc.ShippingCity + ' ';
        }
        // Sostituito Cap con ShippingPostalCode
        if(String.isNotBlank(acc.ShippingPostalCode)) {
            address += acc.ShippingPostalCode + ' ';
        }
        // Sostituito Nazione__r.Name con ShippingCountry
        if(String.isNotBlank(acc.ShippingCountry)) {
            address += acc.ShippingCountry;
        }
        // Se non ha trovato nulla passo al BillingAddress
        if(String.isBlank(address)){
            // Sostituito Indirizzo__c con BillingStreet
            if(String.isNotBlank(acc.BillingStreet)) {
                address += acc.BillingStreet + ' ';
            }
            // Sostituito Localita__c con BillingCity
            if(String.isNotBlank(acc.BillingCity)) {
                address += acc.BillingCity + ' ';
            }
            // Sostituito Cap con BillingPostalCode
            if(String.isNotBlank(acc.BillingPostalCode)) {
                address += acc.BillingPostalCode + ' ';
            }
            // Sostituito Nazione__r.Name con BillingCountry
            if(String.isNotBlank(acc.BillingCountry)) {
                address += acc.BillingCountry;
            }
        }
        return address;
    }

    public static String returnFullAddress(Contact cont) {
        String address = '';
        // Sostituito Indirizzo__c con MailingStreet
        if(String.isNotBlank(cont.MailingStreet)) {
            address += cont.MailingStreet + ' ';
        }
        // Sostituito Localita__c con MailingCity
        if(String.isNotBlank(cont.MailingCity)) {
            address += cont.MailingCity + ' ';
        }
        // Sostituito Cap con MailingPostalCode
        if(String.isNotBlank(cont.MailingPostalCode)) {
            address += cont.MailingPostalCode + ' ';
        }
        // Sostituito Nazione__r.Name con MailingCountry
        if(String.isNotBlank(cont.MailingCountry)) {
            address += cont.MailingCountry;
        }
        return address;
    }
}