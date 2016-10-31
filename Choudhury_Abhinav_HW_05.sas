/*
Author: Abhinav Choudhury
Student ID: 200159347
Course: ST555
Section: 001
Date Created: 2016-10-21
Purpose: Programming Homework 5

Modification Date: 2016-10-21
Reason for Modification: N/A
*/

options formdlim='~';

LIBNAME HW4 "C:\Users\achoudh3\HW4";
LIBNAME HW5 "C:\Users\achoudh3\HW5";

/* Declare the PDF files we are going to output */
FILENAME FULL_PDF "C:\Users\achoudh3\HW5\Air_Emps.pdf";
FILENAME SHRT_PDF "C:\Users\achoudh3\HW5\Air_Emps_Short.pdf";

data HW5.Air_Emps_Raises (drop = Job_Level rename = (CurrentSalary = Old_Salary));
    set HW4.Air_Emps_Full;
    length Job_Level $ 2;

    /* Create a temporary variable which calculates the number of years
        of service of an employee from the hiredate and the current date */
    Years_of_Service = YRDIF(hiredate, today());

    /* Extract Job_Level (temporary) from Job_Type by checking for existence of 1, 2, 3 in Job_Type
       We use the index function which searches for the occurence of characters within a
        string. If found it returns the index, else returns 0 */
    if (index(JobType, '1') NE 0)
        then Job_Level = '1';
    else if (index(JobType, '2') NE 0)
        then Job_Level = '2';
    else if (index(JobType, '3') NE 0)
        then Job_Level = '3';
    else
        Job_Level = 'NA';

    /* Based on given conditions compute the new raised salary.
        Use nested SELECT groups */
    select;
        when (Years_of_Service >= 35) do;
            select(Job_Level);
            when ('2') New_Salary = CurrentSalary * 1.025 + 3500;
            when ('3') New_Salary = CurrentSalary * 1.025 + 3500;
            when ('1') New_Salary = CurrentSalary * 1.015 + 3500;
            otherwise New_Salary = CurrentSalary * 1.02 + 3500;
            end;
        end;
        when (25 <= Years_of_Service < 35) do;
            select(Job_Level);
            when ('2') New_Salary = CurrentSalary * 1.02 + 2000;
            when ('3') New_Salary = CurrentSalary * 1.02 + 2000;
            when ('1') New_Salary = CurrentSalary * 1.01 + 2000;
            otherwise New_Salary = CurrentSalary * 1.0175 + 2000;
            end;
        end;
        when (missing(Years_of_Service)) do;    * When Years_of_Service cannot be computed;
            /* Note that this automatically sets New_Salary in PDV to missing */
            put "NOTE: Empid needs to be investigated.";
        end;
        otherwise do;
            select(Job_Level);
            when ('2') New_Salary = CurrentSalary * 1.025;
            when ('3') New_Salary = CurrentSalary * 1.025;
            when ('1') New_Salary = CurrentSalary * 1.0125;
            otherwise New_Salary = CurrentSalary * 1.0075;
            end;
        end;
    end;

    /* Apply labels and appropriate formats */
    label   New_Salary='New raised salary'
            Years_of_Service='Years of service';
    format  New_Salary dollar11.2;
    format  Years_of_Service 5.2;
run;

/* Sort the dataset by empid */
proc sort data=HW5.Air_Emps_Raises;
    by empid;
run;

data HW5.Air_Emps_Underpaid (drop = Job_Level rename = (CurrentSalary = Old_Salary));
    set HW4.Air_Emps_Underpaid;
    length Job_Level $ 2;

    /* Create a temporary variable which calculates the number of years
        of service of an employee from the hiredate and the current date */
    Years_of_Service = YRDIF(hiredate, today());

    /* Extract Job_Level from Job_Type by checking for existence of 1, 2, 3 in Job_Type
       We use the index function which searches for the occurence of characters within a
        string. If found it returns the index, else returns 0 */
    if (index(JobType, '1') NE 0)
        then Job_Level = '1';
    else if (index(JobType, '2') NE 0)
        then Job_Level = '2';
    else if (index(JobType, '3') NE 0)
        then Job_Level = '3';
    else
        Job_Level = 'NA';

    /* Based on given conditions compute the new raised salary.
        Use nested SELECT groups */
    select;
        when (Years_of_Service >= 35) do;
            select(Job_Level);
            when ('2') New_Salary = CurrentSalary * 1.025 + 3500;
            when ('3') New_Salary = CurrentSalary * 1.025 + 3500;
            when ('1') New_Salary = CurrentSalary * 1.015 + 3500;
            otherwise New_Salary = CurrentSalary * 1.02 + 3500;
            end;
        end;
        when (25 <= Years_of_Service < 35) do;
            select(Job_Level);
            when ('2') New_Salary = CurrentSalary * 1.02 + 2000;
            when ('3') New_Salary = CurrentSalary * 1.02 + 2000;
            when ('1') New_Salary = CurrentSalary * 1.01 + 2000;
            otherwise New_Salary = CurrentSalary * 1.0175 + 2000;
            end;
        end;
        when (missing(Years_of_Service)) do;    * When Years_of_Service cannot be computed;
            put "NOTE: Empid needs to be investigated.";
        end;
        otherwise do;
            select(Job_Level);
            when ('2') New_Salary = CurrentSalary * 1.025;
            when ('3') New_Salary = CurrentSalary * 1.025;
            when ('1') New_Salary = CurrentSalary * 1.0125;
            otherwise New_Salary = CurrentSalary * 1.0075;
            end;
        end;
    end;

    if (New_Salary <= 45000);

    /* Apply labels and appropriate formats */
    label   New_Salary='New raised salary'
            Years_of_Service='Years of service';
    format  New_Salary dollar11.2;
    format  Years_of_Service 5.2;
run;

/* Create first PDF using ODS that contains full Air_Emps_Raises and Air_Emps_Underpaid */
ODS PDF FILE=FULL_PDF;
proc print data=HW5.Air_Emps_Raises label;
    title "Dataset: Air_Emps_Raises";
    footnote "Footnote: Dataset Air_Emps_Raises";
run;

proc print data=HW5.Air_Emps_Underpaid label;
    title "Dataset: Air_Emps_Underpaid";
    footnote "Footnote: Dataset Air_Emps_Underpaid";
run;

ODS PDF CLOSE;

ODS PDF FILE=SHRT_PDF;
/* For the short PDF, keep only Employee ID (empid), Years_of_Service and New_Salary */
proc print data=HW5.Air_Emps_Raises(keep = empid Years_of_Service New_Salary)label;
    title "Dataset (shortened): Air_Emps_Raises";
    footnote "Footnote: Dataset Air_Emps_Raises";
run;

proc print data=HW5.Air_Emps_Underpaid(keep = empid Years_of_Service New_Salary) label;
    title "Dataset (shortened): Air_Emps_Underpaid";
    footnote "Footnote: Dataset Air_Emps_Underpaid";
run;
ODS PDF CLOSE;
