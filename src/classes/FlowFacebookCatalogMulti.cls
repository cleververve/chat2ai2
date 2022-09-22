/**
Author:         serhiivolynets
Date:           31.07.2022
Description:   
**/

global class FlowFacebookCatalogMulti
{
	global class CatalogInput{
		@AuraEnabled @InvocableVariable global String to;
		@AuraEnabled @InvocableVariable global String headerText;
		@AuraEnabled @InvocableVariable global String bodyText;
		@AuraEnabled @InvocableVariable global String footerText;
		@AuraEnabled @InvocableVariable global String catalogId;
		@AuraEnabled @InvocableVariable global CatalogSection[] sections;
	}

	global class CatalogSection{
		@AuraEnabled @InvocableVariable global String title;
		@AuraEnabled @InvocableVariable global String[] productItems;
	}

	@InvocableMethod(Label='old' Description='do not use')
	global static void send(List<CatalogInput> lParam)
	{
//		for(CatalogInput inp :lParam)
//		{
////			SM098_FacebookCatalog.sendMultiProducts(inp.to,inp.bodyText,inp.footerText,inp.catalogId,inp.sections);
//		}
	}
}
