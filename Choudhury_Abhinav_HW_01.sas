/*
Author: Abhinav Choudhury
Student ID: 200159347
Course: ST555
Section: 001
Date Created: 2016-09-10
Purpose: Programming Assignment 1 - Read in the bankdata.txt
        dataset in SLI and MLI and apply appropriate formatting

Modification Date: 2016-09-10
Reason for Modification: N/A
*/

* Create a library reference to the PROG HW1 folder;
LIBNAME HW1 "C:\PROG HW1";

* Create a filename reference to the non-SAS dataset bankdata.txt;
FILENAME Bank "C:\PROG HW1\bankdata.txt";

* Create the Bank_SLI dataset in the HW1 library;
data HW1.Bank_SLI;
    infile Bank;        * Specify the input file;
    input FNAME $ LNAME $ ACCT $ BALANCE RATE;

    /* Use the concatenation operator (||) for strings to
       concatenate the first name and last name with a blank
    */
    NAME = FNAME || " " || LNAME;

    /* Converting the given RATE to a character format with % sign
       The percentw.d format multiplies the given value with 100 and 
       appends the % sign.
       So using,
                RATE_CHAR = put(RATE, percent6.2);
       does not give us the correct values of interest rate.       
     */
    RATE_CHAR = put(RATE, percent6.2);

    /* Create an AcctType character variable by using the substring function
       The substr function takes 2 arguments: the position to start
       the substring, and the number of characters.
       Since we only want the first character, we use arguments 1, 1
    */
    AcctType = substr(ACCT, 1, 1);
    
    /* Create an AcctNum numeric variable:
       First use substr to extract the last 4 characters of ACCT
       Then convert the (character) output to numeric using
       input() function with w.d informat
    */
    AcctNum = input(substr(ACCT, 2, 4), 4.);

    * Apply permanent labels to varibles in the dataset;
    label   FNAME='First name of customer'
            LNAME='Last name of customer'
            ACCT='Account number of customer'
            BALANCE='Balance in account'
            RATE='Rate of interest'
            NAME='Full name of customer'
            RATE_CHAR='RATE in character format with %'
            AcctType='Account Type character'
            AcctNum='Account number'
run;

* Create the Bank_MLI dataset in the HW1 library;
data HW1.Bank_MLI;
    infile Bank;

    /* Using modified list input:
       Since full name contains spaces, we use the ampersand modifier.
       Maximum field width of names is 14 including space.
       We use colon modifier in all other cases, since there are
       no delimiters in the content
    */
    input   NAME & $14.
            ACCT : $5.
            BALANCE : 5.
            RATE : 4.2;
run;

* Assign a permanent label to the Bank_MLI dataset using proc dataset;
proc datasets library=HW1;
    modify Bank_MLI(label="Bank MLI dataset");
run;

* Report descriptor information for the Bank_SLI dataset;
proc contents data=HW1.Bank_SLI;
run;

* Report descriptor information for the Bank_MLI dataset;
proc contents data=HW1.Bank_MLI;
run;
