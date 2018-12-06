({
    getConfigs: function(component){
        // 
        var action = component.get('c.getConfigurazioni')
        action.setParams({fieldsToQuery: component.get('v.fields')})
        action.setCallback(this, function(response){
            var state = response.getState()
            if(state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue())
                component.set('v.configurations', result)
            } else {
                //  Handle error!
                this.displayToast(component, 'error', response.getError[0].message)
            }
        })
        $A.enqueueAction(action)
    },

    getAddressFormats: function(component){
        var action = component.get('c.getAddressFormats')
        action.setParams({field: 'GeocodingAddressFormat__c'})
        action.setCallback(this, function(response){
            var state = response.getState()
            if(state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue())
                component.set('v.addressFormats', result)
            } else {
                //  Handle error!
                this.displayToast(component, 'error', response.getError[0].message)
            }
        })
        $A.enqueueAction(action)
    },

    changeConfiguration: function(component, helper){
        var configurationName = component.get('v.selectedConfigurationName')
        var configurations = component.get('v.configurations')
        for(var i in configurations){
            if(configurations[i].QualifiedApiName == configurationName){
                component.set('v.isNew', false)
                component.set('v.selectedConfiguration', configurations[i])
                this.getObjectFields(component)
                break
            }
        }
    },

    getObjectFields: function(component){
        let types = ['boolean']
        this.getFields(component, types, 'booleanFields')
        types = ['datetime']
        this.getFields(component, types, 'dateTimeFields')
        types = ['string', 'textarea']
        this.getFields(component, types, 'textFields')
        types = ['integer']
        this.getFields(component, types, 'integerFields')
        types = ['double']
        this.getFields(component, types, 'doubleFields')
    },

    getFields: function(component, types, attribute){
        var action = component.get('c.getTypeFields')
        action.setParams({sObjectType: component.get('v.selectedConfiguration.ObjectAPIName__c'), fieldTypes: JSON.stringify(types)})
        action.setCallback(this, function(response){
            var state = response.getState()
            if(state === 'SUCCESS'){
                var result = []
                if(response.getReturnValue().length !== 0) result = JSON.parse(response.getReturnValue())
                component.set('v.'+attribute, result)
            } else {
                //  Handle error!
                this.displayToast(component, 'error', response.getError[0].message)
            }
        });
        $A.enqueueAction(action)
    },
    
    save: function(component){
        var config = component.get('v.selectedConfiguration')
        if(config.QualifiedApiName === '') config.QualifiedApiName = config.MasterLabel.replace(/\s/g,'')
        var action = component.get('c.deployConfiguration')
        action.setParams({jsonConfiguration: JSON.stringify(config), fields: component.get('v.fields')})
        action.setCallback(this, function(response){
            var state = response.getState()
            if(state === 'SUCCESS'){
                var result = response.getReturnValue()
                if(result === 'OK'){
                    this.displayToast(component, 'success', 'Configuration deployment started successfully.')
                } else {
                    this.displayToast(component, 'error', result)
                }
            } else {
                // Handle error!
                this.displayToast(component, 'error', response.getError()[0].message)
            }
        });
        $A.enqueueAction(action)
    },
    
    new: function(component){
        var config = {}
        var fields = component.get('v.fields')
        for(let i in fields){
            config[fields[i]] = ''
        }
        var configurations = component.get('v.configurations')
        configurations.push(config)
        component.set('v.configurations', configurations)
        component.set('v.selectedConfiguration', config)
        component.set('v.isNew', true)
    },

    // Client-side function that invokes the subscribe method on the empApi component.
    subscribe: function (component, event, helper) {
        // Get the empApi component.
        const empApi = component.find('empApi')
        // Get the channel from the attribute.
        const channel = component.get('v.channel')
        // Subscription option to get only new events.
        const replayId = -1
        // Callback function to be passed in the subscribe call.
        const callback = function (message) {
            helper.onReceiveNotification(component, message)
        }
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, $A.getCallback(callback))
        .then($A.getCallback(function (newSubscription) {
            component.set('v.subscription', newSubscription)
            component.set('v.subscriptionProblems', false)
        }))
    },

    // Client-side function that invokes the unsubscribe method on the empApi component.
    unsubscribe: function (component, event, helper) {
        // Get the empApi component.
        const empApi = component.find('empApi')
        // Get the channel from the component attribute.
        const channel = component.get('v.subscription').channel
        // Callback function to be passed in the unsubscribe call.
        const callback = function (message) {
            this.displayToast(component, 'info', 'Unsubscribed from channel ' + message.channel)
        };
        // Unsubscribe from the channel using the subscription object.        
        empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback))
    },

    // Client-side function that displays the platform event message in the console app and displays a toast if not muted.
    onReceiveNotification: function (component, message) {
        if(message.data.payload.CustomMetadataQualifiedApiName__c === 'ConfigurazioneGeolocalizzazione.'+component.get('v.selectedConfiguration').QualifiedApiName){
            // Extract notification from platform event
            const newNotification = {
                time: $A.localizationService.formatDateTime(
                    message.data.payload.CreatedDate, 'HH:mm'
                ),
                message: message.data.payload.Message__c
            };
            // Save notification in history
            const notifications = component.get('v.notifications')
            notifications.push(newNotification)
            component.set('v.notifications', notifications)
            let type = message.data.payload.DeployError__c ? 'error' : 'success'
            // Display notification in a toast
            this.displayToast(component, type, newNotification.message)
        }
    },
        
    // Displays the given toast message.
    displayToast: function (component, type, message) {
        const toastEvent = $A.get('e.force:showToast')
        toastEvent.setParams({
            type: type,
            message: message
        })
        toastEvent.fire()
    }
            
})