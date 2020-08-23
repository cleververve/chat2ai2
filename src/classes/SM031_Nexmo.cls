@RestResource(urlMapping='/nexmo/*')
global class SM031_Nexmo
{
	public static list<MessageOptions> getResponse(NexmoMessage__c mess, Visitor__c visr)
	{
		list<MessageOptions> lret = new list<MessageOptions>();
		boolean bProceeded = false;
		boolean TriggerDefaultFlow = false;
		string translatedText = '';
		translatedText = SM080_Translate.translate(mess.Text__c);
		system.debug('Translated input: ' + translatedText);
		SM080_LUIS.LuisResponse respLuis = SM080_LUIS.queryPhrase(translatedText, visr.language__c);
		SM080_QnA.QnAResponse respQnA = SM080_QnA.queryPhrase(translatedText, visr.language__c);

		if (respLuis.dScore < Decimal.valueOf(SM010_Utils.getValue('Response treshold score')) && respQnA.dScore < Decimal.valueOf(SM010_Utils.getValue('Response treshold score')))
		{
			TriggerDefaultFlow = true; // We will trigger Default Flow, if both scores are below set treshold
		}
		if (visr.Had_First_Interaction__c == false)
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();

			params.put('visphone', visr.Id__c);
			params.put('ChatNumber', visr.Chat_Number__c);
			params.put('channel', visr.chanel__c);
			Flow.Interview chat2aiflow = Flow.Interview.createInterview('Welcome_Flow', params);
			chat2aiflow.Start();
		}
		else if (visr.GDPR_Consent__c == 'No Access' && (visr.Context__c == '' || visr.Context__c == null)) //Restrict Non-GDPR users
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.Text__c);

			Flow.Interview flow = Flow.Interview.createInterview('GDPR_CHECK', params);
			flow.start();
		}
		else if (visr.GDPR_Consent__c == 'No Access' && visr.Context__c != '' && visr.Context__c != null)
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.Text__c);

			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
			system.debug('GDPR MessageOptions=' + mo);
			Option opt = mo.mOptions.get(mess.Text__c);
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
				Flow.Interview flow = Flow.Interview.createInterview('GDPR_CHECK', params);
				flow.start();
			}
		}
		else if (!TriggerDefaultFlow && respLuis.dScore > respQnA.dScore && respLuis.sIntent == 'exit')
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.Text__c);
			Flow.Interview flow = Flow.Interview.createInterview('Main_Menu', params);
			flow.start();
			Visitor__c v = new Visitor__c(Id = visr.id, Next_flow__c = null);
			update v;
		}
		else if (visr.Next_Flow__c != null && visr.Next_Flow__c != '')
		{
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('input', mess.Text__c);

			Flow.Interview flow = Flow.Interview.createInterview(visr.Next_Flow__c, params);
			flow.start();
		}
		else if (visr.Context__c != null && visr.Context__c != '')
		{
			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
			system.debug('MessageOptions=' + mo);
			if (mo.sType == 'Input')
			{
				bProceeded = true;
				Visitor__c v = new Visitor__c(Id = visr.id);
				v.put(mo.sFieldName, mess.Text__c);
				v.Context__c = '';
				update v;
				if (mo.sConfirmMessage != null && mo.sConfirmMessage != '')
				{
					// sendText(visr.id__c,visr.Chat_Number__c,mo.sConfirmMessage);
				}
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
				system.debug('getting option ' + mess.Text__c + ' from ' + mo.mOptions);
				Option opt = mo.mOptions.get(mess.Text__c);
				if (opt != null)
				{
					system.debug('found option ' + opt);
					if (opt.sType == 'QnA')
					{
						integer qnaid = integer.valueOf(opt.sValue);

						SM080_QnA.QnAResponse respQnA2 = SM080_QnA.getQNA(qnaid, visr.language__c);
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
							params.put('originalmessage', mess.Text__c);
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
			params.put('originalmessage', mess.Text__c);

			Flow.Interview flow = Flow.Interview.createInterview('Default_Flow', params);
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
				params.put('originalmessage', mess.Text__c);
				Flow.Interview chat2aiflow = Flow.Interview.createInterview('LUIS', params);
				chat2aiflow.Start();
			}
			else
					lret.add(new MessageOptions(respQnA));

		}
		return lret;
	}

	global static NexmoMessage__c parse(string jsonbody)
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
		NexmoMessage__c mess = new NexmoMessage__c();
		mess.Name = message_uuid;
		mess.From__c = sFrom;
		mess.To__c = sTo;
		mess.Text__c = messageText;
		mess.Channel__c = sChannel;

		System.debug('parse.return ' + mess);
		return mess;
	}

	public static Visitor__c getVisitor(string sid, string sChatNumber, string channel)
	{
		Visitor__c ret;
		list<Visitor__c> lVisitors = DM080_Visitor.getRecordsbyNumber(sid);

		if (!lVisitors.isEmpty())
			ret = lVisitors[0];
		else
			ret = new Visitor__c(Id__c = sid, Context__c = null, Chat_Number__c = sChatNumber, Chanel__c = channel);
		return ret;
	}

	@HttpPost
	global static list<NexmoMessage__c> getMessage()
	{
		return getMessage0(RestContext.request.requestBody.toString());
	}

	global static list<NexmoMessage__c> getMessage0(string jsonbody)
	{
		Visitor__c visr;
		datetime dtBeg = datetime.now();
		string errMsg = '';
		NexmoMessage__c mess0 = new NexmoMessage__c();
		list<NexmoMessage__c>lMess = new list<NexmoMessage__c>();
		try
		{
			mess0 = parse(jsonbody);
			if (mess0 == null)
				return lMess;
			visr = getVisitor(mess0.From__c, mess0.To__c, mess0.Channel__c);

			mess0.Received__c = dtBeg;
			list<MessageOptions> aRetStr = getResponse(mess0, visr);
			system.debug(aRetStr);
			if (aRetStr != null)
			{

				mess0.Response2__c = String.join(aRetStr, '\t');
				if (mess0.Response2__c != null && mess0.Response2__c.length() > 32000)
					mess0.Response2__c = mess0.Response2__c.substring(0, 32000);
				string sPrevContext = visr.Context__c;
				for (MessageOptions opt : aRetStr)
				{
					opt.send(visr);
				}
				if (sPrevContext != visr.Context__c)
				{
					Visitor__c v = new Visitor__c(Id = visr.Id, Context__c = visr.Context__c);
					update v;
				}
				lMess.add(mess0);
			}

		}
		catch (MyException e)
		{
			errMsg = e.getMessage();
			if (mess0 != null && mess0.From__c != null)
			{
				SM042_NexmoOut2.sendText(mess0.From__c, errMsg, mess0.To__c);
			}
			if (Test.isRunningTest())
				throw e;
		}
		catch (Exception e)
		{
			errMsg = '' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString();
			if (mess0 != null && mess0.From__c != null)
				SM042_NexmoOut2.sendText(mess0.From__c, errMsg, mess0.To__c);
			if (Test.isRunningTest())
				throw e;
		}
		finally
		{
			if (mess0 != null)
			{
				SM005_Logs.LogCallOut('', 'Nexmo', jsonbody, JSON.serialize(lMess), dtBeg, Datetime.now(), errMsg);
				SM005_Logs.save();
				SM010_Utils.saveTran();
				if (mess0 != null)
				{
					mess0.Responded__c = Datetime.now();
					mess0.Duration__c = mess0.Responded__c.getTime() - mess0.Received__c.getTime();
				}
				if (lMess != null)
					insert lMess;
			}
		}
		return lMess;
	}
}
