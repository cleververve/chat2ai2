/**
Author:         serhiivolynets
Date:           14.04.2022
Description:   
**/
@IsTest
public with sharing class FlowShortIdTest
{
	@IsTest
	public static void testData()
	{
		Test.startTest();
		FlowShortId.ShortIdInput inp = new FlowShortId.ShortIdInput();
		inp.sValue='11111';
		list<FlowShortId.ShortIdInput> linp = new list<FlowShortId.ShortIdInput>();
		linp.add(inp);
		list<string> lStr = FlowShortId.encode(linp);
		inp.sValue = lStr[0];
		inp.bDecode = true;
		inp.sPrefix = 'TXN';
		lStr = FlowShortId.encode(linp);
		Test.stopTest();
	}
}
