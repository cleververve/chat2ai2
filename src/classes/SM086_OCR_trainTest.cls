/**
Author:         serhiivolynets
Date:           08.09.2021
Description:   
**/
@IsTest
public with sharing class SM086_OCR_trainTest
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		SM086_OCR_train.OCRInputTrain inp = new SM086_OCR_train.OCRInputTrain();
		inp.vendorName = 'test';
		inp.total = 1000;
		inp.dtDate = Date.newInstance(2021,10,03);
		inp.documentID = '39341136';
		SM086_OCR_train.OCR(new list<SM086_OCR_train.OCRInputTrain>{inp});
		Test.stopTest();
	}


}
