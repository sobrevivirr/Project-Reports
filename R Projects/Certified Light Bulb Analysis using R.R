install.packages("ggplot2")
install.packages("dplyr")
install.packages("missForest")
install.packages("mice")
library(mice)
library(ggplot2)
library(dplyr)
library(tidyr)
library(corrplot)
library(summarytools)
library(tidyselect)

#Importing the Dataset
dataset <- read.csv("C:\\Users\\Timmy\\Downloads\\ENERGY_STAR_Certified_Light_Bulbs.csv")
dataset <- read.csv("D:\\University\\ALY 6015\\Intermediate Analytics\\Project\\ENERGY_STAR_Certified_Light_Bulbs.csv")

View(dataset) 

summary(dataset)
dim(dataset)

###############cleaning#############

#Null check
sum(is.na(dataset))

column_names <- names(dataset)
print(column_names)

# Check the data types (classes) of each column
column_classes <- sapply(dataset, class)
print(column_classes)

#identify missing values
sapply(dataset, function(x) sum(is.na(x)))


#Method 4

# Create an imputation model - Random forest
subset_rf <- mice(dataset[, c("Power.Factor","Wattage.Equivalency..watts.","CBCP", "Beam.Angle","Brightness..lumens.","Efficacy..lumens.watt.", "Dims.Down.to.." , "Standby.Power.Consumption..W.")], method = "rf")

# Generate imputed datasets
imputed_subset_data_rf <- complete(subset_rf)


View(imputed_subset_data_rf)
summary(imputed_subset_data_rf)
sum(is.na(imputed_subset_data_rf))
sapply(imputed_subset_data_rf, function(x) sum(is.na(x)))


# Remove specific columns from the dataset
cleanedDataset <- dataset %>% select(-Power.Factor,-Wattage.Equivalency..watts., -CBCP,-Beam.Angle,-Brightness..lumens.,-Efficacy..lumens.watt.,-Dims.Down.to..,-Standby.Power.Consumption..W.)

combined_df <- bind_cols(cleanedDataset, imputed_subset_data_rf)

#Check new dataset with null
sum(is.na(combined_df))
sapply(combined_df, function(x) sum(is.na(x)))
View(combined_df)

bulbs <- data.frame(combined_df)

### More cleaning and data preparation for modeling
# weird entries
bulbs<- bulbs[bulbs$Dims.Down.to..!=-2000,]
bulbs<- bulbs[bulbs$Power.Factor!=10.8,]

#data type/class 
bulbs$Brightness..lumens.<- as.numeric(bulbs$Brightness..lumens.)
bulbs$CBCP<- as.numeric(bulbs$CBCP)


###############EDA################

#create barchart
ggplot(data = bulbs, aes(x = bulbs$Lamp.Category)) +
  geom_bar(fill = "lightblue") +
  labs(title = "Frequency of Bulb Category", x = "Bulb Category", y = "Frequency")

#histogram
ggplot(bulbs, aes(x = Energy.Used..watts.)) +
  geom_histogram(binwidth = 10, fill = "seagreen", color = "black") +
  labs(
    title = "Energy Used Histogram",
    x = "Energy Used (watts)",
    y = "Frequency"
  )

# Create a scatter plot
ggplot(bulbs, aes(x = Energy.Used..watts., y = Brightness..lumens., color = "red")) +
  geom_point() + 
  labs(
    title = "Energy vs. Brightness Scatter Plot",  # Title of the plot
    x = "Energy Used (watts)",  # X-axis label
    y = "Brightness (lumens)"  # Y-axis label
  )

# Bar chart
ggplot(bulbs, aes(x = Bulb.Type, y = Brightness..lumens.)) +
  geom_bar(stat = "summary", fun = "mean", fill = "skyblue") +
  labs(title = "Distribution of Bulb Brightness by Bulb Type",
       x = "Bulb Types",
       y = "Mean Brightness") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


## Corelation
correlation <- cor(bulbs[, sapply(bulbs, function(x) is.numeric(x)||is.integer(x))], use = 'pairwise')
corrplot(correlation, method = "pie", type = "upper", order = "hclust", tl.cex = 0.7, main = "Correlation plot", mar = c(2, 0, 2, 0))

