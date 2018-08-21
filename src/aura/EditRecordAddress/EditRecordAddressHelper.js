({
    showHideModal : function(component) {
        var modal = component.find("normalizzaIndirizzoDialog");
        $A.util.toggleClass(modal, 'slds-fade-in-open');
        var overlay = component.find("overlay");
        $A.util.toggleClass(overlay, 'slds-backdrop--open');
        component.set("v.showDialog", "false");
    },
    
    copyAdminAddress : function(component, helper){
        var action = component.get("c.getAdminAddress");
        var accId = component.get("v.recordId");
        var fields = component.get("v.adminAddressFields");
        action.setParams({ recordId : accId, fieldsString: fields });
        action.setCallback(this, function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.startsWith('ERRORE')){
                    helper.showToast('ERROR', result, "error");
                } else {
                    component.set("v.adminAddress", result);
                    var action = component.get("c.triggerSearch");
                    action.setCallback(this, function(result){
                        if(result.getState() == "SUCCESS"){
                            var res = result.getReturnValue();
                        }
                    })
                    $A.enqueueAction(action);
                }
            }
            else{
                helper.showToast(status, response.getError(), "error");
            }
        });
        $A.enqueueAction(action);
    },
    
    setFields : function(component, helper){
        var place = component.get("v.geolocatedAddress")[0];
        var componentForm = {
            street_number: 'short_name',
            route: 'long_name',
            locality: 'long_name',
            administrative_area_level_1: 'short_name',
            administrative_area_level_2: 'short_name',
            country: 'short_name',
            postal_code: 'short_name'
        };
        
        var fieldMap = {
            street_number: 'NormalizzatoCivico__c',
            route: 'NormalizzatoIndirizzo__c',
            locality: 'NormalizzatoLocalita__c',
            administrative_area_level_1: 'NormalizzatoAmministrativoLiv1__c',
            administrative_area_level_2: 'NormalizzatoAmministrativoLiv2__c',
            country: 'NormalizzatoCodiceNazione__c',
            postal_code: 'NormalizzatoCap__c'
        };

        var record = {
            Id: component.get('v.recordId'),
            NormalizzatoCivico__c: '',
            NormalizzatoIndirizzo__c: '',
            NormalizzatoLocalita__c: '',
            NormalizzatoAmministrativoLiv1__c: '',
            NormalizzatoAmministrativoLiv2__c: '',
            NormalizzatoCodiceNazione__c: '',
            NormalizzatoCap__c: '',
            NormalizzatoIndirizzoEsteso__c: '',
            NormalizzatoCoordinate__Latitude__s: null,
            NormalizzatoCoordinate__Longitude__s: null
        }
        
        for (var i = 0; i < place.address_components.length; i++) {
            var addressType = place.address_components[i].types[0];
            if (componentForm[addressType]) {
                var val = place.address_components[i][componentForm[addressType]];
                record[fieldMap[addressType]] = val;
            }
        }

        record.NormalizzatoIndirizzoEsteso__c = place.formatted_address;
        record.NormalizzatoCoordinate__Latitude__s = parseFloat(place.geometry.location.lat.toFixed(8));
        record.NormalizzatoCoordinate__Longitude__s = parseFloat(place.geometry.location.lng.toFixed(8));
        component.set('v.adminAddress', place.formatted_address);
        component.set('v.record', record);
        helper.saveRecord(component, helper)
    },
    
    saveRecord : function(component, helper){
        var recordObj = component.get("v.record");
        var recId = component.get("v.recordId");
        var action = component.get("c.save");
        action.setParams({ jsonRec : JSON.stringify(recordObj), recordId : recId});
        action.setCallback(this, function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.startsWith('ERRORE')){
                    helper.showToast('ERROR', result, "error");
                } else {
                    $A.get('e.force:refreshView').fire();
                    helper.showToast(status, response.getReturnValue(), "success");
                }
            }
            else{
                helper.showToast(status, response.getError(), "error");
            }
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode" : "dismissible"
        });
        toastEvent.fire();
    }
})