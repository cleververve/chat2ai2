/**
 * Author:         serhiivolynets
 * Date:           31.01.2021
 * Description:
 **/
@IsTest
public class RuffleDrawTests
{
	@TestSetup
	public static void prepareData()
	{
		Ruffle_Draw__c draw = new Ruffle_Draw__c();
		draw.Name = 'aaaa';
		draw.Draw_Date__c = Datetime.now();
		draw.Winners__c = 50;
		insert draw;
		list<Ruffle_Draw_Ticket__c> lTick = new list<Ruffle_Draw_Ticket__c>();
		for (Integer i = 0; i < 100; i++)
		{
			Ruffle_Draw_Ticket__c tick = new Ruffle_Draw_Ticket__c();
			tick.Ruffle_Draw__c = draw.Id;
			lTick.add(tick);
		}
		insert lTick;
	}

	@IsTest
	public static void testIt()
	{
		Test.startTest();
		ApexPages.StandardController ctr = new ApexPages.StandardController([
				select id
				from Ruffle_Draw__c
				limit 1
		]);
		SM082_RuffleDraw draw = new SM082_RuffleDraw(ctr);
		draw.onRun();
		Test.stopTest();
	}

	@IsTest
	public static void testBatch2()
	{
		Ruffle_Draw__c r = [
				select id
				from Ruffle_Draw__c
				limit 1
		];
		Test.startTest();
		Database.executeBatch(new SM082_RaffleDrawBatch(r.Id));
		Test.stopTest();
	}


	@IsTest
	public static void testIt2()
	{
		Test.startTest();
		System.schedule('job1', '0 0 10 * * ?', new SM085_ruffleDrawBatch());
		Test.stopTest();
	}

	@IsTest
	public static void testIt3()
	{

		TestDataFactory data1 = new TestDataFactory();
		SM084_RuffleDrawTicket.TicketInput mess = new SM084_RuffleDrawTicket.TicketInput();
		mess.visitorId = data1.vis.id;
		mess.ticketDate = Date.today();
		Test.startTest();
		SM084_RuffleDrawTicket.getTicket(new list<SM084_RuffleDrawTicket.TicketInput>
		{
				mess
		}
		);
		Test.stopTest();
	}

	@IsTest
	public static void testIt4()
	{
		Test.startTest();
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueof('{"raffleDrawName":"aaaa"}"');
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/raffleDraw/';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		SM087_runDraw.runIt();
		Test.stopTest();
	}
}