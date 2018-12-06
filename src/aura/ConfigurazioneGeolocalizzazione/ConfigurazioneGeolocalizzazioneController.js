({
    doInit: function(component, event, helper){
        helper.getConfigs(component)
        helper.getAddressFormats(component)
        component.set('v.subscriptionProblems', false)

        component.set('v.subscription', null)
        component.set('v.notifications', [])
        // Register error listener for the empApi component.
        const empApi = component.find('empApi')
        // Error handler function that prints the error to the console.
        const errorHandler = function (message) {
            console.error('Received error ', JSON.stringify(message));
            if(message.subscription === component.get('v.channel')){
                component.set('v.subscriptionProblems', true)
            }
        // helper.displayToast(component, 'error', JSON.stringify(message))
        };
        // Register error listener and pass in the error handler function.
        empApi.onError($A.getCallback(errorHandler))
        helper.subscribe(component, event, helper)
    },

    subscribe: function(component, event, helper){
        component.set('v.subscriptionProblems', false)
        component.set('v.subscription', null)
        component.set('v.notifications', [])
        // Register error listener for the empApi component.
        const empApi = component.find('empApi')
        // Error handler function that prints the error to the console.
        const errorHandler = function (message) {
            console.error('Received error ', JSON.stringify(message));
            if(message.subscription === component.get('v.channel')){
                component.set('v.subscriptionProblems', true)
            }
        // helper.displayToast(component, 'error', JSON.stringify(message))
        };
        // Register error listener and pass in the error handler function.
        empApi.onError($A.getCallback(errorHandler))
        helper.subscribe(component, event, helper)
    },
    
    changeConfiguration: function(component, event, helper){
        helper.changeConfiguration(component, helper)
    },

    save: function(component, event, helper){
        helper.save(component)
    },

    new: function(component, event, helper){
        helper.new(component)
    },

    changeObject: function(component, event, helper){
        helper.getObjectFields(component)
    }
})