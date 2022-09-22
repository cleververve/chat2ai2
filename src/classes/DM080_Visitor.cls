/**
Author:         serhiivolynets
Date:           18.07.2020
Description:   
**/

global class DM080_Visitor
{
	public static Map<Id,CVCH__Visitor__c> mVisitor = new Map<Id,CVCH__Visitor__c>();
	public static Map<string,CVCH__Visitor__c> mVisitorPhone = new Map<string,CVCH__Visitor__c>();
	public static List <CVCH__Visitor__c> getRecords(Set<Id> sid)
	{
		List<CVCH__Visitor__c> lVisitors = Database.query(getSOQLString()+' WHERE Id in :sid');
		hashVisitors(lVisitors);
		return lVisitors;
	}

	global static String getSOQLString()
	{
		Map<String,Schema.SObjectField> mapFld = CVCH__Visitor__c.SObjectType.getDescribe().fields.getMap();
		String sFields = String.join(new List<String>(mapFld.keySet()),',');
		sFields='SELECT '+sFields+',\n'+
				'CVCH__Last_Inbound_Message__r.Channel__c,\n' +
				'CVCH__Last_Inbound_Message__r.ChannelId__c,\n' +
				'CVCH__Last_Inbound_Message__r.From__c,\n' +
				'CVCH__Last_Inbound_Message__r.From_Name__c,\n' +
				'CVCH__Last_Inbound_Message__r.CVCH__conversationId__c,\n' +
				'CVCH__Last_Inbound_Message__r.CVCH__conversationName__c,\n' +
				'CVCH__Last_Inbound_Message__r.Name,\n' +
				'CVCH__Last_Inbound_Message__r.To__c,\n' +
				'CVCH__Last_Inbound_Message__r.To_Name__c,\n' +
				'CVCH__Last_Inbound_Message__r.Id\n' +
				' from CVCH__Visitor__c ';
		return sFields;
	}


	global static List <CVCH__Visitor__c> getRecordsbyNumber(String sid)
	{
		List<CVCH__Visitor__c> lVisitors = Database.query(getSOQLString()+' WHERE ID__c = :sid');
		hashVisitors(lVisitors);
		return lVisitors;
	}

	global static List<CVCH__Visitor__c> getRecordsbySessionId(String sid)
	{
		List<CVCH__Visitor__c> lVisitors = Database.query(getSOQLString()+' WHERE CVCH__Livechat_Session_Id__c = :sid');
		hashVisitors(lVisitors);
		return lVisitors;
	}

	global static void hashVisitors(List<CVCH__Visitor__c> lVisitors)
	{
		mVisitor.putAll(lVisitors);
		for(CVCH__Visitor__c vis : lVisitors)
			mVisitorPhone.put(vis.Id__c, vis);
	}

	global static CVCH__Visitor__c getVisitorById(id visitorId)
	{
		CVCH__Visitor__c ret;
		if(mVisitor != null)
			ret = mVisitor.get(visitorId);
		return ret;
	}
	global static CVCH__Visitor__c getVisitorByPhone(string phone)
	{
		CVCH__Visitor__c ret;
		if(mVisitorPhone != null)
			ret = mVisitorPhone.get(phone);
		if(ret == null)
		{
			list<CVCH__Visitor__c> lVisitors = getRecordsbyNumber(phone);
			if(!lVisitors.isEmpty())
				ret = lVisitors[0];
		}
		return ret;
	}
	global static id getVisitorId(string phone)
	{
		Visitor__c vis = getVisitorByPhone(phone);
		id visId;
		if(vis != null)
			visId = vis.Id;
		return visId;
	}
}
