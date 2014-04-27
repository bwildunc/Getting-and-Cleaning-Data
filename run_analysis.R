### set working directory to the "UCI HAR Dataset" folder
setwd("/Users/ ........ /UCI\ HAR\ Dataset")

### load into R the variable names in the "features.txt" file
column_names<-read.table(paste("features.txt",sep=""),col.names=c("ID","Variable"))

### load into R the subject data
subjects_test<-read.table(paste("test","/","subject_test.txt", sep=""),col.names=c("SubjectID"))
subjects_train<-read.table(paste("train","/","subject_train.txt", sep=""),col.names=c("SubjectID"))
subjects_merged<-rbind(subjects_test,subjects_train)

### load into R the X data, appending the column names from the features file
x_test<- read.table(paste("test","/","X_test.txt", sep=""),col.names=column_names$Variable)
x_train<- read.table(paste("train","/","X_train.txt", sep=""),col.names=column_names$Variable)

### load into R the Y data, naming the columns "ActivityID"
y_test<- read.table(paste("test","/","y_test.txt", sep=""),col.names="ActivityID")
y_train<- read.table(paste("train","/","y_train.txt", sep=""),col.names="ActivityID")

### merge the test and train data separately, creating 1 dataframe for each
testmerged<-cbind(x_test,y_test)
trainmerged<-cbind(x_train,y_train)

### now merge all of the data into 1 single dataframe, completing step 1
alldata<-rbind(testmerged,trainmerged)
alldata<-cbind(alldata,subjects_merged) ### add subject ID to main dataframe
names(alldata) <- tolower(names(alldata)) ### make all variable names in the merged dataset lower case to ease later transformations

### extracts only the measurements relating to mean or standard deviation, completing step 2
subset_column_names<-grep(".*mean\\(\\)|.*std\\(\\)", column_names$Variable)
means_sds<-alldata[,subset_column_names]
means_sds$activityID<-alldata$activityid   ### appends the Activity ID variable into the new means/std dataframe
means_sds$subjectID<-alldata$subjectid ### appends the Subject ID variable into the new means/std dataframe

### adds an activity name variable with the correct coding (e.g. 1=walking, 5=standing, etc), completing step 3
means_sds$activityname[means_sds$activityID==1]<-"Walking"
means_sds$activityname[means_sds$activityID==2]<-"WalkingUpstairs"
means_sds$activityname[means_sds$activityID==3]<-"WalkingDownstairs"
means_sds$activityname[means_sds$activityID==4]<-"Sitting"
means_sds$activityname[means_sds$activityID==5]<-"Standing"
means_sds$activityname[means_sds$activityID==6]<-"Laying"

### cleans up column names, completing step 4
clean_names<-colnames(means_sds)
clean_names<-gsub("\\.+mean\\.+", clean_names, replacement="Mean")
clean_names<-gsub("\\.+std\\.+", clean_names, replacement="StandardDeviation")
clean_names<-gsub("tbodyacc", clean_names, replacement="TimeBodyAcceleration")
clean_names<-gsub("tgravityacc", clean_names, replacement="TimeGravityAcceleration")
clean_names<-gsub("tbodygyro", clean_names, replacement="TimeBodyGyro")
clean_names<-gsub("tbodygyrojerk", clean_names, replacement="TimeBodyGyroJerk")
clean_names<-gsub("tbodyaccmag", clean_names, replacement="TimeBodyAccelerationMag")
clean_names<-gsub("tgravityaccmag", clean_names, replacement="TimeGravityAccelerationMag")
clean_names<-gsub("tbodyaccjerkmag", clean_names, replacement="TimeBodyAccelerationJerkMag")
clean_names<-gsub("tbodygyromag", clean_names, replacement="TimeBodyGyroMag")
clean_names<-gsub("tbodygyrojerkmag", clean_names, replacement="TimeBodyGyroJerkMag")
clean_names<-gsub("fbodyacc", clean_names, replacement="FftBodyAcceleration")
clean_names<-gsub("fbodyaccjerk", clean_names, replacement="FftBodyAccelerationJerk")
clean_names<-gsub("fbodygyro", clean_names, replacement="FftBodyGyro")
clean_names<-gsub("fbodyaccmag", clean_names, replacement="FftBodyAccelerationMag")
clean_names<-gsub("fbodybodyaccjerkmag", clean_names, replacement="FftBodyAccelerationJerkMag")
clean_names<-gsub("fbodybodygyromag", clean_names, replacement="FftBodyGyroMag")
clean_names<-gsub("fbodybodygyrojerkmag", clean_names, replacement="FftBodyGyroJerkMag")
colnames(means_sds)<-clean_names

### you must use the reshape2 package in order to melt and recast the dataframe
### melting the data
ids<-c("activityID","subjectID","activityname") ### setting aside the ID vars
measures<-setdiff(colnames(means_sds),ids)  ### separately creating measure vars so I won't have to type out 60+ variable names
melted_data<-melt(means_sds,id=ids,measure.vars=measures)

### re-casting the data to provide mean for each variable by subject and activity ID
### e.g. mean by subject #1, activity 1-6; subject #2, activity 1-6, etc.  For a total of 180 rows.
meancast<-dcast(melted_data,activityID + subjectID~variable, mean)

### saves a tidy dataset to your working directory
write.table(meancast,file="tidydata.txt")