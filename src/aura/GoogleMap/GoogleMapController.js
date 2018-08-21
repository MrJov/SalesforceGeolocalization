({
    doInit : function(component, event, helper) {
        //Send LC Host as parameter to VF page so VF page can send message to LC; make it all dynamic
        component.set('v.lcHost', window.location.hostname);
        
        //Add message listener
        window.addEventListener("message", function(event) {
            // Handle the message
            if(event.data.state == 'LOADED'){
                component.set('v.vfHost', event.data.vfHost);
                component.set('v.scriptLoaded', true);
                helper.sendToVF(component, helper);
            }

            if(event.data.state == 'PREDICTED'){
                component.set("v.predictedAddresses", event.data.places)
            }

            if(event.data.state == 'GEOCODED'){
                component.set("v.geolocatedAddress", event.data.place)
            }
        }, false);
    },

    handleSearch : function(component, event, helper){    
        helper.searchPlaces(component, helper);
    },

    geolocateAddress : function(component, event, helper){
        helper.geolocatePlace(component, helper);
    },

    pinCurrentLocation : function(component, event, helper){
        helper.pinCurrentLocation(component, helper);
    }
})