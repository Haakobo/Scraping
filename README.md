#House Price Modeling

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.pyplot import figure
import seaborn as sns #for heatmap
from scipy import stats
from sklearn import linear_model
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import cross_val_score
from sklearn.linear_model import Ridge
from sklearn.linear_model import Lasso
from sklearn.metrics import mean_squared_error as MSE

data=pd.read_csv("AUA_RealEstateData.csv")
data[['Date','Quarter']] = data['Quarter'].str.split('-',expand=True)
data.isnull().sum()
data.drop("N",
          axis=1, #=0 if you wnat to dorp row, and =1 if you drop column
          inplace=True) #use this to save changes in the data

data.drop("Address",
          axis=1, #=0 if you wnat to dorp row, and =1 if you drop column
          inplace=True) #use this to save changes in the data

data.drop("BuidType",
          axis=1, #=0 if you wnat to dorp row, and =1 if you drop column
          inplace=True) #use this to save changes in the data

data.drop("PropCondition",
          axis=1, #=0 if you wnat to dorp row, and =1 if you drop column
          inplace=True)

data.drop("Street",
          axis=1, #=0 if you wnat to dorp row, and =1 if you drop column
          inplace=True) #use this to save changes in the data
          
 data.drop('Month',
         axis=1,inplace=True)

data.drop('Room', axis=1,inplace=True)

data.dropna(inplace=True)

#let's visualise the distribution of price
sns.distplot(data.Price_usd)
plt.show()

plt.hist(data.Price_usd)
plt.show()

plt.hist(np.log(data.Price_usd),bins=100)
plt.show()

#observe outliers visually
for i in data.select_dtypes(exclude="object").columns:
  plt.boxplot(data[i])
  plt.title(i)
  plt.show()
  
#as the names of newly created dummy variables contain space and "-", let's replace with underscore ("_")
data.columns=data.columns.str.replace(" ","_")
data.columns=data.columns.str.replace(".","_")
data.columns=data.columns.str.replace("-","_")

plt.hist(data.Area_sq_metre)
plt.show()

#let's convert categorical variables in the dataset into dummy variables
data=pd.get_dummies(data,drop_first=True)
data.head()

#create a dataframe consisting of logarithmic price variable
d=data["Price_usd"].apply(np.log)

X=data.drop("Price_usd",axis=1).values
Y=d.values

#make a shape of an array
X.reshape(-1,1)
Y.reshape(-1,1)

print(data.Price_usd.value_counts()/len(data)*100)

print(d.value_counts()/len(data)*100)

#split into train test
x_train,x_test,y_train,y_test=train_test_split(X,Y,test_size=0.2,random_state=42)

reg=LinearRegression(fit_intercept=True)

reg.fit(x_train,y_train)

y_pred_tr=reg.predict(x_train)

#RMSE and R^2
print("R^2: {}".format(reg.score(x_train, y_train)))
rmse = np.sqrt(mean_squared_error(y_train, y_pred_tr))
print("RMSE: {}".format(rmse))

reg.fit(x_test,y_test)

y_pred_ts=reg.predict(x_test)

#RMSE and R^2
print("R^2: {}".format(reg.score(x_test, y_test)))
rmse = np.sqrt(mean_squared_error(y_test, y_pred_ts))
print("RMSE: {}".format(rmse))

#Cross-validation
cv=cross_val_score(reg,X,Y,cv=3)
print(cv)

np.mean(cv)

ridge=Ridge(alpha=0.011,normalize=True)

ridge.fit(x_train, y_train)

ridge_pred=ridge.predict(x_test)
ridge.score(x_test,y_test)

lasso.fit(x_train,y_train)
lasso_pred=lasso.predict(x_test)

#R-squared
lasso.score(x_test,y_test)

#name of the columns except y-variable
column_names=data.drop('Price_usd',axis=1).columns

lasso=Lasso(alpha=0.1)

#coefficients after lasso regression
lasso_coef=lasso.fit(X,Y).coef_

#From the plot the most important variables are District_center and Area_sq_metre
plt.plot(range(len(column_names)),lasso_coef)
x=plt.xticks(range(len(column_names)),column_names,rotation=90)
y=plt.ylabel('coefficients')
plt.margins(0.000000000000000000001)
plt.show()







          
          
          