# Modeling preparation
bulbs <- bulbs %>%
  mutate(decorative_lamb = as.numeric(Lamp.Category == "Decorative"),
         directional_lamb = as.numeric(Lamp.Category == "Directional"),
         omnidirectional_lamb = as.numeric(Lamp.Category == "Omnidirectional"))

bulbs <- bulbs %>%
  mutate(Decorative_bulb = as.numeric(Product.Finder.Bulb.Type == "Decorative"),
         GPR_bulb = as.numeric(Product.Finder.Bulb.Type == "General Purpose Replacement"),
         Globe_bulb = as.numeric(Product.Finder.Bulb.Type == "Globe"),
         Other_bulb = as.numeric(Product.Finder.Bulb.Type == "Other"),
         Reflector_bulb = as.numeric(Product.Finder.Bulb.Type == "Reflector (Flood/Spot)"))

bulbs$Three.Way <- ifelse(bulbs$Three.Way == "Yes", 1, 0)

bulbs$Dimmable <- ifelse(bulbs$Dimmable == "Dimmable", 1, 0)

bulbs$Lamp.Rated.for.Enclosed.Fixtures <- ifelse(bulbs$Lamp.Rated.for.Enclosed.Fixtures == "Yes", 1, 0)

bulbs$Connected.Lamp <- ifelse(bulbs$Connected.Lamp == "Yes", 1, 0)

bulbs <- bulbs %>%
  mutate(Bluetooth_con_lamp = as.numeric(grepl("Bluetooth", Communication.Method.Connected.Protocol)),
         Wi_Fi_con_lamp = as.numeric(grepl("Wi", Communication.Method.Connected.Protocol)),
         Zigbee_con_lamp = as.numeric(grepl("Zigbee", Communication.Method.Connected.Protocol)),
         Other_con_lamp = as.numeric(grepl("Other", Communication.Method.Connected.Protocol)))

bulbs <- bulbs %>%
  mutate(US_market = as.numeric(grepl("United", Markets)),
         Canada_market = as.numeric(grepl("Canada", Markets)))

## independence test
r1 <- chisq.test(bulbs$Color.Quality..CRI., bulbs$Power.Factor)
print(r1)
r2 <- chisq.test(bulbs$Connected.Lamp, bulbs$Three.Way)
print(r2)
r3 <- chisq.test(bulbs$Dimmable, bulbs$Lamp.Rated.for.Enclosed.Fixtures)
print(r3)
r4 <- chisq.test(bulbs$Bulb.Type, bulbs$Markets)
print(r4)

## ANOVA 1
#H0 <- there are no significant differences in brightness (lumens) among the different brands of the bulbs
#H1 <- there is significant differences in brightness (lumens) among the different brands of the bulbs

r5 <- aov (Brightness..lumens. ~ Brand.Name, data = bulbs)
r5
summary_r5 <- summary(r5)
p.value_r5 <- summary_r5[[1]][[1,"Pr(>F)"]]
p.value_r5

## ANOVA 2
#H0 <- there are no interaction between the brand type and bulb type on the brightness
#H1 <- there is a significant interaction between the brand type and bulb type on the brightness

r6 <- aov (Brightness..lumens. ~ Product.Finder.Bulb.Type * Brand.Name, data = bulbs)
r6
summary(r6)

## ANOVA 3
#H0 <- there are no significant differences in energy used among the different market groups
#H1 <- there is significant differences in energy used among the different markets groups

r7 <- aov (Energy.Used..watts. ~ Markets, data = bulbs)
r7
summary(r7)

# Spearman COrrelation

cor.test(bulbs$Warranty..years., bulbs$Life..hrs., method = "spearman")

##----------------------linear regression---------------------------------------##

#dependent variable: Life of bulb
#independent variables: Bulb Type, Energy used

model_bulb <- lm (bulbs$Life..hrs. ~ bulbs$Bulb.Type + bulbs$Energy.Used..watts.)
model_bulb

summary(model_bulb)

plot(model_bulb)


# Multiple Linear Regression
multiple_lm <- lm(Brightness..lumens. ~ Energy.Used..watts. + CBCP + Power.Factor, data = bulbs)

# Summary of the multiple linear regression model
summary(multiple_lm)



