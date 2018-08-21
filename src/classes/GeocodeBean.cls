public class GeocodeBean {
    public List<Results> results {get;set;}
    public String status {get;set;}	//OK

    public class Results {
        public List<Address_components> address_components {get;set;}
        public String formatted_address {get;set;}	//Corso Garibaldi, 71, 20121 Milano, Italia
        public Geometry geometry {get;set;}
        public boolean partial_match {get;set;}
        public String place_id {get;set;}	//ChIJeehXskvBhkcRSbL2KbaCxJY
        public List<String> types {get;set;}
    }

    public class Address_components {
        public String long_name {get;set;}	//71
        public String short_name {get;set;}	//71
        public List<String> types {get;set;}
    }

    public class Geometry {
        public Location location {get;set;}
        public String location_type {get;set;}	//ROOFTOP
        public Viewport viewport {get;set;}
    }

    public class Location {
        public Double lat {get;set;}	//45.4750687
        public Double lng {get;set;}	//9.183375
    }

    public class Viewport {
        public Northeast northeast {get;set;}
        public Southwest southwest {get;set;}
    }

    public class Northeast {
        public Double lat {get;set;}	//45.4764176802915
        public Double lng {get;set;}	//9.184723980291503
    }

    public class Southwest {
        public Double lat {get;set;}	//45.47371971970851
        public Double lng {get;set;}	//9.182026019708498
    }
}