/**
Author:         serhiivolynets
Date:           02.02.2021
Description:   
**/
@IsTest
global class SM086_OCRTest
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		list<SM086_OCR.OCRInput> lParam = new list<SM086_OCR.OCRInput>();
		lParam.add(new SM086_OCR.OCRInput());
		SM086_OCR.OCR(lParam);
		Test.stopTest();
	}
}