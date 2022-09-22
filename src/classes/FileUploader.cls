/**
Author:         serhiivolynets
Date:           28.08.2022
Description:   
**/

public with sharing class FileUploader
{
	/*
	  * @method uploadFile()
	  * @desc Creates a content version from a given file's base64 and name
	  *
	  * @param {String} base64 - base64 string that represents the file
	  * @param {String} filename - full file name with extension, i.e. 'products.csv'
	  * @param {String} recordId - Id of the record you want to attach this file to
	  *
	  * @return {ContentVersion} - returns the created ContentDocumentLink Id if the
	  *   upload was successful, otherwise returns null
	  */
	@AuraEnabled
	public static String uploadFile(String base64, String filename, String filetype)
	{
		system.debug('uploadFile.start');
		String sURL = uploadS3(base64,filename,filetype);
		system.debug('uploadFile.ret');
		system.debug(sURL);
		return sURL;
	}

	/*
	 * @method createContentVersion() [private]
	 * @desc Creates a content version from a given file's base64 and name
	 *
	 * @param {String} base64 - base64 string that represents the file
	 * @param {String} filename - full file name with extension, i.e. 'products.csv'
	 *
	 * @return {ContentVersion} - returns the newly created ContentVersion, or null
	 *   if there was an error inserting the record
	 */
//	private static ContentVersion createContentVersion(String base64, String filename) {
//		ContentVersion cv = new ContentVersion();
//		cv.VersionData = EncodingUtil.base64Decode(base64);
//		cv.Title = filename;
//		cv.PathOnClient = filename;
//		try {
//			insert cv;
//			return cv;
//		} catch(DmlException e) {
//			System.debug(e);
//			return null;
//		}
//	}

	/*
	* @method createContentLink() [private]
	* @desc Creates a content link for a given ContentVersion and record
	*
	* @param {String} contentVersionId - Id of the ContentVersion of the file
	* @param {String} recordId - Id of the record you want to attach this file to
	*
	* @return {ContentDocumentLink} - returns the newly created ContentDocumentLink,
	*   or null if there was an error inserting the record
	*/
//	private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
//		if (contentVersionId == null || recordId == null) { return null; }
//		ContentDocumentLink cdl = new ContentDocumentLink();
//		cdl.ContentDocumentId = [
//				SELECT ContentDocumentId
//				FROM ContentVersion
//				WHERE Id =: contentVersionId
//		].ContentDocumentId;
//		cdl.LinkedEntityId = recordId;
//		// ShareType is either 'V', 'C', or 'I'
//		// V = Viewer, C = Collaborator, I = Inferred
//		cdl.ShareType = 'V';
//		try {
//			insert cdl;
//			return cdl;
//		} catch(DmlException e) {
//			System.debug(e);
//			return null;
//		}
//	}
	public static String uploadS3(String base64, String filename, String filetype)
	{
		String sRet;
		System.debug('uploadS3.start');
		HttpResponse resp = CVCH.SM003_Http.request('http://barcode-env.x49y4mrjpq.eu-central-1.elasticbeanstalk.com/uploadbase64', 'POST', SM090_UploadS3.getHeaders(), getBody(base64, filename, filetype), 'S3UploadBase64', null, 'SM090_UploadS3Mock');
		Map<String, Object> mResp = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
		String sError = (String) mResp.get('Error');
		if (sError != '' && sError != null)
		{
			System.debug('uploadS3.error:'+ sError);
			sRet = 'Error during the upload to S3: ' + sError;
		}
		else
		{
			sRet = SM010_Utils.getChat2aiValue('S3URL') + (String) mResp.get('URL');
		}

		return sRet;
	}

	public static String getBody(String base64, String filename, String filetype)
	{
		string sFolderName = SM010_Utils.getChat2aiValue2('S3 Folder Name');
		if(sFolderName == '')
			sFolderName = 'GV';
		String ext = null;
		if (filename.contains('.'))
		{
			ext = filename.substring(filename.lastIndexOf('.') + 1, filename.length());
		}
		Map<String, Object> mRet = new Map<String, Object>();
		mRet.put('ext', ext);
		mRet.put('filetype', filetype);
		mRet.put('base64', base64);
		mRet.put('folder', 'GV');
		return JSON.serialize(mRet);
	}
}
