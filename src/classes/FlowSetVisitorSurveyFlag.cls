/**
Author:         serhiivolynets
Date:           08.07.2022
Description:   
**/

global class FlowSetVisitorSurveyFlag
{
	global class SetVisitorSurveyFlagInput
	{
		@AuraEnabled @InvocableVariable global Id visitorId;
		@AuraEnabled @InvocableVariable global Boolean flag;
	}

	@InvocableMethod(Label='set visitor survey flag' Description='set visitor survey flag')
	global static void setFlag(List <SetVisitorSurveyFlagInput> lParam)
	{
		for(SetVisitorSurveyFlagInput inp : lParam)
		{
			SM031_Nexmo.updateVisitor(new Visitor__c(Id = (Id)inp.visitorId, CVCH__Survey_Required_Flag__c = inp.flag));
		}
	}
}
