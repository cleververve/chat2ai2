/**
Author:         serhiivolynets
Date:           28.09.2022
Description:   
**/

global class FlowJPath
{
	@AuraEnabled @InvocableVariable global String Payload;
	@AuraEnabled @InvocableVariable global String Path1;
	@AuraEnabled @InvocableVariable global String Path2;
	@AuraEnabled @InvocableVariable global String Path3;
	@AuraEnabled @InvocableVariable global String Path4;
	@AuraEnabled @InvocableVariable global String Path5;
	@AuraEnabled @InvocableVariable global String Path6;
	@AuraEnabled @InvocableVariable global String Path7;
	@AuraEnabled @InvocableVariable global String Path8;
	@AuraEnabled @InvocableVariable global String Path9;
	@AuraEnabled @InvocableVariable global String Path10;

	global class FlowJPathReturn
	{
		@AuraEnabled @InvocableVariable global String Value1;
		@AuraEnabled @InvocableVariable global String Value2;
		@AuraEnabled @InvocableVariable global String Value3;
		@AuraEnabled @InvocableVariable global String Value4;
		@AuraEnabled @InvocableVariable global String Value5;
		@AuraEnabled @InvocableVariable global String Value6;
		@AuraEnabled @InvocableVariable global String Value7;
		@AuraEnabled @InvocableVariable global String Value8;
		@AuraEnabled @InvocableVariable global String Value9;
		@AuraEnabled @InvocableVariable global String Value10;
	}

	@InvocableMethod(Label='Parse JPath' Description='Parse JSON Node with JPath expression')
	global static List<FlowJPathReturn> parse(List<FlowJPath> lInput)
	{
		List<FlowJPathReturn> lRet = new List<FlowJPathReturn>();
		for (FlowJPath inp : lInput)
		{
			FlowJPathReturn ret = new FlowJPathReturn();
			try
			{
				Object payload = JSON.deserializeUntyped(inp.Payload);
				ret.Value1 = getJPath(payload, inp.Path1);
				ret.Value2 = getJPath(payload, inp.Path2);
				ret.Value3 = getJPath(payload, inp.Path3);
				ret.Value4 = getJPath(payload, inp.Path4);
				ret.Value5 = getJPath(payload, inp.Path5);
				ret.Value6 = getJPath(payload, inp.Path6);
				ret.Value7 = getJPath(payload, inp.Path7);
				ret.Value8 = getJPath(payload, inp.Path8);
				ret.Value9 = getJPath(payload, inp.Path9);
				ret.Value10 = getJPath(payload, inp.Path10);
			}
			catch (Exception e)
			{
				System.debug('Error ' + e);
			}
			lRet.add(ret);
		}
		return lRet;
	}

	public static String getJPath(Object payload, String path)
	{
		String ret = null;
		if (payload != null && path != null && path != '')
		{
			ret = String.valueOf(JPath.get0(payload, path));
		}
		return ret;
	}
}
