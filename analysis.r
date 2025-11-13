# Load libraries
library(tidyverse)
library(GGally)
library(caret)
library(rpart)
library(rpart.plot)
library(knitr)
library(formatR)
library(class)

# -----------------------------
# Load and preprocess data
# -----------------------------
weatherAUS <- read_csv("weatherAUS.csv") %>% drop_na()
weatherAUS$RainTomorrow <- ifelse(weatherAUS$RainTomorrow == "Yes", 1, 0)
weatherAUS$RainToday <- ifelse(weatherAUS$RainToday == "Yes", 1, 0)
filtered_weatherAUS <- weatherAUS %>%
  filter(RainToday == 1) %>%
  mutate(Rainfall = log(Rainfall))

# -----------------------------
# Train/test split
# -----------------------------
set.seed(123)
trainIndex <- createDataPartition(weatherAUS$Rainfall, p = 0.8, list = FALSE)
train <- weatherAUS[trainIndex, ]
test  <- weatherAUS[-trainIndex, ]

# Check for missing values
sapply(filtered_weatherAUS, function(x) sum(is.na(x)))

# -----------------------------
# Exploratory Data Analysis
# -----------------------------
ggpairs(filtered_weatherAUS,
        columns = c(5, 6, 14, 16),
        lower = list(continuous = wrap("points", color = "#36445f", alpha = 0.3)),
        diag = list(continuous = wrap("densityDiag", fill = "#36445f", alpha = 0.3)),
        upper = list(continuous = wrap("cor", color = "#36445f"))) +
  theme(text = element_text(family = "serif"))

# -----------------------------
# Simple Linear Regression
# -----------------------------
model <- lm(Rainfall ~ Humidity9am, data = train)
ggplot(train, aes(Humidity9am, Rainfall)) +
  geom_point(alpha = 0.5, color='#36445f') +
  geom_smooth(method = "lm", color = "#fbbc53") +
  theme(text = element_text(family = "serif"))

model3 <- lm(Rainfall ~ Humidity9am + MaxTemp + Sunshine + Evaporation, data = filtered_weatherAUS)

# -----------------------------
# Regression Tree
# -----------------------------
trctrl <- trainControl(method = "repeatedcv", number = 5, repeats = 5)
caretTree <- train(Rainfall ~ Humidity9am + MaxTemp + Sunshine + Evaporation,
                   data = weatherAUS,
                   method = "rpart",
                   trControl=trctrl,
                   tuneGrid = expand.grid(cp=seq(0.005, 0.02, 0.001)))
rpart.plot(caretTree$finalModel, box.col = "#c9d6f0ff", tweak = 1.2, cex = 0.8, family = "serif")

# -----------------------------
# RMSE of Models
# -----------------------------
RMSE <- function(actual, predicted) sqrt(mean((actual - predicted)^2))
pred_lm <- predict(model, newdata = test)
pred_plm <- predict(model3, newdata = test)
pred_tree <- predict(caretTree, newdata = test)
RMSE(test$Rainfall, pred_lm)
RMSE(test$Rainfall, pred_plm)
RMSE(test$Rainfall, pred_tree)

# -----------------------------
# Classification Preparation (KNN)
# -----------------------------
weatherNorm <- data.frame(scale(weatherAUS[, c(5, 6, 7, 14, 16, 22)]), Outcome = weatherAUS$RainTomorrow)
weather0 <- weatherNorm %>% filter(Outcome == 0) %>% sample_n(20000)
weather1 <- weatherNorm %>% filter(Outcome == 1)
sample0 <- sample(1:20000, 20000*0.7)
sample1 <- sample(1:12427, 12427*0.7)
trainStrat <- rbind(weather0[sample0, ], weather1[sample1, ])
testStrat <- rbind(weather0[-sample0, ], weather1[-sample1, ])
trainFea <- trainStrat %>% select(-Outcome)
testFea <- testStrat %>% select(-Outcome)
trainOut <- trainStrat$Outcome
testOut <- testStrat$Outcome

# -----------------------------
# KNN Classification
# -----------------------------
set.seed(1)
knn.pred <- knn(train = trainFea, test = testFea, cl = trainOut, k = 25)
cm <- table(knn.pred, testOut)
mean(knn.pred == testOut)

# Find optimal k
set.seed(123)
accuracy <- sapply(1:30, function(i) {
  knn(train = trainFea, test = testFea, cl = trainOut, k = i) %>% {mean(. == testOut)}
})
ggplot(data.frame(accuracy), aes(x = 1:30, y = accuracy)) +
  geom_line(color = "blue") +
  xlab("Neighborhood Size")
best_k <- which.max(accuracy)

# -----------------------------
# Classification Tree
# -----------------------------
classTree <- rpart(Outcome ~ ., data = trainStrat, method = "class")
rpart.plot(classTree)
plotcp(classTree)
printcp(classTree)
minCP <- classTree$cptable[which.min(classTree$cptable[, "xerror"]), "CP"]
prune_classTree <- prune(classTree, cp = minCP)
rpart.plot(prune_classTree, box.col = "#c9d6f0ff", tweak = 1.2, cex = 0.8, family = "serif")

predTree1 <- predict(classTree, testStrat, type="class")
predTree2 <- predict(prune_classTree, testStrat, type="class")
cmTree1 <- table(testStrat$Outcome, predTree1)
cmTree2 <- table(testStrat$Outcome, predTree2)
mean(testStrat$Outcome == predTree1)
mean(testStrat$Outcome == predTree2)
