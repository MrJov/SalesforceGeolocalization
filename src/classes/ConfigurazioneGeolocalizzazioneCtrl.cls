public with sharing class ConfigurazioneGeolocalizzazioneCtrl {

    @AuraEnabled
    public static String getConfigurazioni(String[] fieldsToQuery){
        // Compute the query, get the geolocation configurations and return them as a JSON
        String configQuery = 'SELECT Id, ' + String.join(fieldsToQuery, ', ') + ' FROM ConfigurazioneGeolocalizzazione__mdt';
        List<ConfigurazioneGeolocalizzazione__mdt> geolocationConfig = Database.query(configQuery);
        return JSON.serialize(geolocationConfig);
    }

    @AuraEnabled
    public static String getAddressFormats(String field){
        // Get the values in the picklist for the address format
        List<FieldWrapper> values = new List<FieldWrapper>();
        for(PicklistEntry ple : Schema.getGlobalDescribe().get('ConfigurazioneGeolocalizzazione__mdt').getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues()){
            values.add(new FieldWrapper(ple.getLabel(), ple.getValue()));
        }
        return JSON.serialize(values);
    }

	@AuraEnabled
    public static String getTypeFields(String sObjectType, String fieldTypes){
        List<FieldWrapper> fields = new List<FieldWrapper>();
        Set<String> types = (Set<String>) JSON.deserialize(fieldTypes, Set<String>.class);

        // Retrieve all the fields of the object
        Map<String,Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap();
        
        // Check if there is at least one available field of the specified type
        Boolean availableFields = false;
        for(String fieldName : mapFields.keySet()){
            Schema.DescribeFieldResult field = mapFields.get(fieldName).getDescribe();
            if(types.contains(field.getType().name().toLowerCase()) && field.isAccessible()){
                availableFields = true;
                break;
            }
        }
        // If there are no accessible fields on the sObject return an error object
        if(mapFields.keySet().size() == 0 || !availableFields){
            fields.add(new FieldWrapper('No available fields.', ''));
        } else {
            // Otherwise put a dummy element followed by the available fields
            fields.add(new FieldWrapper('---', ''));
            for(String fieldName : mapFields.keySet()){
                Schema.DescribeFieldResult field = mapFields.get(fieldName).getDescribe();
                if(types.contains(field.getType().name().toLowerCase()) && field.isAccessible()){
                    fields.add(new FieldWrapper(field.getLabel(), field.getName()));
                }
            }
        }

        return JSON.serialize(fields);
    }

    @AuraEnabled
    public static String deployConfiguration(String jsonConfiguration, String[] fields){
        // Deserialize the configuration to deploy
        ConfigurazioneGeolocalizzazione__mdt configuration = (ConfigurazioneGeolocalizzazione__mdt) JSON.deserialize(jsonConfiguration, ConfigurazioneGeolocalizzazione__mdt.class);
        try{
            // Instantiate a container in which we will put the custom metadata to deploy and a variable representing the custom metadata
            Metadata.DeployContainer container = new Metadata.DeployContainer();
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();

            customMetadata.protected_x = false;
            customMetadata.fullName = 'ConfigurazioneGeolocalizzazione.'+configuration.QualifiedApiName;
            customMetadata.label = configuration.MasterLabel;
            // Populate the custommetadata to deploy with the values from the fields variable
            for(String field : fields){
                if(!field.equalsIgnoreCase('QualifiedApiName') && !field.equalsIgnoreCase('MasterLabel')){
                    Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                    customField.field = field;
                    customField.value = configuration.get(field);
                    customMetadata.values.add(customField);
                }
            }

            container.addMetadata(customMetadata);

            // Setup deploy callback, MyDeployCallback implements
            // the Metadata.DeployCallback interface (code for
            // this class not shown in this example)
            CustomMetadataCallback callback = new CustomMetadataCallback();
            
            // Deploy the container with the new components. 
            Id asyncResultIdCalcPunteggio = Metadata.Operations.enqueueDeployment(container, callback);
            return 'OK';
        } catch(Exception ex){
            return 'Error deploying configuration update ('+ex.getTypeName()+'): '+ex.getMessage()+' (Line '+ex.getLineNumber()+')';
        }
    }

    public class FieldWrapper{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String name {get; set;}

        public FieldWrapper(String label, String name){
            this.label = label;
            this.name = name;
        }
    }
}