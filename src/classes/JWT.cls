public class JWT {

    String applicationId = 'aa048234-54d2-4733-9df5-11b2b033ee06';
    public String alg {get;set;}

    public Integer validFor {get;set;}
    public String cert {get;set;}
    public String pkcs8 {get;set;}


    public static final String HS256 = 'HS256';
    public static final String RS256 = 'RS256';
    public static final String NONE = 'none';


    public JWT() {
        this.alg = RS256;
        this.validFor = 300;
    }


    public String issue() {

        String jwt = '';

        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
        header.writeStringField('typ', 'JWT');
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('application_id', applicationId);
        body.writeNumberField('iat', rightNow);
        body.writeStringField('jti', 'id'+dateTime.now().getTime());
        body.writeNumberField('iat', rightNow);
        body.writeNumberField('exp', (rightNow + validFor));


      body.writeEndObject();

        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));

            Blob signature = null;

            if (cert != null ) {
                signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwt), cert);
            } else {
                Blob privateKey = EncodingUtil.base64Decode(pkcs8);
                if(!test.isRunningTest())
                    signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), privateKey);
                else
                        signature = Blob.valueOf('aaaa');
            }
            jwt += '.' + base64URLencode(signature);
        system.debug('jwt='+jwt);
        return jwt;

    }


    public String base64URLencode(Blob input){
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }

    public static String getAccessToken()
    {
        JWT jwt = new JWT();
        if(!Test.isRunningTest())
        {
            CVCH__Key__c rec = [select id, CVCH__Value__c,CVCH__Application_Id__c  from CVCH__Key__c where CVCH__Active_Flag__c = true limit 1];
            jwt.pkcs8 = rec.CVCH__Value__c;
            if(rec.CVCH__Application_Id__c != '' && rec.CVCH__Application_Id__c != null)
                jwt.applicationId = rec.CVCH__Application_Id__c;
        }
        else
            jwt.pkcs8 = 'aaabbb';
        system.debug('jwt.pkcs8=>'+jwt.pkcs8);
        return jwt.issue();
    }
}