/**
Author:         serhiivolynets
Date:           13.03.2021
Description:   
**/
@IsTest
public with sharing class SM090_UploadS3Test
{
	@IsTest
	public static void testIt4()
	{
		Test.startTest();
		SM090_UploadS3.S3Input inp = new SM090_UploadS3.S3Input();
		inp.sURL = 'url';
		SM090_UploadS3.UploadS3(new List<SM090_UploadS3.S3Input>{inp});
		Test.stopTest();
	}

}
