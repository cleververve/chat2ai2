/**
Author:         serhiivolynets
Date:           03.03.2021
Description:   
**/
@IsTest
public class SM089_HercTest
{
	@TestSetup
	public static void prepareData()
	{
		CVCH__Ruffle_Draw__c draw = new CVCH__Ruffle_Draw__c();
		draw.Name = 'aaaa';
		draw.CVCH__Draw_Date__c = Datetime.now();
		draw.CVCH__Winners__c = 50;
		insert draw;
		list<CVCH__Ruffle_Draw_Ticket__c> lTick = new list<CVCH__Ruffle_Draw_Ticket__c>();
		for (Integer i = 0; i < 100; i++)
		{
			CVCH__Ruffle_Draw_Ticket__c tick = new CVCH__Ruffle_Draw_Ticket__c();
			tick.CVCH__Ruffle_Draw__c = draw.Id;
			lTick.add(tick);
		}
		insert lTick;
	}

	@IsTest
	public static void testIt()
	{
		Test.startTest();
		CVCH__Ruffle_Draw_Ticket__c tick = [select id,CVCH__Short_Id__c from CVCH__Ruffle_Draw_Ticket__c limit 1];
		SM089_Herc.HercInput inp = new SM089_Herc.HercInput();
		inp.ticketNumber = tick.CVCH__Short_Id__c;
		list<SM089_Herc.HercInput>lInp = new list<SM089_Herc.HercInput>();
		lInp.add(inp);

		SM089_Herc.callHerc(lInp);
		Test.stopTest();
	}
}