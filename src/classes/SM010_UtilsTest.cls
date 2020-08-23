/**
 * Created by vladiasynskyi on 2019-05-07.
 */

@IsTest
private class SM010_UtilsTest {
    @IsTest
    public static void testgetPage()
    {
        list<account>lacc = new list<account>();
        for(integer i=0; i<100; i++)
        {
            lacc.add(new account(name='test'+i));
        }
        SM010_Utils.getPage(lacc,2,10,true,true);
    }

}
