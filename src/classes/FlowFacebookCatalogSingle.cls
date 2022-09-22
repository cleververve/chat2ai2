/**
Author:         serhiivolynets
Date:           31.07.2022
Description:   
**/

global class FlowFacebookCatalogSingle
{
	global class CatalogInput{
		@AuraEnabled @InvocableVariable global String to;
		@AuraEnabled @InvocableVariable global String headerText;
		@AuraEnabled @InvocableVariable global String bodyText;
		@AuraEnabled @InvocableVariable global String footerText;
		@AuraEnabled @InvocableVariable global String catalogId;
		@AuraEnabled @InvocableVariable global String SKU;
		@AuraEnabled @InvocableVariable global String sFrom;
	}

	global class CatalogSection{
		@AuraEnabled @InvocableVariable global String title;
		@AuraEnabled @InvocableVariable global String[] productItems;
	}

	@InvocableMethod(Label='Send Facebook Single Product' Description='Send Facebook Single Product')
	global static void send(List<CatalogInput> lParam)
	{
		for(CatalogInput inp :lParam)
		{
			SM098_FacebookCatalog.sendSingleProduct(inp.to,inp.sFrom,inp.bodyText,inp.footerText,inp.catalogId,inp.SKU);
		}
	}
}
