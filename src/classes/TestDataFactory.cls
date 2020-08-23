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
		vis.CVCH__language__c = 'it';
		insert vis;

		account acc = new account();
		acc.Name = 'location1';
		acc.CVCH__Location__c = 'location1';
		insert acc;

		CVCH__Category__c cat = new CVCH__Category__c();
		cat.CVCH__Category__c = 'location1';
		cat.CVCH__Account__c = acc.Id;
		insert cat;

		CVCH__Values__c val = new CVCH__Values__c();
		val.Name = 'Insert Translations';
		val.CVCH__Value__c = 'TRUE';
		insert val;
	}
}
