/*
Author: Abhinav Choudhury
Student ID: 200159347
Course: ST555
Section: 001
Date Created: 2016-09-26
Purpose: Programming Homework 3

Modification Date: 2016-09-26
Reason for Modification: N/A
*/

/* Setting options to remove date and include page nos. */
options formdlim='~' nodate number nocenter pageno=1;

LIBNAME HW3 "C:\Users\achoudh3\HW3\";
LIBNAME ST555 "L:\";

FILENAME Licences "C:\Users\achoudh3\HW3\LIC_702-P.txt";

data HW3.Licences;
    /* While reading in records, only dates are kept numeric 
        as mentioned in the question. Rest are characters.
        Max length for all character is assumed to be 100 by default
        unless otherwise inferred.
        ***IMPORTANT Dates are read in as characters, and later converted to 
        separate numeric variables. This is because using mmddyy10. format in input statement below
        does not work correctly.
    */
    infile Licences firstobs=2 dsd dlm='|';
    input   proc_cde : $100.
            prof_name : $100.
            lic_id : $100.
            expDate : $10.
            origDate : $10.
            rankcode : $2.
            LicenceNum : $100.
            SEDate : $10.
            BAIndicator : $5.
            LcStatusDesc : $10.
            LastName : $100.
            FirstName : $100.
            MiddleName : $100.
            NameSuffix : $100.
            BusinessName : $100.
            LcActiveStatusDesc : $100.
            County : $100.
            CountyDesc : $100.
            MailAddL1 : $100.
            MailAddL2 : $100.
            City : $100.
            State : $100.
            ZIPCode : $100.
            AreaCode : $100.
            PhoneNum : $100.
            PhoneExt : $100.
            PracticeAddL1 : $100.
            PracticeAddL2 : $100.
            PracticeCity : $100.
            PracticeState : $100.
            PracticeZIP : $100.
            Email : $100.
            ModCdes : $100.
            PrescIdx : $100.
            DispIdx : $100.;

    /* Create numerical versions of expDate and origDate */
    expDateNum = input(expDate, mmddyy10.);
    origDateNum = input(origDate, mmddyy10.);
run;


/* Print the necessary variables of the dataset, no observation no. */
proc print data=HW3.Licences label noobs;
    label   lic_id="LIC_ID"
            origDateNum="Original Date"
            LastName="Last Name"
            FirstName="First Name"
            BAIndicator="Board_Action_Indicator"
            LcStatusDesc="Licence_Status_Description"
            LcActiveStatusDesc="Licence_Active_Status_Desc"
            Email="Email";
    var     lic_id origDateNum LastName FirstName BAIndicator LcStatusDesc LcActiveStatusDesc Email;
    format  origDateNum mmddyy10.;
run;

/* Working with the fish dataset. Change options as mentioned */
options nodate number pageno=1 linesize=85 pagesize=60 center;

/* Sort by dam lt and n, in that order and put output in a temporary dataset fish_sorted */
proc sort data=HW3.fish out=HW3.fish_sorted;
    by dam lt n;
run;

/* Print dataset as per details mentioned in HW
    noobs - Do not print observation no.
    label - Use labels instead of names in output headers
    blankline - Insert a blankline after every record printed
*/
proc print data=HW3.fish_sorted noobs label blankline=1;
    by dam lt n;
    sum rf fr;
        sumby lt;       * Sum by lt and outer groups;
        pageby lt;      * Insert page breaks by each lt value;
    id name;
    var lat1-lat3 long1-long3 rf fr;

    * Assign labels;
    label   name="Name"
            n="# of fish"
            lat1="Latitude (deg.)"
            lat2="Lat. (min. part)"
            lat3="Lat. (sec. part)"
            long1="Longitude (deg.)"
            long2="Long. (min. part)"
            long3="Long. (sec. part)"
            rf="Runoff factor"
            fr="Flushing rate (#/year)";

    /* Assign formats so lat and long value take max 2 chars */
    format lat1-lat3 2. long1-long3 2.;

    /* Assign formats such that rf has total field width of 6 char and 3 decimals
        and fr has total field width 7 chars and 2 decimal places.
    */
    format rf 6.3 fr 7.2;
run;

/* Compute means */
proc means data=HW3.fish n mean std noprint maxdec=3;
    class lt dam / missing;     * Group by lt and dam. Include missing values;
    var hg elv z;               * Compute means only for these variables;
    types lt*dam;               * Include only 2 way groupings for lt * dam in output;

    * Output to temp dataset DIFF. Drop _TYPE_ and _FREQ_ columns from output. Include only the mean;
    output out=DIFF (drop=_type_ _freq_) mean= HG_AVG ELV_AVG Z_AVG;
run;

/* Compare the DIFF dataset against the provided dataset proghw03_statz */
proc compare base=HW3.proghw03_statz compare=DIFF novalues;
run;

/* NOTE: We have not included a count variable in our DIFF dataset,
    since it is not mentioned in the HW details
    There is however a count variable reporting the group-wise count in the proghw03_statz dataset
    PROC COMPARE reports this saying "Number of Variables in HW3.PROGHW03_STATZ but not in WORK.DIFF: 1"
    There are no apparent differences in the two datasets other than the count column
*/
