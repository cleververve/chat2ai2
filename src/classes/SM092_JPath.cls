/**
Author:         serhiivolynets
Date:           20.04.2021
Description:   
**/

global class SM092_JPath
{
	global class JPathInput
	{
		@AuraEnabled @InvocableVariable global string rawJson;
		@AuraEnabled @InvocableVariable global string sPath;
	}
	global class JPathOutput
	{
		@AuraEnabled @InvocableVariable global string sValue;
		@AuraEnabled @InvocableVariable global string sErrorMessage;
	}

	@InvocableMethod(label='JPath' description='JPath')
	global static list<JPathOutput> getValue(list<JPathInput> lInputs)
	{
		list<JPathOutput>lRet = new list<JPathOutput>();
		for(JPathInput inp: lInputs)
		{
			JPathOutput out = new JPathOutput();
			try
			{
				out.sValue =  ''+JPath.get(inp.rawJson,inp.sPath);
			}catch(Exception e)
			{
				out.sErrorMessage = e.getMessage();
			}
			lRet.add(out);
		}
		return lRet;
	}
}
