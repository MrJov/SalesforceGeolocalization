trigger AccountTrigger on Account (before update) {
  if(!AccountTriggerHandler.skipTrigger){
    if(T.isBeforeUpdate()){
      AccountTriggerHandler.beforeUpdate(new T(Trigger.new, Trigger.oldMap));      
    }
  }
}