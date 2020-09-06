/**
Author:         serhiivolynets
Date:           21.07.2020
Description:   
**/

global class FlowInputMessage
{
	@AuraEnabled @InvocableVariable global string sMessage;
	@AuraEnabled @InvocableVariable global string sFieldName;
	@AuraEnabled @InvocableVariable global string sFlow;
    @AuraEnabled @InvocableVariable global string sConfirmMessage;
    @AuraEnabled @InvocableVariable global string type;
	@AuraEnabled @InvocableVariable global id visitorId;


	@InvocableMethod(label='Input Message' description='Prompts Visitor to input data and saves the input in Visitor object field')
	global static void send(list<FlowInputMessage> lMessages)
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
            mo.sInputType = mess.type;
			lmo.add(mo);
		}
		MessageOptions.sendWF(lmo);
	}
}