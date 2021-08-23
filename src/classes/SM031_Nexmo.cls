@RestResource(urlMapping='/nexmo/*')
global class SM031_Nexmo
{

	global static decimal scoreLUIS = 0;
	global static decimal scoreQnA = 0;
	global static string intentLUIS = '';
	global static string triggeredFlow = '';
	global static SM080_LUIS.LuisResponse respLuis = null;
	global static boolean triggeredLUIS = false;

	@HttpPost
	global static list<CVCH__NexmoMessage__c> getMessage()
	{
//		if(SM010_Utils.getChat2aiValue2('PROCEED ASYNC')=='TRUE' || Test.isRunningTest())
//			proceedAsync (RestContext.request.requestBody.toString());
//		else
		getMessage0 (RestContext.request.requestBody.toString());
		return new list<CVCH__NexmoMessage__c>();
	}


	@HttpGet
	global static String testIt()
	{
		SM005_Logs.LogCallOut('', 'NexmoGet', RestContext.request.requestBody.toString(), 'hello', Datetime.now(), Datetime.now(), '');
		SM005_Logs.save();
		return 'hello';
	}

	public static list<MessageOptions> getResponse(CVCH__NexmoMessage__c mess, CVCH__Visitor__c visr)
	{
		list<MessageOptions> lret = new list<MessageOptions>();
		boolean bProceeded = false;
		boolean TriggerDefaultFlow = false;
		string translatedText = '';
		MTranslation tran = new MTranslation();
		tran.detectedlang = 'en';
		boolean TriggerDefaultFlowChangeLang = false;
		boolean flowinput = false;

		if (visr.CVCH__Context__c != null && visr.CVCH__Context__c != '')
		{ //if we received input, dont have to translate it
			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
			if (mo.sType == 'Input')
			{
				if (mo.sInputType == 'Name' || mo.sInputType == 'Email')
				{
					flowinput = true;
				}
			}
		}

		SM080_QnA.QnAResponse respQnA  = new SM080_QnA.QnAResponse();
		respQnA.dScore = 0;
		if (mess.CVCH__InputType__c == 'button')
		{
			respLuis = new SM080_LUIS.LuisResponse();
			respLuis.sIntent = mess.Text__c;
			respLuis.dScore = 100;
			respQnA = new SM080_QnA.QnAResponse();
			respQnA.dScore = 0;
			mess.CVCH__Text__c = mess.CVCH__ImageURL__c;
		}
		else if (mess.Text__c != null)
		{
			if (visr.language__c != 'en' && !flowinput)
			{
				tran = SM080_Translate.translate0(mess.Text__c);
				translatedText = tran.translation;
			}
			else
			{
				translatedText = mess.Text__c;
			}

			//system.debug('Translated input: ' + translatedText);
			respLuis = SM080_LUIS.queryPhrase(translatedText, visr.CVCH__language__c);
			if (visr.CVCH__GDPR_Consent__c != 'No Access')
			{
				respQnA = SM080_QnA.queryPhrase(translatedText, visr.CVCH__language__c);
				scoreQnA = respQnA.dScore;
			}
			scoreLUIS = respLuis.dScore;

			intentLUIS = respLuis.sIntent;

			if (respLuis.dScore < Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')) && respQnA.dScore < Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')))
			{
				if (tran.detectedlang != visr.language__c)
					TriggerDefaultFlowChangeLang = true; // We will trigger Default Flow 2, if both scores are below set treshold and if user typed in different language
				else if (visr.language__c == 'en')
				{
					tran = SM080_Translate.translate0(mess.Text__c);
					if (tran.detectedlang != 'en')
						TriggerDefaultFlowChangeLang = true; // We will trigger Default Flow 2, if both scores are below set treshold and if user typed in different language
					else
							TriggerDefaultFlow = true; // We will trigger Default Flow, if both scores are below set treshold and if user typed in same language
				}
				else
						TriggerDefaultFlow = true; // We will trigger Default Flow, if both scores are below set treshold and if user typed in same language
			}
		}
		else
		{
			respLuis = new SM080_LUIS.LuisResponse();
			respLuis.sIntent = 'Image';
			respLuis.dScore = 100;
			respQnA = new SM080_QnA.QnAResponse();
			respQnA.dScore = 0;
			mess.CVCH__Text__c = mess.CVCH__ImageURL__c;
		}
		system.debug('mess=');
		system.debug(mess);
		if (visr.CVCH__Had_First_Interaction__c == false)
		{
			system.debug('CVCH__Had_First_Interaction__c=false');
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();

			params.put('visphone', visr.CVCH__Id__c);
			params.put('ChatNumber', visr.CVCH__Chat_Number__c);
			params.put('channel', visr.CVCH__chanel__c);

			if (visr.id == null && (Test.isRunningTest() || SM010_Utils.getChat2aiValue2('CREATE VISITOR BEFORE FLOWS') == 'TRUE'))
				insert visr;
			if (SM010_Utils.getChat2aiValue2('CREATE VISITOR BEFORE FLOWS') == 'TRUE')
				params.put('visitorId', visr.id);
			system.debug('visitor=' + visr);

			if (SM010_Utils.getChat2aiValue('Welcome Flow') != null && SM010_Utils.getChat2aiValue('Welcome Flow') != '')
				Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Welcome Flow'), params).Start();
			triggeredFlow = 'Welcome Flow';
		}
		else if (apexGDPR() && visr.CVCH__GDPR_Consent__c == 'No Access' && (visr.CVCH__Context__c == '' || visr.CVCH__Context__c == null)) //Restrict Non-GDPR users
		{
			system.debug('No Access');
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.CVCH__Text__c);

			Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('GDPR Flow'), params);
			flow.start();
		}
		else if (apexGDPR() && visr.CVCH__GDPR_Consent__c == 'No Access' && visr.CVCH__Context__c != '' && visr.CVCH__Context__c != null)
		{
			system.debug('start flow: GDPR Flow');
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.CVCH__Text__c);

			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.CVCH__Context__c, MessageOptions.class);
			system.debug('GDPR MessageOptions=' + mo);
			Option opt = mo.mOptions.get(mess.CVCH__Text__c);
			if (opt == null)
			{
				opt = SM010_Utils.getOption(mo.mOptions, mess.CVCH__Text__c); // if input wasnt valid number of option - try to get it with label
			}
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
			triggeredFlow = 'GDPR Flow';
		}
		else if (!TriggerDefaultFlow && !TriggerDefaultFlowChangeLang && respLuis.dScore > respQnA.dScore && respLuis.sIntent == 'exit')
		{
			system.debug('start flow: Main Menu Flow');
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.CVCH__Text__c);
			Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Main Menu Flow'), params);
			flow.start();
			CVCH__Visitor__c v = new CVCH__Visitor__c(Id = visr.id, CVCH__Next_flow__c = null);
			if (visr.Current_Flow__c != null && visr.Current_Flow__c != '')
			{
				EventBus.publish(new User_Input__e(Input__c = mess.Text__c, Exit_Flow__c = true, VisitorId__c = visr.id));
				v.Current_Flow__c = null;
			}
			update v;
			triggeredFlow = 'Main Menu Flow';
		}
		else if (visr.Current_Flow__c != null && visr.Current_Flow__c != '')
		{
			system.debug('FIRE USER INPUT EVENT');
			bProceeded = true;
			Map<string, object> mEntities = new map<string, object>();
			string visEmail = '';
			string visName = '';
			if (respLuis.getentities() != null && respLuis.getentities() != '')
			{
				mEntities = (Map<string, object>) JSON.deserializeUntyped(respLuis.getentities());
				if (mEntities.get('email') != null)
					visEmail = String.valueOf(mEntities.get('email'));
				if (mEntities.get('personName') != null)
					visName = String.valueOf(mEntities.get('personName'));
			}
			EventBus.publish(new User_Input__e(Input__c = mess.Text__c, Exit_Flow__c = false, VisitorId__c = visr.id, Filtered_Email__c = visEmail, Filtered_Name__c = visName));
			triggeredFlow = visr.Current_Flow__c;
		}
		else if (visr.CVCH__Next_Flow__c != null && visr.CVCH__Next_Flow__c != '')
		{
			system.debug('start flow: CVCH__Next_Flow__c');
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('input', mess.CVCH__Text__c);

			Flow.Interview flow = Flow.Interview.createInterview(visr.CVCH__Next_Flow__c, params);
			flow.start();
			triggeredFlow = visr.Next_Flow__c;
		}
		else if (visr.CVCH__Context__c != null && visr.CVCH__Context__c != '')
		{
			system.debug('start flow: CVCH__Context__c');
			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
			system.debug('MessageOptions=' + mo);
			if (mo.sType == 'Input')
			{
				bProceeded = true;
				Map<string, object> mEntities = new map<string, object>();
				if (respLuis.getentities() != null && respLuis.getentities() != '')
				{
					mEntities = (Map<string, object>) JSON.deserializeUntyped(respLuis.getentities());
				}
				//input type check
				if (mo.sInputType == 'Email')
				{
					if (mEntities.get('email') != null)
						mess.Text__c = String.valueOf(mEntities.get('email'));
					else
					{
						Map<String, Object> params = new Map<String, Object>();
						params.put('visitorId', visr.id);
						params.put('type', 'Email');
						Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Input Validation Error Flow'), params);
						flow.start();
						return lret;
					}
				}
				if (mo.sInputType == 'Name')
				{
					if (mEntities.get('personName') != null)
					{
						mess.Text__c = String.valueOf(mEntities.get('personName'));
					}
					else
					{
						Map<String, Object> params = new Map<String, Object>();
						params.put('visitorId', visr.id);
						params.put('type', 'Name');
						Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Input Validation Error Flow'), params);
						flow.start();
						return lret;
					}
				}

				Visitor__c v = new Visitor__c(Id = visr.id);

				Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
				//System.debug('schemaMap = ' + schemaMap);
				Schema.SObjectType leadSchema = schemaMap.get('CVCH__Visitor__c');
				//System.debug('leadSchema = ' + leadSchema);
				Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

				try
				{
					if (fieldMap.get(mo.sFieldName).getDescribe().getType() == Schema.DisplayType.DATE)
					{
						Pattern pat = Pattern.compile('^\\d{1,2}\\/\\d{1,2}\\/\\d{4}$');
						if (!pat.matcher(mess.Text__c).matches())
						{
							string dateEx = SM010_Utils.getChat2aiValue2('INVALID_DATE');
							if (dateEx == '')
								dateEx = 'Invalid date format. Please provide dd/MM/yyyy';
							throw new MyException(dateEx);
						}
						v.put(mo.sFieldName, Date.parse(mess.Text__c));
					}
					else
							v.put(mo.sFieldName, mess.Text__c);
				}
				catch (MyException ex)
				{
					throw ex;
				}
				catch (Exception e)
				{
					v.put(mo.sFieldName, mess.Text__c);
				}

				v.Context__c = '';
				update v;
				if (mo.sFlow != null && mo.sFlow != '')
				{
					Map<String, Object> params = new Map<String, Object>();
					params.put('visitorId', visr.id);

					Flow.Interview flow = Flow.Interview.createInterview(mo.sFlow, params);
					flow.start();
					triggeredFlow = mo.sFlow;
				}
			}
			else
			{
				system.debug('getting option ' + mess.CVCH__Text__c + ' from ' + mo.mOptions);
				Option opt = mo.mOptions.get(mess.CVCH__Text__c);
				if (opt == null)
				{
					opt = SM010_Utils.getOption(mo.mOptions, mess.CVCH__Text__c); // if input wasnt valid number of option - try to get it with label
				}
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
							triggeredFlow = opt.sFlow;
						}
					}
				}
			}

		}
		if (!bProceeded && TriggerDefaultFlowChangeLang)
		{
			system.debug('start flow: Default Flow 2');
			//if (respLuis.dScore < Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')) || (respLuis.dScore >= Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')) && !(respLuis.sIntent == 'directions' || respLuis.sIntent == 'category search' || respLuis.sIntent == 'outlet search' || respLuis.sIntent == 'special opening hours' || respLuis.sIntent == 'opt out' || respLuis.sIntent == 'ikea'))) {
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.Text__c);
			params.put('language', tran.detectedlang);
			params.put('visitorlanguage', visr.language__c);
			Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Default Flow 2'), params);
			flow.start();// trigger default flow 2
			triggeredFlow = 'Default Flow 2';
