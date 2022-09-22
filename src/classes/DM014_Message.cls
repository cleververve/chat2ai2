/**
Author:         serhiivolynets
Date:           26.07.2022
Description:   
**/

public with sharing class DM014_Message
{
	public static CVCH__NexmoMessage__c getRecord(id messId)
	{
		return
		[
				SELECT Id, CVCH__Text__c, CVCH__Status__c, CVCH__FullText__c,
						CVCH__JSON__c, CVCH__Type__c,
						CVCH__From__c, CVCH__From_Name__c,
						CVCH__To__c, CVCH__To_Name__c,
						CVCH__activityId__c,
						CVCH__conversationId__c, CVCH__conversationName__c,
						CVCH__Channel__c,CVCH__Locale__c,CVCH__ChannelId__c,
						CVCH__Visitor__c

				FROM CVCH__NexmoMessage__c
				WHERE Id = :messId
		];
	}

	public static list<CVCH__NexmoMessage__c> getRecordByExtID(string extId)
	{
		return
		[
				SELECT Id, CVCH__Text__c, CVCH__Status__c, CVCH__FullText__c,
						CVCH__JSON__c, CVCH__Type__c,
						CVCH__From__c, CVCH__From_Name__c,
						CVCH__To__c, CVCH__To_Name__c,
						CVCH__activityId__c,
						CVCH__conversationId__c, CVCH__conversationName__c,
						CVCH__Channel__c,CVCH__Locale__c,CVCH__ChannelId__c,
						CVCH__Visitor__c

				FROM CVCH__NexmoMessage__c
				WHERE CVCH__ExternalId__c = :extId
		];
	}
}
