/**
 * Created by vladiasynskyi on 2019-05-07.
 */

@IsTest
private class SM010_UtilsTest {
    @IsTest
    static void testConvertDatePattern1() {
        String sPattern = 'dd/MM/yyyy';
        String sInputDate = '31/12/2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternYear2Digit() {
        String sPattern = 'dd/MM/yy';
        String sInputDate = '31/12/00';
        Date dExpectedDate = Date.newInstance(2000,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternYear2Digit1() {
        String sPattern = 'dd/MM/yy';
        String sInputDate = '31/12/99';
        Date dExpectedDate = Date.newInstance(1999,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternYear2Digit2() {
        String sPattern = 'dd/MM/yy';
        String sInputDate = '31/12/01';
        Date dExpectedDate = Date.newInstance(2001,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDateDecMid() {
        String sPattern = 'dd MMM yyyy';
        String sInputDate = '31 Dec 2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDateDecFirst1() {
        String sPattern = 'MMM d, yyyy';
        String sInputDate = 'Dec 31, 2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDateDecFirst2() {
        String sPattern = 'MMM d, yyyy';
        String sInputDate = 'Dec 1, 2019';
        Date dExpectedDate = Date.newInstance(2019,12,1);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDateDecFirst() {
        String sPattern = 'MMM dd yyyy';
        String sInputDate = 'Dec 31 2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDateDecEnd() {
        String sPattern = 'dd yyyy MMM';
        String sInputDate = '31 2019 Dec';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern4() {
        String sPattern = 'MM/dd/yyyy';
        String sInputDate = '12/31/2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern5() {
        String sPattern = 'MM-dd-yyyy';
        String sInputDate = '12-31-2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern6() {
        String sPattern = 'yyyy-MM-dd';
        String sInputDate = '2019-12-31';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern7() {
        String sPattern = 'd/MM/yyyy';
        String sInputDate = '31/12/2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern8() {
        String sPattern = 'd/MM/yyyy';
        String sInputDate = '1/12/2019';
        Date dExpectedDate = Date.newInstance(2019,12,1);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern9() {
        String sPattern = 'MM/d/yyyy';
        String sInputDate = '12/1/2019';
        Date dExpectedDate = Date.newInstance(2019,12,1);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern10() {
        String sPattern = 'MM/yyyy/d';
        String sInputDate = '12/2019/1';
        Date dExpectedDate = Date.newInstance(2019,12,1);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern11() {
        String sPattern = 'MM/yyyy/d';
        String sInputDate = '12/2019/31';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }

    @IsTest
    static void testConvertDatePatternDecemberMid() {
        String sPattern = 'dd MMMMM yyyy';
        String sInputDate = '31 December 2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternDecemberMid1() {
        String sPattern = 'd. MMMMM yyyy';
        String sInputDate = '31. December 2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternMarchMid() {
        String sPattern = 'dd MMMMM yyyy';
        String sInputDate = '31 March 2019';
        Date dExpectedDate = Date.newInstance(2019,3,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternMarchMid1() {
        String sPattern = 'd MMMMM yyyy';
        String sInputDate = '31 March 2019';
        Date dExpectedDate = Date.newInstance(2019,3,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternMarchMid2() {
        String sPattern = 'd MMMMM yyyy';
        String sInputDate = '1 March 2019';
        Date dExpectedDate = Date.newInstance(2019,3,1);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternMarchMid3() {
        String sPattern = 'd MMMMM yyyy';
        String sInputDate = '01 March 2019';
        Date dExpectedDate = Date.newInstance(2019,3,1);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }

    @IsTest
    static void testConvertDatePatternDecemberEnd() {
        String sPattern = 'dd yyyy MMMMM';
        String sInputDate = '31 2019 December';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }

    @IsTest
    static void testConvertDatePatternDecemberFirst() {
        String sPattern = 'MMMMM dd yyyy';
        String sInputDate = 'December 31 2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternDecemberFirst2() {
        String sPattern = 'MMMMM  dd  yyyy';
        String sInputDate = 'December  31  2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }

    ////////////

    @IsTest
    static void testConvertDatePatternMMid1() {
        String sPattern = 'd/M/yyyy';
        String sInputDate = '31/12/2019';
        Date dExpectedDate = Date.newInstance(2019,12,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternMMid() {
        String sPattern = 'd/M/yyyy';
        String sInputDate = '31/1/2019';
        Date dExpectedDate = Date.newInstance(2019,1,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternMFirst() {
        String sPattern = 'M/d/yyyy';
        String sInputDate = '1/31/2019';
        Date dExpectedDate = Date.newInstance(2019,1,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternMLast() {
        String sPattern = 'yyyy/d/M';
        String sInputDate = '2019/31/1';
        Date dExpectedDate = Date.newInstance(2019,1,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternMLast1() {
        String sPattern = 'yyyy/d/M';
        String sInputDate = '2019/31/01';
        Date dExpectedDate = Date.newInstance(2019,1,31);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePatternMLast2() {
        String sPattern = 'd/yyyy/M';
        String sInputDate = '1/2019/12';
        Date dExpectedDate = Date.newInstance(2019,12,1);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern20() {
        String sPattern = 'dd/MM/yyyy';
        String sInputDate = '22/04/2019';
        Date dExpectedDate = Date.newInstance(2019,4,22);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDatePattern21() {
        String sPattern = 'dd/M/yyyy';
        String sInputDate = '22/04/2019';
        Date dExpectedDate = Date.newInstance(2019,4,22);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDateMix1() {
        String sPattern = 'dd?M?yyyy';
        String sInputDate = '22-04-2019';
        Date dExpectedDate = Date.newInstance(2019,4,22);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDateMix2() {
        String sPattern = 'd?MMMMM?yyyy';
        String sInputDate = '22 April 2019';
        Date dExpectedDate = Date.newInstance(2019,4,22);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDateMix3() {
        String sPattern = 'MMMMM, d yyyy';
        String sInputDate = 'April, 22 2019';
        Date dExpectedDate = Date.newInstance(2019,4,22);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }
    @IsTest
    static void testConvertDateMix4() {
        String sPattern = 'M/ d/yyyy';
        String sInputDate = '4/ 22/2019';
        Date dExpectedDate = Date.newInstance(2019,4,22);

        Test.startTest();
        Date dDate = SM010_Utils.convertDate(sInputDate, sPattern);
        Test.stopTest();
        System.assertEquals(dExpectedDate, dDate);
    }




}