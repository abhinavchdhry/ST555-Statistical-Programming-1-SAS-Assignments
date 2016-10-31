/*
Author: Abhinav Choudhury
Student ID: 200159347
Course: ST555
Section: 001
Date Created: 2016-10-29
Purpose: Programming Homework 6

Modification Date: 2016-10-29
Reason for Modification: N/A
*/

LIBNAME HW6 "C:\Users\achoudh3\HW6";

/**** SECTION 1: Start ***/
data HW6.DESIGN (drop = i j k);
    do i = 1 to 5;
        do j = 1 to 4;
            do k = 1 to 3;
            Block = i;
            if j eq 1 then Treatment = 'A';
            if j eq 2 then Treatment = 'B';
            if j eq 3 then Treatment = 'C';
            if j eq 4 then Treatment = 'D';
            Replicate = k;
            output;
            end;
        end;
    end;
run;

data HW6.DESIGN_RAND_0 (drop = i j k);
    do i = 1 to 5;
        do j = 1 to 4;
            do k = 1 to 3;
            Block = i;
            if j eq 1 then Treatment = 'A';
            if j eq 2 then Treatment = 'B';
            if j eq 3 then Treatment = 'C';
            if j eq 4 then Treatment = 'D';
            Replicate = k;
            rannum = rand('uniform');
            output;
            end;
        end;
    end;
run;

proc sort data=HW6.DESIGN_RAND_0 out=HW6.RCBD_0;
    by Block rannum;
run;

/* 4. On running the code above multiple times and observing the records,
    we notice that the number of different Treatments within each Block
    and the number of different replicates within each Treatment stay the same within the same Block.
    The block column also does not change.
    Only the ordering of records within each block is randomized.
*/

data HW6.DESIGN_RAND_SEED (drop = i j k);
    call streaminit(12345);
    do i = 1 to 5;
        do j = 1 to 4;
            do k = 1 to 3;
            Block = i;
            if j eq 1 then Treatment = 'A';
            if j eq 2 then Treatment = 'B';
            if j eq 3 then Treatment = 'C';
            if j eq 4 then Treatment = 'D';
            Replicate = k;
            rannum = rand('uniform');
            output;
            end;
        end;
    end;
run;

proc sort data=HW6.DESIGN_RAND_SEED out=HW6.RCBD_SEED;
    by Block rannum;
run;

/* Now, after setting the seed, the randomization still happens as before
    and the ordering of the records within each Block have been randomized.
    However, this new rearrangement stays the same across multiple runs, since setting
    the seed ensures that the same sequence of random numbers are generated every time.
    If we change the seed, the random numbers will turn out different than when
    the seed was (12345), but the sequence of random numbers generated will still be same
    across multiple iterations using the same seed. Hence, the shuffling of the records
    within each Block will now be different from before, but will stay like that across iterations.
*/

/**** SECTION 1: End ***/



/**** SECTION 2: Start ***/

* First sort the fish dataset by Lake Type and Dam;
*********** IMPORTANT NOTE: Assumes fish dataset is in HW6 directory;
proc sort data=HW6.fish out=HW6.fish_sorted;
    by lt dam;
run;

* Compute mean and median for Lake Type x Dam groupings;
* Use ODS to output to a dataset STATZ;
* Drop latitude and longitude values;
proc means data=HW6.fish_sorted mean median;
    by lt dam;
    var hg n elv sa z st da rf fr;
    output out=HW6.STATZ (drop = _TYPE_ _FREQ_)
        mean = hg_mean n_mean elv_mean sa_mean z_mean st_mean da_mean rf_mean fr_mean
        median = hg_median n_median elv_median sa_median z_median st_median da_median rf_median fr_median;
run;

