// Apex class the handles the geocoding request for an object
public class GeocodingUtils {

    // Base endpoint URL. Il formato degli indirizzi ritornato è sempre quello italiano
    public static String baseEndpoint = 'https://maps.googleapis.com/maps/api/geocode/json';
    public static String geolocationConfig_geocodingFormat = 'GeocodingAddressFormat__c';
    public static String[] geolocationConfig_InputAddressFields = new String[]{'StreetField__c', 'CityField__c', 'ZipcodeField__c', 'CountryField__c'};
    public static String[] geolocationConfig_OutputAddressFields = new String[]{'NormalizedStreetField__c', 'NormalizedStreetNumberField__c', 'NormalizedCityField__c', 'NormalizedZipcodeField__c',
        'NormalizedAdministrativeAreaLv1__c', 'NormalizedAdministrativeAreaLv2__c', 'NormalizedCountryCodeField__c', 'NormalizedFullAddressField__c'};
    public static String geolocationConfig_OutputLatitudeField = 'NormalizedLatitudeField__c';
    public static String geolocationConfig_OutputLongitudeField = 'NormalizedLongitudeField__c';
    public static String geolocationConfig_AttemptDateField = 'LastGeocodingAttemptDateField__c';
    public static String geolocationConfig_DateField = 'LastGeocodingDateField__c';
    public static String geolocationConfig_StatusField = 'GeocodingStatusField__c';
    public static Map<String, String> geolocationMapping = new Map<String, String>{
        'route' => 'NormalizedStreetField__c',
        'street_number' => 'NormalizedStreetNumberField__c',
        'locality' => 'NormalizedCityField__c',
        'postal_code' => 'NormalizedZipcodeField__c',
        'administrative_area_level_1' => 'NormalizedAdministrativeAreaLv1__c',
        'administrative_area_level_2' => 'NormalizedAdministrativeAreaLv2__c',
        'country' => 'NormalizedCountryCodeField__c',
        'formatted_address' => 'NormalizedFullAddressField__c'
    };

    // Geocoding function
    public static SObject geocodeObject(SObject obj, String sObjectType){

        // Compute the query to get the fields API names from the custom metadata
        String configQuery = 'SELECT ' + String.join(geolocationConfig_InputAddressFields, ', ') + ', ' + String.join(geolocationConfig_OutputAddressFields, ', ') + ', ' +
            geolocationConfig_OutputLatitudeField + ', ' + geolocationConfig_OutputLongitudeField + ', ' + geolocationConfig_AttemptDateField + ', ' + geolocationConfig_DateField + ', ' +
            geolocationConfig_geocodingFormat + ' ' +
            'FROM ConfigurazioneGeolocalizzazione__mdt ' +
            'WHERE ObjectAPIName__c = \'' + sObjectType + '\' ';
        // Get the geolocation configuration
        ConfigurazioneGeolocalizzazione__mdt geolocationConfig = Database.query(configQuery);

        // Get the google server key from a custom setting and the full address chaining the fields given in input
        String apiKey = GoogleMapsGeocoding__c.getOrgDefaults().ServerKey__c;
        String fullAddress = GeocodingUtils.returnFullAddress(obj, geolocationConfig);
        // Encode the full address and compute the complete the endpoint
        String addressEncoded = EncodingUtil.urlEncode(fullAddress, 'UTF-8');
        // Address format language
        String formatLanguage = (String)geolocationConfig.get(geolocationConfig_geocodingFormat);
        // Compute the complete endpoint URL
        String endpointUrl = baseEndpoint +'?language=' + formatLanguage + '&key=' + apiKey + '&address=' + addressEncoded;

        // Send the request to the geocoding service and get the response (in test classes the reponse is fixed)
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
        
        // Deserialize the response throught the GeocodeBean class
        GeocodeBean bean = (GeocodeBean) System.JSON.deserialize(res.getBody(), GeocodeBean.class);
        // If there is one and only one result the geocoding request is considered successful, otherewise we save an error on the record
        if(bean.results.size() == 1) {
            // Initialize all the fileds in which the process will store the normalized fields
            for(String configField : geolocationConfig_OutputAddressFields){
                if(!String.isEmpty((String)geolocationConfig.get(configField))){
                    obj.put((String)geolocationConfig.get(configField), '');
                }
            }
            obj.put((String)geolocationConfig.get(geolocationConfig_OutputLatitudeField), null);
            obj.put((String)geolocationConfig.get(geolocationConfig_OutputLongitudeField), null);

            // Save the address components obtained from the geocoding service (if the corresponded field is specified)
            for(GeocodeBean.AddressComponents comp : bean.results[0].address_components) {
                Set<String> componentTypes = new Set<String>(comp.types);
                for(String type : geolocationMapping.keySet()){
                    if(componentTypes.contains(type) && !String.isEmpty((String)geolocationConfig.get(geolocationMapping.get(type)))) {
                        obj.put((String)geolocationConfig.get(geolocationMapping.get(type)), comp.short_name);
                    }
                }
            }
            // If it is specified the filed, save the formatted address
            if(!String.isEmpty((String)geolocationConfig.get(geolocationMapping.get('formatted_address')))){
                obj.put((String)geolocationConfig.get(geolocationMapping.get('formatted_address')), bean.results[0].formatted_address);
            }
            // Save the latitude and longitude
            obj.put((String)geolocationConfig.get(geolocationConfig_OutputLatitudeField), bean.results[0].geometry.location.lat);
            obj.put((String)geolocationConfig.get(geolocationConfig_OutputLongitudeField), bean.results[0].geometry.location.lng);
            // If it is specified, save the date and time of the successful geolocalization
            if(!String.isEmpty((String)geolocationConfig.get(geolocationConfig_DateField))){
                obj.put((String)geolocationConfig.get(geolocationConfig_DateField), System.now());
            }
        }
        // Save the date and time of this geolocalization attempt
        if(!String.isEmpty((String)geolocationConfig.get(geolocationConfig_AttemptDateField))){
            obj.put((String)geolocationConfig.get(geolocationConfig_AttemptDateField), System.now());
        }
        // Save the status of this geolocalization attempt
        if(!String.isEmpty((String)geolocationConfig.get(geolocationConfig_StatusField))){
            String status = bean.results.size() == 1 ? bean.status : 'TOO_MANY_RESULTS';
            obj.put((String)geolocationConfig.get(geolocationConfig_StatusField), status);
        }
        // Update and return the object
        update obj;
        return obj;
    }

    // Private function to compute the full address
    private static String returnFullAddress(SObject obj, ConfigurazioneGeolocalizzazione__mdt addressFields) {
        String fullAddress = '';
        for(String configField : geolocationConfig_InputAddressFields){
            String field = (String)addressFields.get(configField);
            if(String.isNotBlank((String)obj.get(field))) {
                fullAddress += (String)obj.get(field) + ' ';
            }
        }
        return fullAddress;
    }
}