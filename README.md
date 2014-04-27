RUNNING THE SCRIPT
1) Clone this repository.
2) Download the acceleromater data.
3) Unzip the data, creating a folder called "UCI HAR Dataset"
4) Set the "UCI HAR Dataset" folder as your working directory.
5) Run the script in the R.
6) The script will first clean the data before creating a tidy dataset, which will be saved as "tidydata.txt" in your working directory.

ASSUMPTIONS
1) I am working from the assumption that before running this script, the files have been downloaded and extracted to a convenient local directory.
2) For this script to run, the user must have downloaded and loaded the "reshape2" package.


PREPARATION OF DATA
Step 1: Reading in and merging the data
1) First read in the "features.txt" data using the read.table function.  This data provides the variable names for the data that will be read into R in a subsequent step (step 3).
2) Next read in the subject_test and subject_train data in the "test" and "train" folders respectively.  Then merge them together using rbind.  This data will provide the ID variables for the merged dataset.
3) Read into R the x_test, x_train, y_test, and y_train, from the "test" and "train" folders.  Each time, append the column names from the features file (step 1) to the data.
4) Use the cbind function to create separate test and train datasets; one dataframe with x_test and y_test merged and another with x_train and y_train merged.
5) Use the rbind function to merge the test and train dataframes created in step 4.  Use cbind to append the subjectID variable to created in step 2 to this new merged dataframe.
6) Use the tolower function to make all of the variable names of the merged dataset lower case, making future transformations of the data easier.

Step 2: Extracting only the variables dealing with mean or standard deviation
1) Use the grep function to search through the 563 variables (column names) of the merged dataset created in step 1.  Pull out only variables with "mean" (mean) or "std" (standard deviation) in them.  Use this code: ".*mean\\(\\)|.*std\\(\\)" to insure that the variables with the "meanfreq" tag are not included.
2) Create a new dataset comprising only the 66 variables dealing with mean or standard deviation.
3) Apppend the activityID and subjectID variables to this dataset.

Step 3: Adding a descriptive activity name to accompany the activityID
1) Use subsetting to create a new variable in the means and sds dataframe (created in step 2) for activityname, where the activityIDs 1 through 6 correspond to the correct string, as found in the activity_labels text file (in the UCI HAR Dataset folder).  E.g. 1 == Walking, 2 == WalkingUpstairs, etc.

Step 4: Cleaning up the column names
1) Using the gsub function, substitute certain strings from the column names with more readable alternatives.  For example, "tbodyacc" becomes "TimeBodyAcceleration".  See the run_analysis.R script lines 45-62 for other transformations.

Step 5: Create a tidy dataset
1) Using the "reshape2" package, first melt the means and sds dataframe.
  i) In order to do this without typing out 66 variables, first set aside the ID variables in a vector.
  ii) Then use the setdiff function to create a different vector including all of the other variables besides the ID        ones (i.e. the measurement vars).
  iii) Use the melt function to melt the dataset.
2) Then recast the data using the dcast function.  Specifiy the activityID and subjectID variables and get the mean of every other variable.  
3) This creates a dataframe with 180 rows (30 subjectIDs by 6 activityIDs) and the means of every mean and standard deviation column.
4) Use the write.table function to create a copy of the recasted dataframe (called "tidydata.txt") in your working directory.