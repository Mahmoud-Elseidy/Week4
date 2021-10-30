setwd('C:/Coursera')

#Download the project file
fileName<- 'getdata_dataset.zip'
if (! file.exists(fileName)){
  fileURL<- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
  download.file(fileURL, fileName, method='curl')
}
if (!file.exists('UCI HAR Dataset')){
  unzip(fileName)
}

#Activity labels + Features
activityLabels<- read.table("UCI HAR Dataset/activity_labels.txt")
features<- read.table("UCI HAR Dataset/features.txt")
activityLabels[,2]<- as.character(activityLabels[,2])
features[,2]<- as.character(features[,2])
#Extract mean & SD
features_MeanSD<- grep(".*mean.*|.*std.*", features[,2])
features_MeanSD_names<- features[features_MeanSD,2]
features_MeanSD_names<- gsub("-mean", "Mean", features_MeanSD_names)
features_MeanSD_names<- gsub("-std", "Std", features_MeanSD_names)
features_MeanSD_names<- gsub("[-()]", "", features_MeanSD_names)

#Assemble test and train datasets
train<- read.table("./UCI HAR Dataset/train/X_train.txt")[,features_MeanSD]
tr_activities<- read.table("./UCI HAR Dataset/train/Y_train.txt")
tr_subjects<- read.table("./UCI HAR Dataset/train/subject_train.txt")
train_all<- cbind(tr_subjects, tr_activities,train)

test<- read.table("./UCI HAR Dataset/test/X_test.txt")[,features_MeanSD]
test_activities<- read.table("./UCI HAR Dataset/test/Y_test.txt")
test_subjects<- read.table("./UCI HAR Dataset/test/subject_test.txt")
test_all<- cbind(test_subjects, test_activities,test)

# Merge training and test data sets
combined_data<- rbind(train_all, test_all)
colnames(combined_data)<- c("Subject", "Activity", features_MeanSD_names)

#Label and factorize activity and Subjects
combined_data$Activity<- factor(combined_data$Activity, levels=activityLabels[,1], labels = activityLabels[,2])
combined_data$Subject<- factor(combined_data$Subject)
#Reshape the data
library(reshape2)
library(dplyr)
combined_2<- melt(combined_data, id= c("Subject", "Activity"))
FinalData <- dcast(combined_2, Subject + Activity ~ variable, mean)

#Write the data table
write.table(FinalData, "tidy.txt")


