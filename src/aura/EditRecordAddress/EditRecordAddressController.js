({
    toggleDialog : function(component, event, helper) {
        helper.showHideModal(component);
        component.set("v.cssStyle", ".forceStyle .viewport .oneHeader {z-index:0; } .slds-global-header_container {position: static;} .forceStyle.desktop .viewport{overflow:hidden}");
        if(component.get("v.showModal")){
            var dialog = component.find("normalizzaIndirizzoDialog");
            $A.util.addClass(dialog, 'slds-modal');
            var container = component.find("normalizzaIndirizzoContainer");
            $A.util.addClass(container, 'slds-modal__container');
            var content = component.find("normalizzaIndirizzoContent");
            $A.util.addClass(content, 'slds-modal__content slds-p-around--medium slds-grid slds-wrap slds-grid--align-spread');
        }
    },
    
    closeDialog : function(component, event, helper) {
        helper.showHideModal(component);
        component.set("v.cssStyle", "");
        component.set("v.showComponent", false);

    },
    
    doInit : function(component, event, helper){
        helper.getLabels(component, event, helper);
        helper.getRecord(component, event, helper);
    },
    
    saveRecord : function(component, event, helper){
        helper.saveRecord(component, event, helper);
        helper.showHideModal(component);
        component.set("v.cssStyle", "");
        component.set("v.showComponent", false);
    },
    
    cancel : function(component, event, helper){
        //        alert('Canceled!');
    },
    
    copyAdminAddress : function(component, event, helper){
        helper.copyAdminAddress(component, event, helper);
    },
    
    triggerSearch : function(component, event, helper){
        var searchStr = component.get("v.adminAddress");
        if(searchStr.length > 0){
            var googleMap = component.find('googleMapVFCtrl');
            googleMap.handleSearch(googleMap);
        } else {
            component.set('v.showPredictionsList', false);
        }
    },
    
    getPredictions : function(component, event, helper){
        var predictions = event.getParam("prediction");
        component.set("v.predictions", predictions);
        component.set('v.showPredictionsList', true);
        var input = component.find("searchText");
        input.focus();
    },
    
    geolocateAddress : function(component, event, helper){
        var geoaddress = event.target.parentElement.parentElement.parentElement.getAttribute("id");
        var googleMap = component.find('googleMapVFCtrl');
        googleMap.set("v.geoaddress", geoaddress);
        googleMap.geolocateAddress(googleMap, event);
    },
    
    handleGeolocatedAddress : function(component, event, helper){
        console.log('EditRecordAddress Component -> handleGeolocatedAddress()')
        helper.setFields(component, event, helper);
        component.set('v.showPredictionsList', false);
    },
    
    showResults : function(component, event, helper){
        var predList = component.get("v.predictions");
        if(predList.length>0)
            component.set('v.showPredictionsList', true);
        
    },
    
    dismissResults : function(component, event, helper){
        component.set('v.showPredictionsList', false);
    }
})