/**
Author:         serhiivolynets
Date:           15.07.2020
Description:   
**/

global class Option
{
	@AuraEnabled @InvocableVariable global string sLabel='';
	@AuraEnabled @InvocableVariable global string sName='';
	@AuraEnabled @InvocableVariable global string sValue='';
	@AuraEnabled @InvocableVariable global string sFlow='';
	@AuraEnabled @InvocableVariable global string sType='';
	@AuraEnabled @InvocableVariable global string sName2='';
	@AuraEnabled @InvocableVariable global string sValue2='';
	@AuraEnabled @InvocableVariable global string sName3='';
	@AuraEnabled @InvocableVariable global string sValue3='';
	//	@AuraEnabled @InvocableVariable public string sURL;

	public integer iNumber;
	public string getBody()
	{
		return ''+'*'+iNumber+')* '+sLabel;
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
	global static list<string> toJSON(list<Option> loption)
	{
		system.debug('Option JSON.start '+loption);
		list<string>lret = new list<string>();

		for(Option opt: loption)
		{
//			if(opt.sName == '') opt.sName = null;
//			if(opt.sValue == '') opt.sValue = null;
//			if(opt.sFlow == '') opt.sFlow = null;
//			if(opt.sType == null) opt.sType = null;

			lret.add(JSON.serialize(opt));
		}
		system.debug('Option JSON.return '+lret);
		return lret;
	}
}
