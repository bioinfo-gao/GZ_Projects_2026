# https://posit.co/blog/three-ways-to-program-in-python-with-rstudio/

from scipy import linalg # LINear ALGebra 
# No module named 'scipy'
# sudo apt-get install python-scipy
# ===> in terminal pip install scipy

from numpy import *
arr = np.array([[1,2], [3,4]])
print(arr)

linalg.det(arr)
aArray = array([1,2,3])
aArray 
bArray = array([(1,2,3), (4,5,6)])
bArray 


from scipy import linalg # LINear ALGebra 
arr = np.array([[1,2], [3,4]])
print(arr)
linalg.det(arr)
from numpy import *
aArray = array([1,2,3])
aArray 
bArray = array([(1,2,3), (4,5,6)])
bArray 
zeros((2,2))
arange(1,5,0.5)
# bArray = array([(1,2,3), (4,5,6)])
# bArray 
cArray = array([(8,7,3), (8,5,6)])
dArray = cArray * bArray 
dArray 
#cArray = array([(8,7,3), (8,5,6)])
eArray = cArray + bArray 
eArray 
dArray > 5
#cArray = array([(8,7,3), (8,5,6)])
eArray += cArray  
eArray 
sin(eArray)
fArray= eArray.reshape(3,2)
fArray
fArray.sum()
print(fArray)
fArray.sum(axis=1)
fArray.sum(axis=0)
gArray = array([1,2,3])
hArray = array([4,5,6])
iArray = array([0,2,9])
where(iArray >2, gArray, hArray) 
def fun(x,y): return(x*y)

arr =fromfunction(fun, (7,7))
arr
help(ufunc) # the fast internal np ndarray ! Based on C laguages , for big data
np.add(gArray, hArray)
import pkgutil
[name for _, name, _ in pkgutil.iter_modules(['pandas'])]
#['modulea', 'moduleb']
# list all modules in a library
import os.path, pkgutil
#import pandas # the local pandas masked the pandas packages 
import numpy 
pkgpath = os.path.dirname(numpy.__file__)
print([name for _, name, _ in pkgutil.iter_modules([pkgpath])])
import sys
print(sys.executable) 
# import sys
# !{sys.executable} -m pip install PyGame 
# !{sys.executable} -m pip install PyOpenGL 
!{sys.executable} -m pip install pandas

#import pandas 
from pandas import Series
aSer=Series([1,2.0, 'a'])
aSer
bSer=Series(['Apple','MS', 'GOOD'], index=[1,2,3])
bSer
sindex=['Apple','MS', 'GOOD', "AMD"]
Series(bSer, index= sindex)
import pandas as pd
pd.isnull(bSer)
# DataFramets 
data = {'company': ["AXP","CSCO","BA","GOOD"], 'price': ["123.5","65.8","72.55","789.82"]}
PD2 = pd.DataFrame(data)
print(PD2)
PD2['company']
PD2.price
#PD2.iloc[2, 'company', 'price']
PD2.iloc[2]
import matplotlib.
# https://www.geeksforgeeks.org/how-to-install-yfinance-with-python-pip/
# https://medium.com/@finkai/retrieving-visualising-data-from-yahoo-finance-in-python-94f71150275b
# pip install numpy
# pip install pandas
# pip install matplotlib
#  pip install yahoo-finance
#  pip install seaborn
# !{sys.executable} -m pip install pip install yahoo-finance
# !{sys.executable} -m pip install pip install seaborn
import numpy as np
import pandas as pd
import matplotlib as plt
import yfinance as yf
import seaborn as sns
from datetime import date
#from datetime import date
help(yf)


def SaySome(name, words="Hello"):
    print(name + " ==> " + words)
SaySome("Zhen")
SaySome("Zhen", words="Hello")
SaySome(words="Hello", "Zhen" ) # positional argument follows keyword argument
SaySome(words="Hello", name= "Zhen" ) # positional argument follows keyword argument
def Test(*params, exp):
    print("参赛的长度是" + ' ==> ' , len(params) , exp)
    print("第二个参数是" + ' ==> ', params[1])
    print("exp参数是" + ' ==> ', exp)
Test(1, 'Fish', 3.14, 2.71828, 8) # Test() missing 1 required keyword-only argument: 'exp'

Test(1, 'Fish', 3.14, 2.71828, exp=8) # Test() missing 1 required keyword-only argument: 'exp'

#### local and global variable
def discount(price, rate):
    final_price = price * rate
    print( "The INSIDE Printing ==> fianl price is ", final_price)  
    return final_price  
