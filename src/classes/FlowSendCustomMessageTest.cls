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

    @IsTest
    public static void send1()
    {
        TestDataFactory data = new TestDataFactory();
        FlowSendCustomMessage2 inp = new FlowSendCustomMessage2();
        inp.visitorId = data.vis.id;
        inp.async = false;
        inp.content = '{}';
        Test.startTest();
        FlowSendCustomMessage2.sendMessage(new list<FlowSendCustomMessage2>{inp});
        Test.stopTest();
    }

    @IsTest
    public static void sendMTM()
    {
        TestDataFactory data = new TestDataFactory();
        FlowSendMTM inp = new FlowSendMTM();
        inp.visitorId = data.vis.id;
        inp.async = false;
        inp.content = '{}';
        inp.locale = '';
        Test.startTest();
        FlowSendMTM.sendMessage(new list<FlowSendMTM>{inp});
        Test.stopTest();
    }

}
