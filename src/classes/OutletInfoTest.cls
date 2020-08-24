/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/
@IsTest
public class OutletInfoTest
{
	@IsTest
	public static void testIt()
	{
		TestDataFactory data1 = new TestDataFactory();
		Test.startTest();
		OutletInfo.OutletInfoRequest inp = new OutletInfo.OutletInfoRequest();
		inp.visitorId = data1.vis.id;
		inp.outletId = data1.acc.id;
		OutletInfo.getOutlet(new list<OutletInfo.OutletInfoRequest> {inp});

		Test.stopTest();
	}

	@IsTest
	public static void testIt3()
	{
		TestDataFactory data1 = new TestDataFactory();
		Test.startTest();
		OutletInfo3 inp = new OutletInfo3();
		inp.visitorId = data1.vis.id;
		inp.outletId = data1.acc.id;
		OutletInfo3.getOutlet(new list<OutletInfo3> {inp});

		Test.stopTest();
	}
}
