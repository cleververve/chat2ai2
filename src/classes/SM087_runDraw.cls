/**
 * Author:         serhiivolynets
 * Date:           10.02.2021
 * Description:
 **/
@RestResource(urlMapping='/runRaffleDraw/*')
global class SM087_runDraw
{
	global class drawRequest
	{
		global string raffleDrawName;
	}

	global class RunResponse
	{
		global string statusCode = '';
		global string errorMessage = '';
		global Boolean success = true;
	}


	@HttpPOST
	global static RunResponse runIt()
	{

		string jsonStr = RestContext.request.requestBody.toString();
		map<string, object> mResp = (map<string, object>) JSON.deserializeUntyped(jsonStr);
		string raffleDrawName = (string) mResp.get('raffleDrawName');
		RunResponse ret = new RunResponse();
		ret.statusCode = '200';
		ret.success = true;

		try
		{
			List<CVCH__Ruffle_Draw__c> lDraws =
			[
					select id
					from CVCH__Ruffle_Draw__c
					where name = :raffleDrawName
			];
			if (lDraws.isEmpty())
				throw new CVCH.MyException('Can not find raffle draw ' + raffleDrawName);
			CVCH__Ruffle_Draw__c draw = lDraws[0];
			string sRet = CVCH.SM082_RuffleDraw.start2(draw.Id);
			if(sret != '')
			{
				ret.statusCode = '500';ret.success = false;ret.errorMessage = sRet;
			}
		}
		catch (Exception e)
		{
			ret.statusCode = '500';ret.success = false;ret.errorMessage = e.getMessage();
		}
		return ret;
	}
}
