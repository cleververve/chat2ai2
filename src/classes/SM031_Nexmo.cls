@RestResource(urlMapping='/nexmo/*')
global class SM031_Nexmo
{

	@HttpPost
	global static list<CVCH__NexmoMessage__c> getMessage()
	{
		return getMessage0(RestContext.request.requestBody.toString());
	}

	@HttpGet
	global static String testIt()
	{
		SM005_Logs.LogCallOut('', 'NexmoGet',RestContext.request.requestBody.toString(),'hello', Datetime.now(), Datetime.now(), '');
		SM005_Logs.save();

		return 'hello';

	}

	public static list<MessageOptions> getResponse(CVCH__NexmoMessage__c mess, CVCH__Visitor__c visr)
	{

		list<MessageOptions> lret = new list<MessageOptions>();
		boolean bProceeded = false;
		boolean TriggerDefaultFlow = false;
		string translatedText = '';
		translatedText = SM080_Translate.translate(mess.CVCH__Text__c);
		system.debug('Translated input: ' + translatedText);
		SM080_LUIS.LuisResponse respLuis = SM080_LUIS.queryPhrase(translatedText, visr.CVCH__language__c);
		SM080_QnA.QnAResponse respQnA = SM080_QnA.queryPhrase(translatedText, visr.CVCH__language__c);

		if (respLuis.dScore < Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')) && respQnA.dScore < Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')))
		{
			TriggerDefaultFlow = true; // We will trigger Default Flow, if both scores are below set treshold
		}
		if (visr.CVCH__Had_First_Interaction__c == false)
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();

			params.put('visphone', visr.CVCH__Id__c);
			params.put('ChatNumber', visr.CVCH__Chat_Number__c);
			params.put('channel', visr.CVCH__chanel__c);
			if (SM010_Utils.getChat2aiValue('Welcome Flow') != null && SM010_Utils.getChat2aiValue('Welcome Flow') != '')
				 Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Welcome Flow'), params).Start();
		}
		else if (visr.CVCH__GDPR_Consent__c == 'No Access' && (visr.CVCH__Context__c == '' || visr.CVCH__Context__c == null)) //Restrict Non-GDPR users
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.CVCH__Text__c);

			Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('GDPR Flow'), params);
			flow.start();
		}
		else if (visr.CVCH__GDPR_Consent__c == 'No Access' && visr.CVCH__Context__c != '' && visr.CVCH__Context__c != null)
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.CVCH__Text__c);

			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.CVCH__Context__c, MessageOptions.class);
			system.debug('GDPR MessageOptions=' + mo);
			Option opt = mo.mOptions.get(mess.CVCH__Text__c);
			if (opt != null && opt.sFlow != null)
			{
				if (opt.sName != null)
					params.put(opt.sName, opt.sValue);
				if (opt.sName2 != null)
					params.put(opt.sName2, opt.sValue2);
				if (opt.sName3 != null)
					params.put(opt.sName3, opt.sValue3);
				Flow.Interview flow = Flow.Interview.createInterview(opt.sFlow, params);
				flow.start();
			}
			else
			{
				Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('GDPR Flow'), params);
				flow.start();
			}
		}
		else if (!TriggerDefaultFlow && respLuis.dScore > respQnA.dScore && respLuis.sIntent == 'exit')
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.CVCH__Text__c);
			Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Main Menu Flow'), params);
			flow.start();
			CVCH__Visitor__c v = new CVCH__Visitor__c(Id = visr.id, CVCH__Next_flow__c = null);
			update v;
		}
		else if (visr.CVCH__Next_Flow__c != null && visr.CVCH__Next_Flow__c != '')
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('input', mess.CVCH__Text__c);

			Flow.Interview flow = Flow.Interview.createInterview(visr.CVCH__Next_Flow__c, params);
			flow.start();
		}
		else if (visr.CVCH__Context__c != null && visr.CVCH__Context__c != '')
		{
			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.CVCH__Context__c, MessageOptions.class);
			system.debug('MessageOptions=' + mo);
			if (mo.sType == 'Input')
			{
				bProceeded = true;
				CVCH__Visitor__c v = new CVCH__Visitor__c(Id = visr.id);
				v.put(mo.sFieldName, mess.CVCH__Text__c);
				v.CVCH__Context__c = '';
				update v;
				if (mo.sFlow != null && mo.sFlow != '')
				{
					Map<String, Object> params = new Map<String, Object>();
					params.put('visitorId', visr.id);

					Flow.Interview flow = Flow.Interview.createInterview(mo.sFlow, params);
					flow.start();
				}
			}
			else
			{
				system.debug('getting option ' + mess.CVCH__Text__c + ' from ' + mo.mOptions);
				Option opt = mo.mOptions.get(mess.CVCH__Text__c);
				if (opt != null)
				{
					system.debug('found option ' + opt);
					if (opt.sType == 'QnA')
					{
						integer qnaid = integer.valueOf(opt.sValue);

						SM080_QnA.QnAResponse respQnA2 = SM080_QnA.getQNA(qnaid, visr.CVCH__language__c);
						lret.add(new MessageOptions(respQnA2));
						bProceeded = true;
					}
					else
					{
						bProceeded = true;
						if (opt.sFlow != null)
						{
							Map<String, Object> params = new Map<String, Object>();
							params.put('visitorId', visr.id);
							params.put('originalmessage', mess.CVCH__Text__c);
							if (opt.sName != null)
								params.put(opt.sName, opt.sValue);
							if (opt.sName2 != null)
								params.put(opt.sName2, opt.sValue2);
							if (opt.sName3 != null)
								params.put(opt.sName3, opt.sValue3);
							Flow.Interview flow = Flow.Interview.createInterview(opt.sFlow, params);
							flow.start();
						}
					}
				}
			}

		}
		if (!bProceeded && TriggerDefaultFlow)
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.CVCH__Text__c);

			Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Default Flow'), params);
			flow.start();// trigger default flow
		}
		if (!bProceeded)
		{
			system.debug('LUIS score=' + respLuis.dScore + ',QnA score=' + respQnA.dScore);
			if (respLuis.dScore > respQnA.dScore)
			{
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.id);
				params.put('intent', respLuis.sIntent);
				params.put('entities', respLuis.getEntities());
				params.put('originalmessage', mess.CVCH__Text__c);
				Flow.Interview chat2aiflow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Chat2ai Flow'), params);
				chat2aiflow.Start();
			}
			else
					lret.add(new MessageOptions(respQnA));
		}
		return lret;
	}

	global static CVCH__NexmoMessage__c parse(string jsonbody)
	{
		system.debug('parse.start ' + jsonbody);
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonbody);
		system.debug(m);
		string message_uuid = (string) m.get('message_uuid');
		map<string, object> mFrom = (map<string, object>) m.get('from');
		string sFrom = SM010_Utils.phone((string) mFrom.get('number'));
		string sChannel = (string) mFrom.get('type');
		map<string, object> mTo = (map<string, object>) m.get('to');
		string sTo = (string) mTo.get('number');
		map<string, object> mMess = (map<string, object>) m.get('message');
		map<string, object> mCon;
		try
		{
			mCon = (map<string, object>) mMess.get('content');
		}
		catch (Exception e)
		{
			return null;
		}

		string messageText = (string) mcon.get('text');
		CVCH__NexmoMessage__c mess = new CVCH__NexmoMessage__c();
		mess.Name = message_uuid;
		mess.CVCH__From__c = sFrom;
		mess.CVCH__To__c = sTo;
		mess.CVCH__Text__c = messageText;
		mess.CVCH__Channel__c = sChannel;
		list<CVCH__NexmoMessage__c> lold = [select id from CVCH__NexmoMessage__c where Name = :mess.name];
		if(!lold.isEmpty())
			return null;
		System.debug('parse.return ' + mess);
		return mess;
	}

	public static CVCH__Visitor__c getVisitor(string sid, string sChatNumber, string channel)
	{
		CVCH__Visitor__c ret;
		list<CVCH__Visitor__c> lVisitors = DM080_Visitor.getRecordsbyNumber(sid);

		if (!lVisitors.isEmpty())
			ret = lVisitors[0];
		else
				ret = new CVCH__Visitor__c(CVCH__Id__c = sid, CVCH__Context__c = null, CVCH__Chat_Number__c = sChatNumber, CVCH__Chanel__c = channel);
		return ret;
	}


	global static list<CVCH__NexmoMessage__c> getMessage0(string jsonbody)
	{
		CVCH__Visitor__c visr;
		datetime dtBeg = datetime.now();
		string errMsg = '';
		CVCH__NexmoMessage__c mess0 = new CVCH__NexmoMessage__c();
		list<CVCH__NexmoMessage__c>lMess = new list<CVCH__NexmoMessage__c>();
		try
		{
			mess0 = parse(jsonbody);
			if (mess0 == null)
				return lMess;
			lMess.add(mess0);
			visr = getVisitor(mess0.CVCH__From__c, mess0.CVCH__To__c, mess0.CVCH__Channel__c);

			mess0.CVCH__Received__c = dtBeg;

			list<MessageOptions> aRetStr = getResponse(mess0, visr);
			system.debug(aRetStr);
			if (aRetStr != null)
			{

				mess0.CVCH__Response2__c = String.join(aRetStr, '\t');
				if (mess0.CVCH__Response2__c != null && mess0.CVCH__Response2__c.length() > 32000)
					mess0.CVCH__Response2__c = mess0.CVCH__Response2__c.substring(0, 32000);
				string sPrevContext = visr.CVCH__Context__c;
				for (MessageOptions opt : aRetStr)
				{
					opt.send(visr);
				}
				if (sPrevContext != visr.CVCH__Context__c)
				{
					CVCH__Visitor__c v = new CVCH__Visitor__c(Id = visr.Id, CVCH__Context__c = visr.CVCH__Context__c);
					update v;
				}
//				lMess.add(mess0);
			}
		}
		catch (MyException e)
		{
			errMsg = e.getMessage();
			if (mess0 != null && mess0.CVCH__From__c != null)
			{
				SM042_NexmoOut2.sendText(mess0.CVCH__From__c, errMsg, mess0.CVCH__To__c);
			}
			if (Test.isRunningTest())
				throw e;
		}
		catch (Exception e)
		{
			errMsg = '' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString();
			if (mess0 != null && mess0.CVCH__From__c != null)
				SM042_NexmoOut2.sendText(mess0.CVCH__From__c, errMsg, mess0.CVCH__To__c);
			if (Test.isRunningTest())
				throw e;
		}
		finally
		{
//			if (mess0 != null)
//			{
			try
			{
				SM005_Logs.LogCallOut('', 'Nexmo', jsonbody, JSON.serialize(lMess), dtBeg, Datetime.now(), errMsg);
				SM005_Logs.save();
				SM010_Utils.saveTran();
				if (mess0 != null)
				{
					mess0.CVCH__Responded__c = Datetime.now();
					mess0.CVCH__Duration__c = mess0.CVCH__Responded__c.getTime() - mess0.CVCH__Received__c.getTime();
				}
				if (lMess != null)
					insert lMess;
			}catch(Exception e)
			{

			}

//			}
		}
		return lMess;
	}
}
