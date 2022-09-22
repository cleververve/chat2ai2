/**
Author:         serhiivolynets
Date:           06.08.2022
Description:   
**/

global class FlowFacebookCatalogMulti2
{
	global class CatalogInput{
		@AuraEnabled @InvocableVariable global String to;
		@AuraEnabled @InvocableVariable global String headerText;
		@AuraEnabled @InvocableVariable global String bodyText;
		@AuraEnabled @InvocableVariable global String footerText;
		@AuraEnabled @InvocableVariable global String catalogId;
		@AuraEnabled @InvocableVariable global String sections;
		@AuraEnabled @InvocableVariable global String sFrom;
	}
	@InvocableMethod(Label='Send Facebook Multi Products' Description='Send Facebook Multi Products')
	global static void send(List<CatalogInput> lParam)
	{
		for(CatalogInput inp :lParam)
		{
			SM098_FacebookCatalog.sendMultiProducts(inp.to,inp.sFrom,inp.bodyText,inp.footerText,inp.catalogId,inp.sections,inp.headerText);
		}
	}
}
