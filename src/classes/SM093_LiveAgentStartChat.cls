/**
Author:         serhiivolynets
Date:           23.08.2021
Description:   
**/

global class SM093_LiveAgentStartChat
{
	@AuraEnabled @InvocableVariable global Id visitorId;
	@AuraEnabled @InvocableVariable global String paramName1;
	@AuraEnabled @InvocableVariable global String paramValue1;
	@AuraEnabled @InvocableVariable global String fieldName1;

	@AuraEnabled @InvocableVariable global String paramName2;
	@AuraEnabled @InvocableVariable global String paramValue2;
	@AuraEnabled @InvocableVariable global String fieldName2;

	@AuraEnabled @InvocableVariable global String paramName3;
	@AuraEnabled @InvocableVariable global String paramValue3;
	@AuraEnabled @InvocableVariable global String fieldName3;

	@AuraEnabled @InvocableVariable global String paramName4;
	@AuraEnabled @InvocableVariable global String paramValue4;
	@AuraEnabled @InvocableVariable global String fieldName4;

	@AuraEnabled @InvocableVariable global String paramName5;
	@AuraEnabled @InvocableVariable global String paramValue5;
	@AuraEnabled @InvocableVariable global String fieldName5;

	@InvocableMethod(label='Start Chat' description='Start chat')
	global static void StartChat(List<SM093_LiveAgentStartChat> lParam)
	{
		System.debug('start chat');
		try
		{


		Map<Id, CVCH__Visitor__c> mUpdate = new Map<Id, CVCH__Visitor__c>();
		Set<Id>sids = new Set<Id>();
		for (SM093_LiveAgentStartChat inp : lParam)
		{
			sids.add((id) inp.visitorId);
		}
		Map<Id, CVCH__Visitor__c> mVis = new Map<Id, CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		for (SM093_LiveAgentStartChat inp : lParam)
		{
			CVCH__Visitor__c vis = mVis.get(inp.visitorId);
			if (vis == null)
				throw new MyException('Can not find visitor ' + inp.visitorId);
			if (vis.CVCH__Livechat_Session_Key__c != null && vis.CVCH__Livechat_Session_Key__c != '')
				throw new MyException('Please close the previous live chat in order to start a new one.');
			Map<String, String> mPar = new Map<String, String>();
			if (inp.paramName1 != null && inp.paramValue1 != null && inp.paramName1 != '' && inp.paramValue1 != '')
				mPar.put(inp.paramName1, inp.paramValue1);
			if (inp.paramName2 != null && inp.paramValue2 != null && inp.paramName2 != '' && inp.paramValue2 != '')
				mPar.put(inp.paramName2, inp.paramValue2);
			if (inp.paramName3 != null && inp.paramValue3 != null && inp.paramName3 != '' && inp.paramValue3 != '')
				mPar.put(inp.paramName3, inp.paramValue3);
			if (inp.paramName4 != null && inp.paramValue4 != null && inp.paramName4 != '' && inp.paramValue4 != '')
				mPar.put(inp.paramName4, inp.paramValue4);
			if (inp.paramName5 != null && inp.paramValue5 != null && inp.paramName5 != '' && inp.paramValue5 != '')
				mPar.put(inp.paramName5, inp.paramValue5);

			if (!SM093_LiveAgent.isAvailable())
			{
				SM042_NexmoOut2.sendText(vis.CVCH__Id__c, SM010_Utils.translate('There is no available agents at the moment. Please try again later.',vis.CVCH__language__c), vis.CVCH__Chat_Number__c, false);
//				throw new MyException('There is no available agents at the moment. Please try again later.');
			}
			else
			{
				SM093_LiveAgent.InitSessionResponse resp = SM093_LiveAgent.initSession('null');
				SM093_LiveAgent.ChasitorInit(resp.affinityToken, resp.key, resp.id, vis.Name,getChatDetails(inp));
				SM042_NexmoOut2.sendText(vis.CVCH__Id__c, SM010_Utils.translate('Connected to live chat', vis.CVCH__language__c), vis.CVCH__Chat_Number__c, false);
				mUpdate.put(vis.Id, new CVCH__Visitor__c(Id = vis.Id, CVCH__Livechat_Session_Key__c = resp.key, Livechat_affinityToken__c = resp.affinityToken, Livechat_Session_Id__c = resp.id));
			}
		}

		if (!mUpdate.isEmpty())
		{
			update mUpdate.values();
		}
		}catch(Exception e)
		{
			System.debug('Exception :'+e.getMessage() + ' '+e.getStackTraceString());
			throw e;
		}
	}

//	[
//	{
//	"label":"Accepted",
//		"value": True,
//		"transcriptFields":[
//		"CC_Accepted_by_specialist__c"
//		],
//		"displayToAgent": True
//},
//{
//"label":"AccepeptedByAgentTime",
//"value": "2020-01-10T10:00:00.000Z",
//"transcriptFields":[
//"CC_Accepted_by_specialist_DateTime__c"
//],
//"displayToAgent": True
//},
//]

	public static Map<String,Object> getElement(String paramName, String paramValue, String fieldName)
	{
		Map<String, Object> mel = new Map<String,Object>();
		mel.put('displayToAgent', true);
		if(fieldName != null && fieldName != '')
			mel.put('transcriptFields',new List<Object>{fieldName});
		else
				mel.put('transcriptFields',new List<Object>{});
		mel.put('entityFieldMaps',new List<Object>());
		mel.put('value',paramValue);
		mel.put('label',paramName);
		return mel;
	}
	public static String getChatDetails(SM093_LiveAgentStartChat inp)
	{
		List<Object> lRet = new List<Object>();
		if (inp.paramName1 != null && inp.paramValue1 != null && inp.paramName1 != '' && inp.paramValue1 != '')
			lRet.add(getElement(inp.paramName1, inp.paramValue1,inp.fieldName1));
		if (inp.paramName2 != null && inp.paramValue2 != null && inp.paramName2 != '' && inp.paramValue2 != '')
			lRet.add(getElement(inp.paramName2, inp.paramValue2,inp.fieldName2));
		if (inp.paramName3 != null && inp.paramValue3 != null && inp.paramName3 != '' && inp.paramValue3 != '')
			lRet.add(getElement(inp.paramName3, inp.paramValue3,inp.fieldName3));
		if (inp.paramName4 != null && inp.paramValue4 != null && inp.paramName4 != '' && inp.paramValue4 != '')
			lRet.add(getElement(inp.paramName4, inp.paramValue4,inp.fieldName4));
		if (inp.paramName5 != null && inp.paramValue5 != null && inp.paramName5 != '' && inp.paramValue5 != '')
			lRet.add(getElement(inp.paramName5, inp.paramValue5,inp.fieldName5));
		return JSON.serialize(lRet);
	}
}
