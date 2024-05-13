# 13.2.1 Game Attendance
alpha <- 0.05
median <- 3000
attendance <-
  c(6210,3150,2700,3012,4875,3540,6127,2581,2642,2573,2792,2800,2500,3700,6030,5437,2758,
    3490,2851,2720)
sign_value <- attendance - median
sign_value

# Determine the number of games the paid attendance above 3000 -> +ve values
sign_above <- length(sign_value[sign_value>0])

# Determine the number of games the paid attendance below 3000 -> -ve values
sign_below <- length(sign_value[sign_value<0])

# Sign Test
test_sign_result <- binom.test( x = c(sign_above , sign_below) ,alternative="two.sided")
test_sign_result

# Calculate the p Value
test_sign_result$p.value
ifelse(test_sign_result$p.value > alpha, "Fail to reject the null hypothesis", "Reject the null
hypothesis")

# 13.2.2 Lottery Ticket Sales
alpha <- 0.05
# Determine the number of days the tickets sold more than 200
above_value <- 25
# Determine the number of days the tickets sold less than 200
below_value <- 15

# Sign Test
test_result <- binom.test(x = c(25, 15),alternative="less")
test_result

# Calculate the p Value
test_result$p.value
ifelse(test_result$p.value>alpha, "Fail to reject the null hypothesis", "Reject the null hypothesis")

# 13.3.1 Lengths of Prison Sentences
alpha <- 0.05
male <- c(8, 12, 6, 14, 22, 27, 3, 2, 2, 2, 4, 6, 19, 15, 13)
female <- c(7, 5, 2, 3, 21, 26, 3, 9, 4, 0, 17, 23, 12, 11, 16)

# Wilcox Test
test_result <- wilcox.test(x=male, y=female, alternative = "two.sided", correct = FALSE)
test_result

# Calculate the p Value
test_result$p.value
ifelse(test_result$p.value>alpha, "Fail to reject the null hypothesis", "Reject the null hypothesis")

# 13.3.2 Winning Baseball Games
alpha <- 0.05
National_League <- c(89, 96, 88, 101, 90, 91, 92, 96, 108, 100, 95)
American_League <- c(108, 86, 91, 97, 100, 102, 95, 104, 95, 89, 88, 101)
test_result <- wilcox.test(x=National_League, y=American_League, alternative = "two.sided",
                           correct = FALSE)
test_result

# Calculate the p Value
test_result$p.value
ifelse(test_result$p.value>alpha, "Fail to reject the null hypothesis", "Reject the null hypothesis")

# 13.5 Mathematics Literacy Scores
alpha <- 0.05

Western_hemisphere <- data.frame(scores=c(527, 406, 474, 381,
                                          411),group=rep("Western_Hemisphere",5))
Europe <- data.frame(scores=c(520, 510, 513, 548, 496), group=rep("Europe",5))
Eastern_Asia <- data.frame(scores=c(523, 547, 547, 391, 549), group=rep("Eastern_Asia",5))
data_frame <- rbind(Western_hemisphere, Europe, Eastern_Asia)

# Kruskal-Wallis test
test_result <- kruskal.test(scores ~ group, data = data_frame)
test_result

# Calculate the p Value
test_result$p.value
ifelse(test_result$p.value > alpha, "Fail to reject the null hypothesis", "Reject the null
hypothesis")

# 13.6 Subway and Rail commuter Passangers
alpha <- 0.05
city <- c(1, 2, 3, 4, 5, 6)
subway <- c(845, 494, 425, 313, 108, 41)
rail <- c(39, 291, 142, 103, 33, 38)
data_frame <- data.frame(city=city, subway=subway, rail=rail)

#Spearman rank correlation coefficient test
test_result <- cor.test(data_frame$subway, data_frame$rail, method = "spearman")
test_result

# Calculate the p Value
test_result$p.value
ifelse(test_result$p.value>alpha, "Fail to reject the null hypothesis", "Reject the null hypothesis")

# 14.3 - 1 Prizes in Caramel Corn Boxes
experiment <- function(){
  prize_1 <- FALSE
  prize_2 <- FALSE
  prize_3 <- FALSE
  prize_4 <- FALSE
  pick <- 0
  
  while(!prize_1 | !prize_2 | !prize_3 | !prize_4){
    pick <- pick+1
    prize <- sample(1:4,1)
    if(prize==1){
      prize_1 <- TRUE
    }
    if(prize==2){
      prize_2 <- TRUE
    }
    if(prize==3){
      prize_3 <- TRUE
    }
    if(prize==4){
      prize_4 <- TRUE
    }
  }
  return(pick)
}
experiment()
num_of_experiment <- 1
trials_result <- c()
while(num_of_experiment <= 40) {
  num_of_experiment <- num_of_experiment + 1
  trial <- experiment()
  trials_result <- append(trials_result, trial)
}
mean(trials_result)
trial > mean(trials_result)

## 14.3 - 2 Lottery Winner
experiment_lottery <- function(){
  b <- FALSE
  
  i <- FALSE
  g <- FALSE
  pick <- 0
  while(!b | !i| !g){
    pick <- pick+1
    letter <- sample(1:10,1)
    if(letter<=6){
      b <- TRUE
    }
    if(letter>=7 & letter<=9){
      i <- TRUE
    }
    if(letter==10){
      g <- TRUE
    }
  }
  return(pick)
}
experiment_lottery()
num_of_lottery_experiment <- 1
trials_lottery_result <- c()
while(num_of_lottery_experiment <= 30) {
  num_of_lottery_experiment <- num_of_lottery_experiment + 1
  trial <- experiment_lottery()
  trials_lottery_result <- append(trials_lottery_result, trial)
}
trials_lottery_result
mean(trials_lottery_result)