##--------------------------LASSO/RIDGR-------------------------##
# Load necessary libraries
library(glmnet)

set.seed(123)
predictors <- c("Wattage.Equivalency..watts.", "Brightness..lumens", "Energy.Used..watts", "Power.Factor")
sample_size <- 0.8 * nrow(bulbs)
trainIndex <- sample(x=nrow(bulbs), size=nrow(bulbs)*0.8)
trainIndex <- sample(1:nrow(bulbs), size = sample_size)
train_data <- bulbs[trainIndex,]
test_data <- bulbs[-trainIndex,]
train_x <- model.matrix(Life..hrs. ~ Wattage.Equivalency..watts. + Energy.Used..watts. + Power.Factor +CBCP+ Color.Quality..CRI.  + Dimmable+ Dims.Down.to.. + Bulb.Type + Base.Type +Special.Features+ Connected.Lamp+ Communication.Method.Connected.Protocol  , data = train_data)
View(train_x)
test_x <- model.matrix(Life..hrs.~ Wattage.Equivalency..watts. + Energy.Used..watts. + Power.Factor +CBCP+ Color.Quality..CRI.  + Dimmable+ Dims.Down.to.. + Bulb.Type + Base.Type +Special.Features+ Connected.Lamp+ Communication.Method.Connected.Protocol , data = test_data)

train_y <- train_data$Life..hrs.
test_y <- test_data$Life..hrs.

#7. Find best values of lambda
lasso_model <- cv.glmnet(train_x, train_y, alpha = 1)  # alpha = 1 for Lasso

#cv.lasso <- cv.glmnet(train_x, train_y, nfolds=10)
#lambda min
lasso_model$lambda.min
#lambda.1se
lasso_model$lambda.1se
#8. Plot the results
plot(lasso_model)

#9. fit LASSO regression model against the training set
#fit lasso regression model against the training set
model.lasso.min <- glmnet(train_x, train_y, alpha=1, lambda =
                            lasso_model$lambda.min)#lambda min
model.lasso.min
coef(model.lasso.min)
model.lasso.1se <- glmnet(train_x, train_y, alpha = 1, lambda =
                            lasso_model$lambda.1se)#lambda 1se
model.lasso.1se
coef(model.lasso.1se)##regression coefficients using lambda.1se
#10. Train set prediction of LASSO model by calculating RMSE
#lambda min
install.packages("caret")
library(caret)
pred.lasso.min <- predict(model.lasso.min, newx = train_x)
#train.lasso.rmse <- rmse(train_y, pred.lasso.min)
train.lasso.rmse <- sqrt(mean((train_y - pred.lasso.min)^2))
train.lasso.rmse
#lambda 1se
install.packages("yardstick")
library(yardstick)
pred.lasso.1se <- predict(model.lasso.1se, newx = train_x)
#train.lasso.rmse.1se <- rmse(train_y, pred.lasso.1se)
train.lasso.rmse.1se <- sqrt(mean((train_y - pred.lasso.1se)^2))
train.lasso.rmse.1se



#11. Test set prediction of lasso model using RMSE
#lambda min
pred.lasso.min.test <- predict(model.lasso.min, newx = train_x)
test.lasso.rmse.min <-sqrt(mean((train_y - pred.lasso.min.test)^2))
#test.lasso.rmse.min <- rmse(train_y, pred.lasso.min.test)

test.lasso.rmse.min
#lambda 1se
pre.lasso.1se.test <- predict(model.lasso.1se, newx = train_x)
#test.lasso.rmse.1se <- rmse(train_y, pre.lasso.1se.test)
test.lasso.rmse.1se <-sqrt(mean((train_y - pre.lasso.1se.test)^2))
test.lasso.rmse.1se


