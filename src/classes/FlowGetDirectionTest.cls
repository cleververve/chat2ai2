/**
Author:         serhiivolynets
Date:           23.08.2020
Description:
**/
@IsTest
public class FlowGetDirectionTest
{
	@IsTest
	public static void testIt()
	{
		TestDataFactory data1 = new TestDataFactory();
		FlowGetDirection.FlowInput inp = new FlowGetDirection.FlowInput();
		inp.visitorId = data1.vis.Id;
		inp.type = 'get TOID';
		Test.startTest();
		FlowGetDirection.send(new list<FlowGetDirection.FlowInput> {inp});

		inp.type = 'get LINK';
		inp.location = 'location1';
		FlowGetDirection.send(new list<FlowGetDirection.FlowInput> {inp});
		inp.type = 'get FROMID';
		inp.entities= '{"shops":["123"]}';
		FlowGetDirection.send(new list<FlowGetDirection.FlowInput> {inp});
		Test.stopTest();
	}

}