* Merge the sorted fish dataset and the STATZ dataset using groupwise merge;
* Use arrays to compute the differences from mean and median and respective percentages for the same;
data HW6.ALL (drop = lat: long: i);
    merge HW6.fish_sorted HW6.STATZ;
    by lt dam;

    array orig[9] hg n elv sa z st da rf fr;
    array origmean[9] hg_mean n_mean elv_mean sa_mean z_mean st_mean da_mean rf_mean fr_mean;
    array origmed[9] hg_median n_median elv_median sa_median z_median st_median da_median rf_median fr_median;
    array diff_from_mean[9] hg_dfm n_dfm elv_dfm sa_dfm z_dfm st_dfm da_dfm rf_dfm fr_dfm;
    array perc_diff_from_mean[9] hg_pdfm n_pdfm elv_pdfm sa_pdfm z_pdfm st_pdfm da_pdfm rf_pdfm fr_pdfm;
    array diff_from_med[9] hg_dfmed n_dfmed elv_dfmed sa_dfmed z_dfmed st_dfmed da_dfmed rf_dfmed fr_dfmed;
    array perc_diff_from_med[9] hg_pdfmed n_pdfmed elv_pdfmed sa_pdfmed z_pdfmed st_pdfmed da_pdfmed rf_pdfmed fr_pdfmed;

    do i = 1 to dim(orig);
        diff_from_mean[i] = orig[i] - origmean[i];
        if origmean[i] eq 0 then call missing(perc_diff_from_mean[i]);
        else perc_diff_from_mean[i] = diff_from_mean[i]/origmean[i];
        diff_from_med[i] = orig[i] - origmed[i];
        if origmed[i] eq 0 then call missing(perc_diff_from_med[i]);
        else perc_diff_from_med[i] = diff_from_med[i]/origmed[i];
    end;

    * Apply appropriate formats to all variables;
    * Since all varaibles from hg_mean to fr_pdfmed are contguous in PDV, use --;
    format hg_mean -- fr_pdfmed 10.2;

    /* Apply labels separately for all new variables */
    label   hg_mean="Mean Hg (within Dam and Lake type)"
            n_mean="Mean of n(within Dam and Lake type)"
            elv_mean="Mean Elv (within Dam and Lake type)"
            sa_mean="Mean sa (within Dam and Lake type)"
            z_mean="Mean z (within Dam and Lake type)"
            st_mean="Mean st (within Dam and Lake type)"
            da_mean="Mean da (within Dam and Lake type)"
            rf_mean="Mean rf (within Dam and Lake type)"
            fr_mean="Mean fr (within Dam and Lake type)";

    label   hg_median="Median Hg (within Dam and Lake type)"
            n_median="Median n (within Dam and Lake Type)"
            elv_median="Median elv (within Dam and Lake Type)"
            sa_median="Median sa (within Dam and Lake Type)"
            z_median="Median z (within Dam and Lake Type)"
            st_median="Median st (within Dam and Lake Type)"
            da_median="Median da (within Dam and Lake Type)"
            rf_median="Median rf (within Dam and Lake Type)"
            fr_median="Median fr (within Dam and Lake Type)";

    label   hg_dfm="Difference from mean of Hg"
            n_dfm="Difference from mean of n"
            elv_dfm="Difference from mean of elv"
            sa_dfm="Difference from mean of sa"
            z_dfm="Difference from mean of z"
            st_dfm="Difference from mean of st"
            da_dfm="Difference from mean of da"
            rf_dfm="Difference from mean of rf"
            fr_dfm="Difference from mean of fr";

    label   hg_pdfm="Percentage difference from mean of Hg"
            n_pdfm="Percentage difference from mean of n"
            elv_pdfm="Percentage difference from mean of elv"
            sa_pdfm="Percentage difference from mean of sa"
            z_pdfm="Percentage difference from mean of z"
            st_pdfm="Percentage difference from mean of st"
            da_pdfm="Percentage difference from mean of da"
            rf_pdfm="Percentage difference from mean of rf"
            fr_pdfm="Percentage difference from mean of fr";

    label   hg_dfmed="Difference from median of Hg"
            n_dfmed="Difference from median of n"
            elv_dfmed="Difference from median of elv"
            sa_dfmed="Difference from median of sa"
            z_dfmed="Difference from median of z"
            st_dfmed="Difference from median of st"
            da_dfmed="Difference from median of da"
            rf_dfmed="Difference from median of rf"
            fr_dfmed="Difference from median of fr";

    label   hg_pdfmed="Percentage difference from median of Hg"
            n_pdfmed="Percentage difference from median of n"
            elv_pdfmed="Percentage difference from median of elv"
            sa_pdfmed="Percentage difference from median of sa"
            z_pdfmed="Percentage difference from median of z"
            st_pdfmed="Percentage difference from median of st"
            da_pdfmed="Percentage difference from median of da"
            rf_pdfmed="Percentage difference from median of rf"
            fr_pdfmed="Percentage difference from median of fr";
run;

* Sort the resulting dataset by Name;
proc sort data=HW6.ALL;
    by Name;
run;

/**** SECTION 2: End ***/
