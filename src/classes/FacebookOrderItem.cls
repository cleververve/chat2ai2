/**
Author:         serhiivolynets
Date:           01.08.2022
Description:   
**/

global class FacebookOrderItem
{
	@AuraEnabled @InvocableVariable global String sCurrency;
	@AuraEnabled @InvocableVariable global String SKU;
	@AuraEnabled @InvocableVariable global Decimal dPrice;
	@AuraEnabled @InvocableVariable global Decimal quantity;
}
