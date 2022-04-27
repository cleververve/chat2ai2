/**
Author:         serhiivolynets
Date:           14.04.2022
Description:   
**/

global with sharing class FlowShortId
{
	global class ShortIdInput
	{
		@AuraEnabled @InvocableVariable global string sValue;
		@AuraEnabled @InvocableVariable global boolean bDecode;
		@AuraEnabled @InvocableVariable global string sPrefix;
	}
	@InvocableMethod(label='encode or decode shortId' description='encode or decode shortId')
	global static list<String> encode(list<ShortIdInput> lParam)
	{
		list<string>lRet = new list<string>();
		system.debug('FlowShortId.start');

		for(ShortIdInput inp: lParam)
		{
			if(inp.bDecode==true)
			{
				lRet.add(SM010_Utils.decodeId(inp.sValue,inp.sPrefix));
			}
			else
			{
				lRet.add(SM010_Utils.encodeId(inp.sValue));
			}
		}
		return lRet;
	}
}
