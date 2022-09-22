/**
Author:         serhiivolynets
Date:           01.08.2022
Description:   
**/
@IsTest
public class FlowFacebookCatalogSingleTest
{
	@IsTest
	public static void send()
	{
		FlowFacebookCatalogSingle.CatalogInput inp = new FlowFacebookCatalogSingle.CatalogInput();
		inp.SKU = '1234';
		inp.footerText = 'footer1';
		inp.bodyText = 'body1';
		inp.headerText = 'header1';
		inp.catalogId = '321';
		inp.SKU = '222';
		Test.startTest();
		FlowFacebookCatalogSingle.send(new list<FlowFacebookCatalogSingle.CatalogInput>{inp});
		Test.stopTest();
	}
}