//}

		}
		if (!bProceeded && TriggerDefaultFlow)
		{
			system.debug('start flow: Default Flow');
			bProceeded = true;
			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', visr.id);
			params.put('originalmessage', mess.Text__c);
			Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Default Flow'), params);
			flow.start();// trigger default flow
			triggeredFlow = 'Default Flow';
//VF-438
/*if (visr.language__c == 'en')
{
    tran = SM080_Translate.translate0(mess.Text__c);
    if (visr.language__c != tran.detectedlang)
    {
        params.put('language',tran.detectedlang);
        params.put('visitorlanguage',visr.language__c);
        Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Default Flow 2'), params);
        flow.start();// trigger default flow 2
        triggeredFlow = 'Default Flow 2';
    }
    else
    {
        Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Default Flow'), params);
        flow.start();// trigger default flow
        triggeredFlow = 'Default Flow';
    }
}
else
{
    Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Default Flow'), params);
    flow.start();// trigger default flow
    triggeredFlow = 'Default Flow';
}
*/
		}
		if (!bProceeded)
		{
			system.debug('start flow: Chat2ai Flow');
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
				triggeredFlow = intentLUIS;
				triggeredLUIS = true;
			}
			else
					lret.add(new MessageOptions(respQnA));
		}
		return lret;
	}

	public static boolean apexGDPR()
	{
		boolean bRet = false;
		Chat2ai__c val = Chat2ai__c.getInstance('ApexGDPR');
		if (val != null)
		{
			bRet = (val.Value__c == 'TRUE');
		}
		if (Test.isRunningTest())
			bRet = true;
		return bRet;
	}
	global static CVCH__NexmoMessage__c getAzureMessage(Map<String, Object> m)
	{
		CVCH__NexmoMessage__c mess = new CVCH__NexmoMessage__c();
		mess.name = (string) m.get('id');
		mess.CVCH__Text__c = (string) m.get('text');
		if (mess.CVCH__Text__c == null || mess.CVCH__Text__c == '')
			return null;
		map<string, object> mFrom = (map<string, object>) m.get('from');
		mess.CVCH__From__c = (string) mFrom.get('id');
		mess.CVCH__From_Name__c = (string) mFrom.get('name');

		map<string, object> mTo = (map<string, object>) m.get('recipient');
		mess.CVCH__To__c = (string) mTo.get('id');
		mess.CVCH__To_Name__c = (string) mTo.get('name');
		mess.CVCH__ChannelId__c = (string) mTo.get('channelId');
		mess.CVCH__Channel__c = 'Azure';
		map<string, object> mConv = (map<string, object>) m.get('conversation');

		mess.CVCH__conversationId__c = (string) mConv.get('id');
		mess.CVCH__conversationName__c = (string) mConv.get('name');
		SM042_NexmoOut2.setInboundMessage(mess);
		return mess;
	}

	global static CVCH__NexmoMessage__c parse(string jsonbody)
	{
		system.debug('parse.start ' + jsonbody);
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonbody);
		system.debug(m);

		string message_uuid = (string) m.get('message_uuid');
		if (message_uuid == null && (string) m.get('type') != null)
			return getAzureMessage(m);
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
		mess.CVCH__InputType__c = (string) mcon.get('type');
		System.debug(mcon);
		if (mess.CVCH__InputType__c == 'button')
		{
			messageText = (string) ((map<string, object>) mCon.get('button')).get('payload');
		}
		if (mess.CVCH__InputType__c == 'image')
		{
			map<string, object> mImage = (map<string, object>) mcon.get('image');
			mess.ImageURL__c = (string) mImage.get('url');
		}

		mess.Name = message_uuid;
		mess.CVCH__From__c = sFrom;

		mess.CVCH__To__c = sTo;


		mess.CVCH__Text__c = messageText;
		if (mess.CVCH__Text__c != null)
			mess.CVCH__Text__c = mess.CVCH__Text__c.replace('١', '1').replace('٢', '2').replace('٣', '3').replace('٤', '4').replace('٥', '5').replace('٦', '6').replace('٧', '7').replace('٨', '8').replace('٩', '9').replace('٠', '0');
		mess.CVCH__Channel__c = sChannel;

		mess.CVCH__From_Name__c = '';
		mess.CVCH__To_Name__c = '';
		mess.CVCH__ChannelId__c = '';
		mess.CVCH__conversationId__c = '';
		mess.CVCH__conversationName__c = '';

		list<CVCH__NexmoMessage__c> lold =
		[
				select id
				from CVCH__NexmoMessage__c
				where Name = :mess.name
		];
		if (!lold.isEmpty())
			mess = null;
		System.debug('parse.return ' + mess);
		SM042_NexmoOut2.setInboundMessage(mess);
		return mess;
	}

	public static CVCH__Visitor__c getVisitor(string sid, string sChatNumber, string channel)
	{
		CVCH__Visitor__c ret;
		list<CVCH__Visitor__c> lVisitors = DM080_Visitor.getRecordsbyNumber(sid);

		if (!lVisitors.isEmpty())
			ret = lVisitors[0];
		else
				ret = new CVCH__Visitor__c(CVCH__Id__c = sid, CVCH__Context__c = null, CVCH__Chat_Number__c = sChatNumber, CVCH__Chanel__c = channel, id = null, CVCH__language__c = null);
		return ret;
	}


	public static void sendError0(CVCH__NexmoMessage__c mess0, string sErrorMessage, CVCH__Visitor__c vis)
	{
		if (vis != null && vis.CVCH__language__c != '' && vis.CVCH__language__c != null && vis.CVCH__language__c != 'en')
		{
			try
			{
				sErrorMessage = SM010_Utils.translate(sErrorMessage, vis.CVCH__language__c);
			}
			catch (Exception e)
			{

			}
		}

		if (mess0 != null && mess0.CVCH__From__c != null)
		{
			SM042_NexmoOut2.sendText(mess0.CVCH__From__c, sErrorMessage, mess0.CVCH__To__c);
		}
	}
	public static void sendError(CVCH__NexmoMessage__c mess0, string sErrorMessage, CVCH__Visitor__c vis)
	{
		if (sErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
		{
			sErrorMessage = sErrorMessage.substring(sErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 'FIELD_CUSTOM_VALIDATION_EXCEPTION'.length() + 2);
			if (sErrorMessage.contains('Class.'))
			{
				sErrorMessage = sErrorMessage.substring(0, sErrorMessage.indexOf('Class.'));
			}

			if (sErrorMessage.contains(': []'))
			{
				sErrorMessage = sErrorMessage.substring(0, sErrorMessage.indexOf(': []'));
			}
			if (sErrorMessage.contains('[]'))
			{
				sErrorMessage = sErrorMessage.substring(0, sErrorMessage.indexOf('[]'));
			}
		}
		else if (SM010_Utils.getChat2aiValue2('SEND DEV ERRORS') != 'TRUE')
			sErrorMessage = 'Oops, something went wrong. Please try again.';
		if (vis != null && vis.CVCH__language__c != '' && vis.CVCH__language__c != null && vis.CVCH__language__c != 'en')
		{
			try
			{
				sErrorMessage = SM010_Utils.translate(sErrorMessage, vis.CVCH__language__c);
			}
			catch (Exception e)
			{
			}
		}
		if (mess0 != null && mess0.CVCH__From__c != null)
		{
			SM042_NexmoOut2.sendText(mess0.CVCH__From__c, sErrorMessage, mess0.CVCH__To__c);
		}
	}
	@Future(Callout = true)
	global static void proceedAsync(string jsonbody)
	{
		getMessage0(jsonbody);

	}

	global static list<CVCH__NexmoMessage__c> getMessage0(string jsonbody)
	{
		CVCH__Visitor__c visr;
		datetime dtBeg = datetime.now();
		string errMsg = '';
		string sOutput = '';
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
					sOutput += '\t' + opt.getBody();
				}
				if (sOutput != null && sOutput.length() > 32000)
					sOutput = sOutput.substring(0, 32000);
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
			system.debug('error: ' + e);
			sendError0(mess0, e.getMessage(), visr);
			if (Test.isRunningTest())
				throw e;
		}
		catch (Exception e)
		{
			system.debug('error: ' + e);
			sendError(mess0, '' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString(), visr);
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
				SM010_Utils.insertConversation(scoreLUIS, scoreQnA, intentLUIS, triggeredFlow, visr.language__c, visr.id__c, mess0.Text__c, sOutput, visr.id, errMsg);
				if (triggeredLUIS)
				{ // if we got LUIS response for query - log Search Request for keyword, if present
					SM010_Utils.logSearchRequest(respLuis);
				}
			}
			catch (Exception e)
			{

			}

//			}
		}
		return lMess;
	}
}
