from numpy import *
import matplotlib
import matplotlib.pyplot as plt

my_data = genfromtxt('csv/Pitching.csv', delimiter=',')
# IPouts hist
plt.hist((my_data[:,12]), bins=50, normed=1)
