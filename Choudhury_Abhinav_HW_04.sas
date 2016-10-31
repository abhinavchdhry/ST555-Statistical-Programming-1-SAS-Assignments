/*
Author: Abhinav Choudhury
Student ID: 200159347
Course: ST555
Section: 001
Date Created: 2016-10-13
Purpose: Programming Homework 4

Modification Date: 2016-10-13
Reason for Modification: N/A
*/

LIBNAME HW4 "C:\Users\achoudh3\HW4";

FILENAME salesdiv "C:\Users\achoudh3\HW4\SALES Division.dat";
FILENAME aodiv "C:\Users\achoudh3\HW4\AO Division.dat";
FILENAME corpdiv "C:\Users\achoudh3\HW4\CORP Division.dat";
FILENAME finitdiv "C:\Users\achoudh3\HW4\FINANCE_IT Division.dat";
FILENAME flopsdiv "C:\Users\achoudh3\HW4\FLIGHT OPS Division.dat";
FILENAME hrdiv "C:\Users\achoudh3\HW4\HR Division.dat";
FILENAME empdata "C:\Users\achoudh3\HW4\empdata.dat";
FILENAME personal "C:\Users\achoudh3\HW4\personal.dat";

options formdlim='~';

/* Read in all the individual division datasets
    Note that all these text files use tabs as delimiters and there are embedded spaces
    So we use modified list input with colon modifier
*/
data work.salesdiv;
    infile  salesdiv dlm='09'x firstobs=2;
    input   DivName : $100.
            JobType : $100.;
run;

data work.aodiv;
    infile aodiv dlm='09'x firstobs=2;
    input   DivName : $100.
            JobType : $100.;
run;

data work.corpdiv;
    infile corpdiv dlm='09'x firstobs=2;
    input   DivName : $100.
            JobType : $100.;
run;

data work.finitdiv;
    infile finitdiv dlm='09'x firstobs=2;
    input   DivName : $100.
            JobType : $100.;
run;

data work.flopsdiv;
    infile flopsdiv dlm='09'x firstobs=2;
    input   DivName : $100.
            JobType : $100.;
run;

data work.hrdiv;
    infile hrdiv dlm='09'x firstobs=2;
    input   DivName : $100.
            JobType : $100.;
run;

/* Merge (concatenate) the datasets above to create the DIVISION dataset */
data HW4.DIVISION;
    set aodiv corpdiv finitdiv flopsdiv hrdiv salesdiv;
run;

/* Read in the empdata dataset */
data work.empdata;
    infile empdata firstobs=2 truncover;
    input hiredate date9.
            empid : $10.
            JobType : $10.
            salary dollar10.;
run;

/* Sort empdata and DIVISION by JobType so we can do a groupwise merge */
proc sort data=empdata;
    by JobType;
run;

proc sort data=HW4.DIVISION;
    by JobType;
run;

/* Merge the empdata and DIVISION datasets to get the JobCode column for each record */
data empdata_div_merged;
    merge HW4.DIVISION empdata;
    by JobType;
run;

/* Read in the personal dataset */
data work.personal;
    infile personal firstobs=2;
    input   lname & $100.
            fname & $100.
            phone
            empid : $10.;
run;

/* Sort the personal and empdata_div_merged datsets by empid before merging */
proc sort data=personal;
    by empid;
run;

proc sort data=empdata_div_merged;
    by empid;
run;

/* Merge the personal and empdata_div_merged datasets by empid */
data HW4.Air_Emps_Full;
    merge personal (drop=phone) empdata_div_merged (rename = (salary=CurrentSalary));
    by empid;
    format CurrentSalary dollar10. hiredate date9.;
    label lname='Last Name'
            fname='First Name'
            empid='Employee ID'
            DivName='Division Name'
            JobType='Job Type'
            hiredate='Date of Hiring'
            CurrentSalary='Current Salary';
run;

/* Subset the Air_Emps_Full dataset to create the Air_Emps_Underpaid dataset */
data HW4.Air_Emps_Underpaid;
    set HW4.Air_Emps_Full;

    /* Filter records with CurrentSalary less than 45000 and hiring date before 1st Jan 1990 */
    where (CurrentSalary lt 45000 and hiredate lt '01JAN1990'd);
run;
