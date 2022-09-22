/**
Author:         serhiivolynets
Date:           16.02.2021
Description:   
**/

global class SM088_File
{
	global class FileInput
	{
		@AuraEnabled @InvocableVariable global string sURL;
		@AuraEnabled @InvocableVariable global id parentId;
		global blob bcontent;
	}

	global class FileOutput
	{
		@AuraEnabled @InvocableVariable global id fileId;
//		@AuraEnabled @InvocableVariable global id linkId;

	}

	@InvocableMethod(label='Save File' description='saves and shares the file in for parentId')
	global static void SaveFile(list<FileInput> lInp)
	{
		list<FileOutput> lRet = new list<FileOutput>();
		for(FileInput inp : lInp)
		{
			inp.bcontent = getFileByURL(inp.sURL);
		}
		for(FileInput inp : lInp)
		{
			FileOutput ret = new FileOutput();
			ret.fileId = saveFile2(inp.bcontent,inp.parentId);
			lRet.add(ret);
		}
//		return lRet;
	}

	global static blob getFileByURL(string sURL)
	{
		DateTime dtBeg = DateTime.now();
		string sErr = '';
		Blob content = null;
		try
		{
			Http h = new Http();
			HttpRequest req = new HttpRequest();

			req.setEndpoint(sURL);
			req.setMethod('GET');
			if(Test.isRunningTest())
			{
				content = blob.valueOf('aaaa');
			}
			else
			{
				HttpResponse res = h.send(req);
				//content= Blob.valueOf(res.getBody());
				system.debug(res.getBody());
				content = res.getBodyAsBlob();
			}

		}catch(Exception e)
		{
			sErr = e.getMessage();
			throw new MyException('The content can not be downloaded from '+sURL);
		}
		finally
		{
			SM005_Logs.LogCallOut(null,'getFileByURL', sURL, null, dtBeg, DateTime.now(),sErr);
		}
		return content;
	}

	global static void saveFile(blob bcontent, id parentId)
	{
		saveFile2( bcontent, parentId);
	}
	global static id saveFile2(blob bcontent, id parentId)
	{
		ContentVersion ContVerFile = new ContentVersion();
		ContVerFile.VersionData = bcontent;
		ContVerFile.Title = 'file' + datetime.now() + '.jpg';
		ContVerFile.ContentLocation = 's';
		ContVerFile.PathOnClient = 'file' + datetime.now() + '.jpg';
		insert ContVerFile;
		ContentVersion ver = [SELECT id,ContentDocumentId from ContentVersion where id = :ContVerFile.id];
		if(parentId != null)
		{

			system.debug('ContentDocumentId = '+ver);
			ContentDocumentLink link = new ContentDocumentLink();
			link.ContentDocumentId = ver.ContentDocumentId;
			link.LinkedEntityId = parentId;
			link.ShareType = 'I';
			link.Visibility = 'AllUsers';
			insert link;
			system.debug('ContentDocumentLink = '+link);
		}
		return ver.ContentDocumentId;
	}
}
