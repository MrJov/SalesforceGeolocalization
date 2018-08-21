@isTest
public class GeocodeBeanTest {
    public static GeocodeBean parse(String json){
        return (GeocodeBean) System.JSON.deserialize(json, GeocodeBean.class);
    }

    public static String getJson() {
        String json = '{'+
                '   "results" : ['+
                '      {'+
                '         "address_components" : ['+
                '            {'+
                '               "long_name" : "71",'+
                '               "short_name" : "71",'+
                '               "types" : [ "street_number" ]'+
                '            },'+
                '            {'+
                '               "long_name" : "Corso Garibaldi",'+
                '               "short_name" : "Corso Garibaldi",'+
                '               "types" : [ "route" ]'+
                '            },'+
                '            {'+
                '               "long_name" : "Milano",'+
                '               "short_name" : "Milano",'+
                '               "types" : [ "locality", "political" ]'+
                '            },'+
                '            {'+
                '               "long_name" : "Milano",'+
                '               "short_name" : "Milano",'+
                '               "types" : [ "administrative_area_level_3", "political" ]'+
                '            },'+
                '            {'+
                '               "long_name" : "Città Metropolitana di Milano",'+
                '               "short_name" : "MI",'+
                '               "types" : [ "administrative_area_level_2", "political" ]'+
                '            },'+
                '            {'+
                '               "long_name" : "Lombardia",'+
                '               "short_name" : "Lombardia",'+
                '               "types" : [ "administrative_area_level_1", "political" ]'+
                '            },'+
                '            {'+
                '               "long_name" : "Italia",'+
                '               "short_name" : "IT",'+
                '               "types" : [ "country", "political" ]'+
                '            },'+
                '            {'+
                '               "long_name" : "20121",'+
                '               "short_name" : "20121",'+
                '               "types" : [ "postal_code" ]'+
                '            }'+
                '         ],'+
                '         "formatted_address" : "Corso Garibaldi, 71, 20121 Milano, Italia",'+
                '         "geometry" : {'+
                '            "location" : {'+
                '               "lat" : 45.4750687,'+
                '               "lng" : 9.183375'+
                '            },'+
                '            "location_type" : "ROOFTOP",'+
                '            "viewport" : {'+
                '               "northeast" : {'+
                '                  "lat" : 45.4764176802915,'+
                '                  "lng" : 9.184723980291503'+
                '               },'+
                '               "southwest" : {'+
                '                  "lat" : 45.47371971970851,'+
                '                  "lng" : 9.182026019708498'+
                '               }'+
                '            }'+
                '         },'+
                '         "partial_match" : true,'+
                '         "place_id" : "ChIJeehXskvBhkcRSbL2KbaCxJY",'+
                '         "types" : [ "street_address" ]'+
                '      }'+
                '   ],'+
                '   "status" : "OK"'+
                '}';
        return json;
    }

    static testMethod void testParse() {
        GeocodeBean obj = new GeocodeBean();
        obj = parse(getJson());
        System.assert(obj != null);
    }
}