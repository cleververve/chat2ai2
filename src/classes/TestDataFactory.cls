/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/

public class TestDataFactory
{
	public CVCH__Visitor__c vis;
	public CVCH__Visitor__c vis2;
	public account acc;
	public TestDataFactory()
	{
		list<CVCH__Visitor__c> lIns = new list<CVCH__Visitor__c>();
		vis = new CVCH__Visitor__c();
		vis.CVCH__LastName__c = 'lastName1';
		vis.CVCH__Id__c = '111';
		vis.CVCH__language__c = 'it';
		vis.CVCH__Chanel__c = 'whatsapp';
		lIns.add(vis);

		vis2 = new CVCH__Visitor__c();
		vis2.CVCH__LastName__c = 'lastName2';
		vis2.CVCH__Id__c = '222';
		vis2.CVCH__language__c = 'it';
		lIns.add(vis2);

		insert lIns;

		acc = new account();
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
