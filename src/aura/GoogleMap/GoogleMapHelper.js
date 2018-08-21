({
    sendToVF : function(component, helper) {
        //Prepare message in the format required in VF page
        var message = {
            loadGoogleMap: false,
            predictAddress: false,
            geolocateAddress: false,
            address: component.get('v.address') != undefined ? component.get('v.address') : ''
        }

        //Send message to VF
        helper.sendMessage(component, message)
    },

    searchPlaces : function(component, helper) {
        //Prepare message in the format required in VF page
        var message = {
            loadGoogleMap: false,
            predictAddress: true,
            geolocateAddress: false,
            address: component.get('v.address')
        }

        //Send message to VF
        helper.sendMessage(component, message);
    },

    geolocatePlace : function(component, helper) {
        
        //Prepare message in the format required in VF page
        var message = {
            loadGoogleMap: false,
            predictAddress: false,
            geolocateAddress: true,
            address: component.get('v.geoaddress')
        }
        console.log('GoogleMap Component -> geolocatePlace() | message: ', message)

        //Send message to VF
        helper.sendMessage(component, message);
    },

    pinCurrentLocation : function(component, helper) {
        //Prepare message in the format required in VF page
        var message = {
            loadGoogleMap: false,
            predictAddress: false,
            geolocateAddress: false,
            pinCurrentLocation: true,
            address: component.get('v.geoaddress')
        }

        //Send message to VF
        helper.sendMessage(component, message);
    },

    sendMessage: function(component, message){
        //Send message to VF
        message.origin = window.location.hostname;
        if(component.find("vfFrame") !== undefined && component.find("vfFrame").getElement() !== null){
            var vfWindow = component.find("vfFrame").getElement().contentWindow;
            vfWindow.postMessage(JSON.stringify(message), component.get("v.vfHost"));
        }
    }
})