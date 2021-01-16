library(dplyr)
library(data.table)

#Download, unzip the file and reading text files into data frames
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./project")){dir.create("./project")}
download.file(fileurl,destfile = "./project/data.zip",method = "curl")
unzip("./project/data.zip",exdir = "./project")

features <- read.table("./UCI HAR Dataset/features.txt", header = FALSE)
activity <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)

#Merges the training and the test sets to create one data set.
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
SubjectData <- rbind(subject_train,subject_test)
names(SubjectData)<-c("subject")
names(Y)<- c("activity")
names(X)<- features$V2
Data <- cbind(SubjectData,X,Y)

#Extracts only the measurements on the mean and standard deviation for each measurement. 
mean_std <- features$V2[grep("mean\\(\\)|std\\(\\)",features$V2)]
Data<-subset(Data,select=c("subject","activity",as.character(mean_std)))

#Uses descriptive activity names to name the activities in the data set
activity_names <- as.character(activity[,2])
Data$activity <- activity_names[Data$activity]

#Appropriately labels the data set with descriptive variable names. 
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#From the data set above, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject.
TidyData <- Data %>% group_by(subject,activity) %>% summarise_all(funs(mean))
write.table(TidyData,"TidyData.txt",row.name = FALSE)
