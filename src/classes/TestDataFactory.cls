/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/

public class TestDataFactory
{
	public CVCH__Visitor__c vis;
	public TestDataFactory()
	{
		vis = new CVCH__Visitor__c();
		vis.CVCH__LastName__c = 'lastName';
		vis.CVCH__Id__c = '111';
		insert vis;
	}

}
