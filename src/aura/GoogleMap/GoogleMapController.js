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
                var evt = component.getEvent("prediction");
                if(evt != undefined){
                    evt.setParams({ "prediction" : event.data.places });
                    evt.fire();
                }
            }

            if(event.data.state == 'GEOCODED'){
                var evt = component.getEvent("geolocation");
                console.log('GEOCODED! '+evt)
                if(evt != undefined){
                    evt.setParams({ "geolocation" : event.data.place });
                    evt.fire();
                }
                // component.set("v.geolocatedAddress", event.data.place)
            }
        }, false);
    },

    handleSearch : function(component, event, helper){    
        helper.searchPlaces(component, helper);
    },

    geolocateAddress : function(component, event, helper){
        console.log('GoogleMap Component -> geolocateAddress()')
        var evt = component.getEvent("geolocation");
        helper.geolocatePlace(component, helper);
    },

    pinCurrentLocation : function(component, event, helper){
        helper.pinCurrentLocation(component, helper);
    }
})