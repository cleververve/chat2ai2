/**
Author:         serhiivolynets
Date:           15.07.2020
Description:   
**/

public class Option
{
	@AuraEnabled @InvocableVariable public string sLabel='';
	@AuraEnabled @InvocableVariable public string sName='';
	@AuraEnabled @InvocableVariable public string sValue='';
	@AuraEnabled @InvocableVariable public string sFlow='';
	@AuraEnabled @InvocableVariable public string sType='';
	@AuraEnabled @InvocableVariable public string sName2='';
	@AuraEnabled @InvocableVariable public string sValue2='';
	@AuraEnabled @InvocableVariable public string sName3='';
	@AuraEnabled @InvocableVariable public string sValue3='';

	public integer iNumber;

	public string getBody()
	{
		return ''+iNumber+') '+sLabel;
	}
	public Option()
	{

	}

	public Option (string sLabel, integer iNumber , string sType, string sValue)
	{
		this.sLabel = sLabel;
		this.iNumber = iNumber;
		this.sType = sType;
		this.sValue = sValue;
	}

	@InvocableMethod(label='Option JSON' description='converts Option to JSON')
	public static list<string> toJSON(list<Option> loption)
	{
		system.debug('Option JSON.start '+loption);
		list<string>lret = new list<string>();

		for(Option opt: loption)
		{
			lret.add(JSON.serialize(opt));
		}
		system.debug('Option JSON.return '+lret);
		return lret;
	}
}
