# Salesforce Geolocalization

Collection of apex classes, triggers, visualforce pages and lightning components useful to enable google geocoding in a Salesforce org.
It includes:
* a schedulable batch used to geocode *n* records per day
* a trigger that resets the geocoding parameters fi something change
* a lightning component that can be called in a quick action to manually geocode the record.

All these operations can be done on any object (this package refers to the account object as example).

## Getting Started

Clone the project on your computer if you need to modify it, otherwise you can directly download it as a zip file.

### Prerequisites

In order to properly install this package in your org, you need to create the following fields on the object you want to geolocalize:
* NormalizzatoAmministrativoLiv1__c [Text(255)]
* NormalizzatoAmministrativoLiv2__c [Text(255)]
* NormalizzatoCap__c [Text(10)]
* NormalizzatoCivico__c [Text(5)]
* NormalizzatoCodiceNazione__c [Text(2)]
* NormalizzatoCoordinate__c [Location(Decimal, 8)]
* NormalizzatoIndirizzoEsteso__c [Text(255)]
* NormalizzatoIndirizzo__c [Text(255)]
* NormalizzatoLocalita__c [Text(255)]
* UltimoTentativoNormalizzazione__c [Datetime]
* UltimaNormalizzazione__c [Datetime]

### Installing

Once you have created the fields on the object to geolocalize, you can deply the pacake as a zip file to your org.