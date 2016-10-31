/*
Author: Abhinav Choudhury
Student ID: 200159347
Course: ST555
Section: 001
Date Created: 2016-09-19
Purpose: Programming Homework 2

Modification Date: 2016-09-20
Reason for Modification: N/A
*/

/* Setting options to remove date and include page nos. */
options formdlim='~' nodate number nocenter pageno=1;

LIBNAME HW2 "C:\Users\achoudh3\HW2\";

FILENAME Pres1 "C:\Users\achoudh3\HW2\President_v1.txt";

data HW2.Pres1;
    /* Not that the delimiter here is a TAB (09x).
    We use MISSOVER so that missing values at the end of a record dont corrupt dataset */
    infile Pres1 dlm='09'x missover;
    input   FullName : $22.
            City : $18.
            State : $20.
            ASP 
            DOB : mmddyy10.
            Term 
            Votes : comma10.
            PercVote : percent6.;

    /* Setting formats for DOB, Votes and PercVote*/
    format  DOB mmddyy10. Votes comma10. PercVote percent10.2;

    /* Setting labels */
    label   FullName="Full name of president"
            City="City of president"
            State="State of president"
            ASP="Age starting presidency"
            DOB="Date of birth"
            Term="Term of presidency"
            Votes="Number of votes"
            PercVote="Percentage of votes";

    /* Create a char version of DOB in 01JAN1960 format */
    DOBC = put(DOB, date9.);

    /* Extract day, mon, year from DOBC */
    Day = substr(DOBC, 1, 2);
    Month = substr(DOBC, 3, 3);
    Year = substr(DOBC, 6, 4);

    /* Character version of DOB in MM/DD/YYYY format */
    DOBC2 = put(DOB, mmddyy10.);

    /* Extract numerical values for day, month, year using scan */
    Day_num = scan(DOBC2, 1, '/');
    Month_num = scan(DOBC2, 2, '/');
    Year_num = scan(DOBC2, 3, '/');

    /* SCAN vs SUBSTR -- 
    Scan(input, n, d) takes a char input and splits it
    based on delimiter d, and returns the word numbered n
    Substr(input, k, n) takes a char input and returns a substr of size n characters 
    beginning at character position k */

    /* using TRANWRD() function to replace '/' with '-' */
    DOBC2 = tranwrd(DOBC2, '/', '-');
run;

/* SECTION 1: Print Descriptor portion of data */
options pageno=1;
proc contents data=HW2.Pres1;
    title "SECTION 1: Printing descriptor portion of data";
run;

/* SECTION 2: Group ASP, PercVote by state and calculate mean and median
   Note that PROC MEANS ignores missing values from the computation by default */
options pageno=1;
proc means data=HW2.Pres1;
    title "SECTION 2: Printing mean median";
    class State;
    var Term ASP PercVote;
    output out=temp mean = AvgTerm AvgASP AvgPercVote;
run;

/* SECTION 3: Compute and print frequencies of presidents first by State, and then by both State and Age */
options pageno=1;
proc freq data=HW2.Pres1;
    title "SECTION 3: Printing frequencies by State and by both State and ASP";
/*    table State;*/
/*    table State * ASP;*/
run;

proc sort data=HW2.Pres1 out=Pres1;
    by State;
run;

/* SECTION 4: Print the content portion of the dataset */
options pageno=1;
proc print data=Pres1;
    title "SECTION 4: Printing contents of dataset";
    by ASP;
run;

options pageno=1;
proc print data=Pres1 noobs;
    title "Printing sum by State";
    by ASP;
    sum PercVote;
run;
