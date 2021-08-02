/**
Author:         serhiivolynets
Date:           03.03.2021
Description:   
**/

global class SM089_Herc
{
	@InvocableMethod(label='Herc' description='Herc')
	global static void callHerc(list<HercInput> lInput)
	{
		CVCH__Chat2ai__c val = CVCH__Chat2ai__c.getInstance('Skip blockchain');
		if(val != null && val.CVCH__Value__c == 'TRUE')
			return;

		
		set<string>lNumber = new set<string>();
		for (HercInput inp : lInput)
		{
			String str1 = inp.ticketNumber;

			String[] arrStr = str1.split(',');
			for (string str : arrStr)
			{
				lNumber.add(str);
			}
		}
		list<CVCH__Ruffle_Draw_Ticket__c> lTick =
		[
				select id
				from CVCH__Ruffle_Draw_Ticket__c
				where CVCH__Short_Id__c in :lNumber
		];
		set<id>srecId = new set<id>();

		for (CVCH__Ruffle_Draw_Ticket__c tick : lTick)
		{
			srecId.add(tick.Id);
		}
		callItFuture2(srecId);
	}

	public static string getURL()
	{
		string sURL = CVCH.SM010_Utils.getChat2aiValue('Herc URL');
		sURL = sURL + '/timestamp/create';
		return sURL;
	}
	public static string getURL2()
	{
		string sURL = CVCH.SM010_Utils.getChat2aiValue('Herc URL');
		sURL = sURL + '/raffle-ticket/timestamp-reference';
		return sURL;
	}
	global class HercOutput
	{
		@AuraEnabled @InvocableVariable global string status;
		@AuraEnabled @InvocableVariable global string error;
	}

	global class HercInput
	{
		@AuraEnabled @InvocableVariable global string ticketNumber;
	}

	@Future(Callout = true)
	global static void callItFuture2(set<id> ticketId)
	{

		for(id recid: ticketId)
		{
			try
			{
				callIt(recid);
			}catch (Exception e)
			{}
		}
		CVCH.SM005_Logs.save();
	}


	global static HercOutput callIt(id ticketId)
	{

		HercOutput ret = new HercOutput();
		try
		{

			CVCH__Ruffle_Draw_Ticket__c ticket =
			[
					SELECT id,CVCH__Visitor__c,CVCH__Short_Id__c
					from CVCH__Ruffle_Draw_Ticket__c
					where id = :ticketId
			];
			Blob b1 = Blob.valueOf(ticket.CVCH__Short_Id__c);
			Blob b2 = Crypto.generateDigest('SHA256', b1);

			string sHash = EncodingUtil.convertToHex(b2);

//			if(Test.isRunningTest())
//				Test.setMock(HttpCalloutMock.class, new SM089_HercMock());
			HttpResponse resp = CVCH.SM003_Http.request(getURL(),
					'POST', headers(), getBody(ticket.CVCH__Visitor__c, sHash), 'Herc Create', ticketId, null);
			map<string, object> mResp = (map<string, object>) JSON.deserializeUntyped(resp.getBody());
			integer errorCode = (integer) mResp.get('errorCode');
			string errorMessage = (string) mResp.get('errorMessage');
			if (errorCode == 0)
			{

				map<string, object> mData = (map<string, object>) mResp.get('data');
				string hashString = (string) mData.get('hashString');
				HttpResponse resp2 = CVCH.SM003_Http.request(getURL2(),
						'POST', headers(), getBody2(ticket.CVCH__Visitor__c, hashString, ticket.CVCH__Short_Id__c), 'Herc timestamp', ticketId, 'SM089_HercMock');
				map<string, object> mResp2 = (map<string, object>) JSON.deserializeUntyped(resp2.getBody());
				integer statusCode = (integer) mResp2.get('statusCode');
				Boolean success = (Boolean) mResp2.get('success');
				if (success == true)
					ret.status = 'success';
				else
				{
					ret.status = 'error';
					ret.error = 'Herc timestamp was finished with ' + statusCode;
				}
			}
			else
			{

				ret.status = 'error';
				ret.error = errorMessage;
			}
		}
		catch (Exception e)
		{
			if (Test.isRunningTest())
				throw e;
			ret.status = 'error';
			ret.error = e.getMessage()+' '+e.getLineNumber()+' '+e.getStackTraceString();
		}
		return ret;
	}

	public static Map<String, String> headers()
	{
		map<string, string> mRet = new map<string, string>();
		mRet.put('partner_id', CVCH.SM010_Utils.getChat2aiValue('Herc partner_id'));
		mRet.put('api_key', CVCH.SM010_Utils.getChat2aiValue('Herc api_key'));
		mRet.put('Content-Type', 'application/json');
		system.debug(mRet);
		return mRet;
	}
	public static string getBody(string sVisitorId, string sHash)
	{
		map<string, string>mRet = new map<string, string>();
		mRet.put('comment', sVisitorId);
		mRet.put('hash', sHash);
		return JSON.serialize(mRet);
	}

	public static string getBody2(string sVisitorId, string hashString, string ticketNumber)
	{
		map<string, string>mRet = new map<string, string>();
		mRet.put('userId', sVisitorId);
		mRet.put('raffleTicketId', ticketNumber);
		mRet.put('timestampHash', hashString);
		return JSON.serialize(mRet);
	}
}