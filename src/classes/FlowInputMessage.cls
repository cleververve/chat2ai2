/**
Author:         serhiivolynets
Date:           21.07.2020
Description:   
**/

global class FlowInputMessage
{
	@AuraEnabled @InvocableVariable global String sMessage;
	@AuraEnabled @InvocableVariable global String sFieldName;
	@AuraEnabled @InvocableVariable global String sParamName;
	@AuraEnabled @InvocableVariable global String sFlow;
	@AuraEnabled @InvocableVariable global String flowParamsJSON;
    @AuraEnabled @InvocableVariable global String sConfirmMessage;
    @AuraEnabled @InvocableVariable global String type;
	@AuraEnabled @InvocableVariable global Id visitorId;
	@AuraEnabled @InvocableVariable global String OrchestrationInstance;
	@AuraEnabled @InvocableVariable global String OrchestrationInstance2;


	@InvocableMethod(Label='Input Message' Description='Prompts Visitor to input data and saves the input in Visitor object field')
	global static void send(List<FlowInputMessage> lMessages)
	{
		List<MessageOptions> lmo = new List<MessageOptions>();
		for(FlowInputMessage mess: lMessages)
		{
			MessageOptions mo = new MessageOptions();
			System.debug('mess.OrchestrationInstance='+mess.OrchestrationInstance);

			mo.sType = 'Input';
			mo.sFlow = mess.sFlow;
			mo.sFieldName = mess.sFieldName;
			mo.sParamName = mess.sParamName;
			mo.flowParamsJSON = mess.flowParamsJSON;
			mo.sMessage = mess.sMessage;
			mo.visitorId = mess.visitorId;
            mo.sConfirmMessage = mess.sConfirmMessage;
            mo.sInputType = mess.type;
			mo.OrchestrationInstance = mess.OrchestrationInstance;
			if((mo.sFieldName == null ||mo.sFieldName == '') &&(mo.sParamName == null || mo.sParamName == ''))
			{
				mo.sParamName = 'abc';
			}
			lmo.add(mo);
		}
		MessageOptions.sendWF(lmo);
	}
}
