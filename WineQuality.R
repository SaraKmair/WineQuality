---
  title: "Untitled"
author: "Sara Kmair"
date: "11/18/2019"
output: html_document
---
  
  ---
  title: "Assignment 3"
author: "Sara Kmair"
date: "11/16/2019"
output: html_document
---
  
  
  library(class)
library(gmodels)
library(Boruta)
library(corrplot)


#reading the data 

data <- read.csv("winequality-white.csv", header = T, sep = ";")
str(data) #Data has 12 variables all numeric except for quality is integer 
summary(data) #there is no missing values 
sum(is.na(data))


#The correlation between the attributes
#.00-.19 very weak
#.20-.39 weakH
#.40-.59 moderate
#.60-.79 strong
#.80-1.0 very strong


cr <-  as.matrix(cor(data))
corrplot(cr, method = "number", type = "upper",  number.cex=0.8)
#there is a very strong positive relationship between density and residual sugar 0.84
#there is a strong negative relationship between alcohol and density 0.78
#ther is a strong positive relationship between free sulfur dioxide and total sulfur dioxide 0.62
#there is a moderate negative relationship between alcohol and residual sugar 0.45
#there is a moderate positive relationship between quality and alcohol 0.44



#frequency distribution of wine quality.

index <- c(1:12)
for (i in index){
  print(hist(data[,i], xlab = colnames(data[i]), col = "gold3", main = ""))
}


#Reducing the levels of rating for quality to three levels as high, medium and low 
#if the rating is 3,4--> low
#5,6 --> medium 
#7,8,9 --> High

#converting to categorical 
data$quality[which(data$quality == 3 | data$quality == 4)] <- "low"
data$quality[which(data$quality == 5 | data$quality == 6)] <- "medium"
data$quality[which(data$quality == 7 | data$quality == 8 | data$quality == 9)] <- "high"
data$quality <-  as.factor(data$quality)
table(data$quality)
barplot(table(data$quality), col = "cyan3") #most of the wine in this dataset is medium quality 


#Normalizing the dataset between 0, 1

index <- c(1:11)
norm <- function(x){(x-min(x))/(max(x)-min(x))} #build the normalization function 

for(i in index) {
  data[,i] <- norm(data[, i])
}

summary(data) #all attributes between 0,1





#higher fixed acidity lower quality 
#higher volatile acidity lower quality 
#Higher alcohol percent shows higher quality 
#lower density higher quality 
#Higher pH higher quality 

for (i in index){
  plot(data$quality, data[, i],  xlab = colnames(data[i]), col = "cyan3")
}


#feature selection

Boruta(quality~., data = data)



#cross-validation


#building knn-model with 5-cross validation 
set.seed(100)
train.fold <- trainControl(method = "cv", number = 5)
model <- train(quality~., data = data, method = "knn", trControl = train.fold)
print(model)

#over all accuracy 0.78



#Dividing the data to training and testing groups.


set.seed(100)
index <- sample(2, nrow(data), replace = TRUE, prob = c(0.7, 0.3)) #in this case 70% of the data will go for training 
train.set <- data[index==1, ] #subsetting the training data 70% 
test.set <-data[index==2,  ] #subsetting the testing dat 30%

#another way of doing the splitting 
index <- sample(1:nrow(data), 0.7 * nrow(data))
train.set <- data[index,]
test.set  <- data[-index,]
train.set2 <- train.set2[-12]
test.set2 <- test.set[-12]
train.set.lable <- train.set$quality
test.set.lable <- test.set$quality





#building the model
knn.model <- knn(train = train.set2, test = test.set2, cl = train.set.lable, k = 3)



#Evaluating the model
tbl <- CrossTable(x = test.set.lable, y =  knn.model, prop.chisq = FALSE)
#the test set is obtained to 1470 observation
#overall accuracy 
tbl$t

acc <- sum(diag(tbl$t))/sum(tbl$t)
acc
#accuracy of the model 0.78 using 70% for training set, and 30% for testing set 





