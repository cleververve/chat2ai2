/**
Author:         serhiivolynets
Date:           29.07.2022
Description:   
**/

public class SM097_GoogleSheet
{

	public static map<string,string> getHeaders()
	{
		map<string,string> mHeaders = new map<string,string>{'Accept'=>'application/json','Content-Type'=>'application/json'};
		return mHeaders;
	}
	@Future(Callout = true)
	public static void initSheet()
	{
		string sSheetName = SM010_Utils.getChat2aiValue2('Google Sheet Name');
		string sURL = getBaseURL()+'/values:batchClear';
		string sRequestBody = '{ "ranges": ["'+sSheetName+'!2:10000"]}';
		SM003_Http.request(sURL,'POST',getHeaders(),sRequestBody,'Google Sheet Init',null,'DummySuccessMock');
		System.enqueueJob(new SM097_GoogleSheetJob());
	}
	public static string getBaseURL()
	{
		return 'callout:GoogleSheetAPI/v4/spreadsheets/'+SM010_Utils.getChat2aiValue2('Google Spreadsheet Id');
	}
	public static void callAppendProducts(List<Product2> lProd, List<String>lFields)
	{
		string sSheetName = SM010_Utils.getChat2aiValue2('Google Sheet Name');

		string sURL = getBaseURL()+'/values/'+sSheetName+':append?valueInputOption=RAW';
		list<object>lRecords = new list<object>();
		string sStatus = 'Done';
		string sErrorMessage = '';
		for(Product2 prod : lProd)
		{
			list<object> lVal = new List<object>();
			for(string sField : lFields)
			{
				lVal.add(prod.get(sField));
			}
			lRecords.add(lVal);
		}
		map<string,object> mBody = new map<string,object>{'majorDimension'=>'ROWS','range'=>sSheetName,'values'=>lRecords};
		try
		{
			SM003_Http.request(sURL,'POST',getHeaders(),JSON.serialize(mBody),'Google Sheet Append',null,'DummySuccessMock');

		}catch(Exception e)
		{
			sStatus = 'Error';
			sErrorMessage = e.getMessage();
		}
		SM005_Logs.save();
		list<product2>lUpdate = new list<Product2>();
		for(Product2 prod : lProd)
		{
			Product2 upd = new Product2(Id = prod.Id, Google_Sheets_Synch_Status__c = sStatus, CVCH__Google_Sheet_Sync_Error_Message__c = sErrorMessage);
			lUpdate.add(upd);
		}
		update lUpdate;
	}

}
