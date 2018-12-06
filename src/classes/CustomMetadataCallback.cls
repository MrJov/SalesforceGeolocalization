public class CustomMetadataCallback implements Metadata.DeployCallback {
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        // Generate new platform event to tell the configuration component the deploy result
        GeolocationMetadataDeploy__e deployEvent = new GeolocationMetadataDeploy__e();
            
        // Get the correct deploy messages. If the deploy failed set the flag on the event object
        List<Metadata.DeployMessage> deployMessages = new List<Metadata.DeployMessage>();
        if (result.status == Metadata.DeployStatus.Succeeded) {
            deployMessages = result.details.componentSuccesses;
        } else {
            deployMessages = result.details.componentFailures;
            deployEvent.DeployError__c = true;
        }

        // Scan the messages to find the one about the custom metadata and set the other fields on the event object
        for(Metadata.DeployMessage  message : deployMessages){
            if(message.componentType != null && message.componentType.equalsIgnoreCase('CustomMetadata')){
                deployEvent.CustomMetadataQualifiedApiName__c = message.fullName;
                if(deployEvent.DeployError__c == true){
                    deployEvent.Message__c = message.problem;
                } else {
                    deployEvent.Message__c = 'Metadata successfully updated.';
                }
            }
        }

        // Call method to publish the event
        Database.SaveResult sr = EventBus.publish(deployEvent);
        // Inspect publishing result 
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
            }
        }
    }
}