/**
Author:         serhiivolynets
Date:           21.07.2020
Description:   
**/

public with sharing class FlowInputMessage
{
	@AuraEnabled @InvocableVariable public string sMessage;
	@AuraEnabled @InvocableVariable public string sFieldName;
	@AuraEnabled @InvocableVariable public string sFlow;
    @AuraEnabled @InvocableVariable public string sConfirmMessage;
	@AuraEnabled @InvocableVariable public id visitorId;
    


	@InvocableMethod(label='Input Message' description='Prompts Visitor to input data and saves the input in Visitor object field')
	public static void send(list<FlowInputMessage> lMessages)
	{
		list<MessageOptions> lmo = new list<MessageOptions>();
		for(FlowInputMessage mess: lMessages)
		{
			MessageOptions mo = new MessageOptions();
			mo.sType = 'Input';
			mo.sFlow = mess.sFlow;
			mo.sFieldName = mess.sFieldName;
			mo.sMessage = mess.sMessage;
			mo.visitorId = mess.visitorId;
            mo.sConfirmMessage = mess.sConfirmMessage;
			lmo.add(mo);
		}
		MessageOptions.sendWF(lmo);
	}
}