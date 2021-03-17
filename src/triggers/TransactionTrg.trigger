/**
Author:         serhiivolynets
Date:           18.02.2021
Description:   
**/

trigger TransactionTrg on CVCH__Transaction__c (before insert, before update, after insert, after update)
{
//	if(Trigger.isBefore && Trigger.isInsert)
//	{
//		for(CVCH__Transaction__c tr: Trigger.new)
//		{
//			if(tr.CVCH__Receipt_URL__c != null && tr.CVCH__Receipt_URL__c != '')
//			{
//				blob dContent = SM088_File.getFileByURL(tr.Receipt_URL__c);
//
//				ContentVersion ContVerFile = new ContentVersion();
//				ContVerFile.VersionData = dContent;
//				ContVerFile.Title = 'file' + datetime.now() + '.jpg';
//				ContVerFile.ContentLocation = 's';
//				ContVerFile.PathOnClient = 'file' + datetime.now() + '.jpg';
//				insert ContVerFile;
//				tr.CVCH__File_Id__c = ContVerFile.Id;
//			}
//		}
//	}
//	if(Trigger.isAfter && Trigger.isInsert)
//	{
//		for(Transaction__c tr: Trigger.new)
//		{
//			if(tr.CVCH__File_Id__c != null && tr.CVCH__File_Id__c != '')
//			{
//				id fileId = (id)tr.CVCH__File_Id__c;
//				ContentVersion ver = [SELECT id,ContentDocumentId from ContentVersion where id = :fileId];
//				system.debug('ContentDocumentId = '+ver);
//				ContentDocumentLink link = new ContentDocumentLink();
//				link.ContentDocumentId = ver.ContentDocumentId;
//				link.LinkedEntityId = tr.Id;
//				link.ShareType = 'I';
//				link.Visibility = 'AllUsers';
//				insert link;
//			}
//		}
//	}
}
