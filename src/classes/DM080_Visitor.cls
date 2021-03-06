/**
Author:         serhiivolynets
Date:           18.07.2020
Description:   
**/

public class DM080_Visitor
{

	public static list <CVCH__Visitor__c> getRecords(set<id> sid)
	{
        map<string,Schema.SObjectField> mapFld = CVCH__Visitor__c.SObjectType.getDescribe().fields.getMap();
        
		list<CVCH__Visitor__c> lVisitors = Database.query('select '+string.join(new list<string>(mapFld.keyset()),',')+' from CVCH__Visitor__c where ID in :sid');//[select id,Context__c,Id__c,Chat_Number__c,language__c, location__c  from Visitor__c where ID = :sid];
		return lVisitors;
	}
    
    public static list <CVCH__Visitor__c> getRecordsbyNumber(string sid)
	{
        map<string,Schema.SObjectField> mapFld = CVCH__Visitor__c.SObjectType.getDescribe().fields.getMap();
        
		list<CVCH__Visitor__c> lVisitors = Database.query('select '+string.join(new list<string>(mapFld.keyset()),',')+' from CVCH__Visitor__c where ID__c = :sid');//[select id,Context__c,Id__c,Chat_Number__c,language__c, location__c  from Visitor__c where ID__c = :sid];
		return lVisitors;
	}

}