/**
Author:         serhiivolynets
Date:           01.08.2022
Description:   
**/
@IsTest
public class FlowFacebookCatalogMultiTest
{
	@IsTest
	public static void send()
	{
		FlowFacebookCatalogMulti.CatalogSection section = new FlowFacebookCatalogMulti.CatalogSection();
		section.productItems = new List<String>{'111','222','333'};
		FlowFacebookCatalogMulti.CatalogInput inp = new FlowFacebookCatalogMulti.CatalogInput();
		inp.footerText = 'footer1';
		inp.bodyText = 'body1';
		inp.headerText = 'header1';
		inp.catalogId = '321';
		inp.sections = new List<FlowFacebookCatalogMulti.CatalogSection>{section};
		Test.startTest();
		FlowFacebookCatalogMulti.send(new List<FlowFacebookCatalogMulti.CatalogInput>{inp});
		Test.stopTest();
	}


	@IsTest
	public static void send2()
	{
		FlowFacebookCatalogMulti2.CatalogInput inp = new FlowFacebookCatalogMulti2.CatalogInput();
		inp.footerText = 'footer1';
		inp.bodyText = 'body1';
		inp.headerText = 'header1';
		inp.catalogId = '321';
		inp.sections = '[]';
		Test.startTest();
		FlowFacebookCatalogMulti2.send(new List<FlowFacebookCatalogMulti2.CatalogInput>{inp});
		Test.stopTest();
	}

}
