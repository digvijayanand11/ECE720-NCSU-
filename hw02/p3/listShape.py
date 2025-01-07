
import oa, sys
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

techlib = oa.oaLib.open("NCSU_TechLib_FreePDK15","/mnt/designkits/ncsu/FreePDK15/cdslib/NCSU_TechLib_FreePDK15")
tech = oa.oaTech.open(techlib)
lib = oa.oaLib.open("newlib","./newlib")
des = oa.oaDesign.open("newlib",sys.argv[1],"layout","r")
blk = des.getTopBlock()
ns = oa.oaNativeNS()
pst=oa.oaType('PathSeg')
p1=oa.oaPoint()
p2=oa.oaPoint()
netlength={}
for shape in blk.getShapes():
  ln=shape.getLayerNum()
  ln=oa.oaLayer.find(tech,ln)
  if ln:
    ln=ln.getName()
  else:
    ln='(none)'
  pn=shape.getPurposeNum()
  pn=oa.oaPurpose.find(tech,pn)
  pn=pn.getName()
  nn=shape.getNet()
  if nn:
    nn=nn.getName()
  else:
    nn='None'
  t=shape.getType()
  if t==pst:
    shape.getPoints(p1,p2)
    pathlen=(abs(p1[0]-p2[0])+abs(p1[1]-p2[1]))/2000
    if nn in netlength:
      netlength[nn]+=pathlen
    else:
      netlength[nn]=pathlen
    t=t.getName()
#    print(f"{t} ({ln} {pn}) {nn} ({p1[0]/2000} {p1[1]/2000}) ({p2[0]/2000} {p2[1]/2000})")
  else:
    t=t.getName()
#    print(f"{t} ({ln} {pn}) {nn}")

total=0
x_nn = []
length_per_nn = []

for nn in netlength:
  if nn not in ('VDD','VSS'):
    length_per_nn.append(netlength[nn])
    x_nn.append(nn)
    total+=netlength[nn]

df = pd.DataFrame(list(netlength.items()), columns=['NetName', 'NetLength'])
df_cleaned = df[~df['NetName'].isin(['VDD', 'VSS'])]

#print(df.shape)

#######################################
#
# define and save plot
#
#######################################

ax = df_cleaned['NetLength'].plot(kind='hist', bins=128, color='blue', edgecolor='black', figsize=(12, 9))

ax.set_xlim(0, 128)

ax.set_xlabel('Net Length', fontweight='bold', fontsize=18)
ax.set_ylabel('Frequency', fontweight='bold', fontsize=18)
ax.set_title('Histogram of Net Length', fontweight='bold', fontsize=24)
ax.tick_params(axis='x', labelsize=14)
ax.tick_params(axis='y', labelsize=14)

for label in ax.get_xticklabels():
    label.set_fontweight('bold')
for label in ax.get_yticklabels():
    label.set_fontweight('bold')

filename = f'netlength_histogram_pandas.png'
plt.savefig(filename, dpi=300)


#######################################
#
# print output for Q3:
#
#######################################

print('##########################')
print()
print('Q3:')
print()
print('based on Listshape.py:')
print(f'Total length\t\t\t= {total:.4f} microns')

# calculate the avg cell length
num_of_total_cells = 40197
total_per_cell = total/num_of_total_cells
print(f'L_avg\t\t\t\t= {total_per_cell:.4f}  microns')


#######################################
#
# define Donath method:
#
#######################################

def L_avg(C, p, d_avg):
    if p != 1/2:
        term1 = 7 * (C**(p-1/2) - 1) / (4**(p-1/2) - 1)
    else:
        term1 = 7 * np.log2(C) / 2
        
    term2 = (1 - C**(p-3/2)) / (1 - 4**(p-3/2))
    term3 = (1 - 4**(p-1)) / (1 - C**(p-1))

    L_avg = d_avg * (2/9) * (term1 - term2) * term3

    return L_avg


#######################################
#
# use given values for d_avg:
#
#######################################

corearea = 152.64*152.064
C = 40197

d_avg = np.sqrt(corearea/C)
p1 = 0.5
p2 = 0.75

result1 = L_avg(C, p1, d_avg)
result2 = L_avg(C, p2, d_avg)


#######################################
#
# Output for Q3 using Donath's method
#
#######################################

print(f'\n\nDonath\'s method for wirelength:')
print(f"L_avg (with p = 1/2)\t\t= {result1:.4f} microns")
print(f"L_avg (with p = 3/4)\t\t= {result2:.4f} microns ")
print()
print('##########################')


