/**
Author:         serhiivolynets
Date:           26.03.2021
Description:   
**/
@IsTest
public class FlowSendCustomMessageTest
{
    @IsTest
    public static void send2()
    {
        TestDataFactory data = new TestDataFactory();
        FlowSendCustomMessage inp = new FlowSendCustomMessage();
        inp.visitorId = data.vis.id;
        inp.async = false;
        inp.content = '{}';
        Test.startTest();
        FlowSendCustomMessage.sendMessage(new list<FlowSendCustomMessage>{inp});
        Test.stopTest();
    }
}