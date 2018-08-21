({
    showHideModal : function(component) {
        var modal = component.find("normalizzaIndirizzoDialog");
        $A.util.toggleClass(modal, 'slds-fade-in-open');
        var overlay = component.find("overlay");
        $A.util.toggleClass(overlay, 'slds-backdrop--open');
        component.set("v.showDialog", "false");
    },
    
    getLabels : function(cmp, ev, hlp){
        var action = cmp.get("c.init");
        var accId = cmp.get("v.recordId");
        action.setParams({ recordId : accId });
        action.setCallback(this, function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var labels = response.getReturnValue();
                var fields = Object.keys(labels);
                for(var i=0; i<fields.length; i++){
                    cmp.set("v."+fields[i], labels[fields[i]]);
                }
            }
            else{
                hlp.showToast(status, response.getError(), "error");
            }
        });
        $A.enqueueAction(action);
    },
    
    copyAdminAddress : function(cmp, ev, hlp){
        var action = cmp.get("c.getAdminAddress");
        var accId = cmp.get("v.recordId");
        var fields = cmp.get("v.adminAddressFields");
        action.setParams({ recordId : accId, fieldsString: fields });
        action.setCallback(this, function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.startsWith('ERRORE')){
                    hlp.showToast('ERROR', result, "error");
                } else {
                    cmp.set("v.adminAddress", result);
                    var action = cmp.get("c.triggerSearch");
                    action.setCallback(this, function(result){
                        if(result.getState() == "SUCCESS"){
                            var res = result.getReturnValue();
                        }
                    })
                    $A.enqueueAction(action);
                }
            }
            else{
                hlp.showToast(status, response.getError(), "error");
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecord : function(cmp, ev, hlp){
        var record = cmp.get("v.record");
        if(record == undefined || record == null){
            var action = cmp.get("c.getRecord");
            var recId = cmp.get("v.recordId");
            var addressFields = cmp.get("v.adminAddressFields");
            action.setParams({recordId : recId, fieldsString: addressFields});
            action.setCallback(this, function(response){
                var status = response.getState();
                if(status === "SUCCESS"){
                    var record = JSON.parse(response.getReturnValue());
                    cmp.set("v.record", record);
                }
                else{
                    hlp.showToast(status, response.getError(), "error");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    setFields : function(component, event, helper){
        // var place = event.getParam("geolocation")[0];
        var place = component.get("v.geolocatedAddress");
        var componentForm = {
            street_number: 'short_name',
            route: 'long_name',
            locality: 'long_name',
            administrative_area_level_1: 'short_name',
            administrative_area_level_2: 'short_name',
            country: 'short_name',
            postal_code: 'short_name'
        };
        
        var fieldMap = {};
        fieldMap['street_number']='NormalizzatoCivico__c';
        fieldMap['route']='NormalizzatoIndirizzo__c';
        fieldMap['locality']='NormalizzatoLocalita__c';
        fieldMap['administrative_area_level_1']='NormalizzatoAmministrativoLiv1__c';
        fieldMap['administrative_area_level_2']='NormalizzatoAmministrativoLiv2__c';
        fieldMap['country']='NormalizzatoCodiceNazione__c';
        fieldMap['postal_code']='NormalizzatoCap__c';
        
        component.set("v.record.NormalizzatoCivico__c", '');
        component.set("v.record.NormalizzatoIndirizzo__c", '');
        component.set("v.record.NormalizzatoLocalita__c", '');
        component.set("v.record.NormalizzatoAmministrativoLiv1__c", '');
        component.set("v.record.NormalizzatoAmministrativoLiv2__c", '');
        component.set("v.record.NormalizzatoCodiceNazione__c", '');
        component.set("v.record.NormalizzatoCap__c", '');
        component.set("v.record.NormalizzatoIndirizzoEsteso__c", '');
        component.set("v.record.NormalizzatoCoordinate__Latitude__s", null);
        component.set("v.record.NormalizzatoCoordinate__Longitude__s", null);
        
        for (var i = 0; i < place.address_components.length; i++) {
            var addressType = place.address_components[i].types[0];
            if (componentForm[addressType]) {
                var val = place.address_components[i][componentForm[addressType]];
                component.set("v.record."+fieldMap[addressType], val);
            }
        }
        component.set("v.record.NormalizzatoIndirizzoEsteso__c", place.formatted_address);
        component.set("v.adminAddress", place.formatted_address);
        component.set("v.record.NormalizzatoCoordinate__Latitude__s", parseFloat(place.geometry.location.lat.toFixed(8)));
        component.set("v.record.NormalizzatoCoordinate__Longitude__s", parseFloat(place.geometry.location.lng.toFixed(8)));
    },
    
    saveRecord : function(cmp, ev, hlp){
        var recordObj = cmp.get("v.record");
        var recId = cmp.get("v.recordId");
        var action = cmp.get("c.save");
        action.setParams({ jsonRec : JSON.stringify(recordObj), recordId : recId});
        action.setCallback(this, function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                console.log('Success')
                var result = response.getReturnValue();
                if(result.startsWith('ERRORE')){
                    hlp.showToast('ERROR', result, "error");
                } else {
                    var compEvent = cmp.getEvent('changeAddress');
                    compEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    hlp.showToast(status, response.getReturnValue(), "success");
                }
            }
            else{
                console.log(response.getError())
                hlp.showToast(status, response.getError(), "error");
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