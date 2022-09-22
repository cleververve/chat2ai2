@isTest
public class DM013_Cleaner_Test
{
	testMethod static void testSubmit()
	{
		Test.startTest();
		account acc = new account(name='acc123');
		acc.BillingCountry = 'Denmark';
		insert acc;
		Database.executeBatch(new DM013_Cleaner('select id from account where name = \'acc123\''));

		Test.stopTest();
	}
}
