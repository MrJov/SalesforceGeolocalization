// Apex class used to parse the json received in response from Google Geocoding API
public class GeocodeBean {
    public List<Results> results {get;set;}
    public String status {get;set;}	// Possible outcomes of the request: [OK, ZERO_RESULTS, OVER_DAILY_LIMIT, OVER_QUERY_LIMIT, REQUEST_DENIED, INVALID_REQUEST, UNKNOWN_ERROR]

    public class Results {
        public List<String> types {get;set;} // This attribute may contain a list of tags describing the result
        public String formatted_address {get;set;}	// This contains the human-readable address (ex: Corso Garibaldi, 71, 20121 Milano, Italia)
        public List<AddressComponents> address_components {get;set;} // This attribute contains the list of each component of the formatted address
        public Geometry geometry {get;set;} // Contains the details abount the geolocated result
        public boolean partial_match {get;set;} // The geocoder did not return an exact match for the original request, though it was able to match part of the requested address
        public String place_id {get;set;}	// This is a unique identifier that can be used with other Google APIs
    }

    public class AddressComponents { // In a result there may be more address components than elements in the formatted address
        public List<String> types {get;set;} // Contains the tags associated with the address component
        public String long_name {get;set;}	// This is the full text description of the component
        public String short_name {get;set;}	// If exists, this is the shortened version of the component name (like IT for Italy)
    }

    public class Geometry {
        public Location location {get;set;} // Contains the longitude and the latitude
        public String location_type {get;set;}	// additional data about the specified location pracision [ROOFTOP, RANGE_INTERPOLATED, GEOMETRIC_CENTER, APPROXIMATE]
        public Viewport viewport {get;set;} // Contains the recommended viewport for displaying the returned result as the NE and SW corners of the bounding box
    }

    public class Location { // The geolocated longitude and latitude for the requested address
        public Double lat {get;set;}
        public Double lng {get;set;}
    }

    public class Viewport { // NE and SW corners of the suggested viewport to display the location
        public Northeast northeast {get;set;}
        public Southwest southwest {get;set;}
    }

    public class Northeast { // Latitude and longitude of the NE corner of the viewport
        public Double lat {get;set;}
        public Double lng {get;set;}
    }

    public class Southwest { // Latitude and longitude of the SW corner of the viewport
        public Double lat {get;set;}
        public Double lng {get;set;}
    }
}