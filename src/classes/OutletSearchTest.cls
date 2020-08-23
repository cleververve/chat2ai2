/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@IsTest
public class OutletSearchTest
{
	@IsTest
	public static void testIt()
	{
		TestDataFactory data1 = new TestDataFactory();
		Test.startTest();
		OutletSearch srch = new OutletSearch();
		srch.visitorId = data1.vis.Id;
		srch.keyword = 'location1';
		OutletSearch.search(new list<OutletSearch>{srch});

		OutletSearch srch2 = new OutletSearch();
		srch2.visitorId = data1.vis2.Id;
		srch2.keyword = 'location1';
		OutletSearch.search(new list<OutletSearch>{srch2});

		Test.stopTest();
	}

}