#Ridge Regression
#RIDGE REGRESSION
#2. Find best values of lambda
#lambda min: minimizes out of sample loss
#lambda 1se: largest value of lambda within 1 standard error of lambda
#Find the best lambda using cross-validation
set.seed(123)
cv.ridge <- cv.glmnet(train_x, train_y, alpha=0, nfolds=10)
#lambda min
log(cv.ridge$lambda.min)
#lambda.1se
log(cv.ridge$lambda.1se)
#3. Plot the results
par(mfrow=c(1,1))
plot(cv.ridge)
#4. Fit Ridge regression model against the training set
model.ridge.min <- glmnet(train_x, train_y, alpha = 0, lambda = cv.ridge$lambda.min) #lambda min
model.ridge.min
coef(model.ridge.min) # ridge regression coefficients for lambda min
model.ridge.1se <- glmnet(train_x, train_y, alpha = 0, lambda = cv.ridge$lambda.1se) #lambda 1se
model.ridge.1se
coef(model.ridge.1se) #ridge regression coefficients for lambda 1se
#5. Train set prediction of RIDGE model by calculating RMSE

#lamda min
pred.ridge.min <- predict(model.ridge.min, newx = train_x)
library(yardstick)
train.ridge.rmse.min <- sqrt(mean((train_y - pred.ridge.min)^2))
#train.ridge.rmse.min <- rmse(train_y, pred.ridge.min)
train.ridge.rmse.min
#lambda 1se
pred.ridge.1se <- predict(model.ridge.1se, newx = train_x)
#train.ridge.rmse.1se <- rmse(train_y, pred.ridge.1se)
train.ridge.rmse.1se <- sqrt(mean((train_y - pred.ridge.1se)^2))
train.ridge.rmse.1se
#6. Test set prediction of ridge model using RMSE
#lambda min
pred.ridge.min.test <- predict(model.ridge.min, newx = train_x)
test.ridge.rmse.min <- sqrt(mean((train_y - pred.ridge.min.test)^2))
#test.ridge.rmse.min <- rmse(train_y, pred.ridge.min.test)
test.ridge.rmse.min
#lambda 1se
pred.ridge.1se.test <- predict(model.ridge.1se, newx = train_x)
#test.ridge.rmse.1se <- rmse(train_y, pred.ridge.1se.test)
test.ridge.rmse.1se <- sqrt(mean((train_y - pred.ridge.1se.test)^2))
test.ridge.rmse.1se


# Calculate MSE for Lasso
mse.lasso <- mean((test_y - test.lasso.rmse.min)^2)

# Calculate MSE for Ridge
mse.ridge <- mean((test_y - test.ridge.rmse.min)^2)

# Calculate R-squared for Lasso
r_squared.lasso <- 1 - (sum((test_y - test.lasso.rmse.min)^2) / sum((test_y - mean(test_y))^2))

# Calculate R-squared for Ridge
r_squared.ridge <- 1 - (sum((test_y - test.ridge.rmse.min)^2) / sum((test_y - mean(test_y))^2))

# Print results
cat("Lasso MSE:", mse.lasso, "\n")
cat("Ridge MSE:", mse.ridge, "\n")

cat("lasso_r_squared:", r_squared.lasso, "\n")
cat("ridge_r_squared:", r_squared.ridge, "\n")


##--------------------------analysis in terms of time series-------------------------##
# Convert the 'Date.Certified' column to a date
column_classes <- sapply(bulbs, class)
print(column_classes)
bulbs$Date.Certified <- as.Date(bulbs$Date.Certified, format = "%m-%d-%Y")

#identify missing values
sapply(bulbs, function(x) sum(is.na(x)))


column_classes <- sapply(bulbs, class)
print(column_classes)
bulbs$Date.Certified <- as.Date(bulbs$Date.Certified, format = "%m-%d-%Y")

#identify missing values
sapply(bulbs, function(x) sum(is.na(x)))

# Create a time series plot for energy used
ggplot(data = bulbs, aes(x = Date.Certified, y = bulbs$Energy.Used..watts.)) +
  geom_line(color = "dodgerblue") +  # Line color
  geom_smooth(method = "lm", color = "red", se = FALSE) +  # Add a linear trend line
  labs(title = "Change in Energy Used Over Time",
       x = "Date Certified",
       y = "Energy Used (watts)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# Create a time series plot for life hrs
ggplot(data = bulbs, aes(x = Date.Certified, y = bulbs$Life..hrs.)) +
  geom_line(color = "dodgerblue") +  # Line color
  geom_smooth(method = "lm", color = "red", se = FALSE) +  # Add a linear trend line
  labs(title = "Change in Life of bulbs",
       x = "Date Certified",
       y = "Life in hrs") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
