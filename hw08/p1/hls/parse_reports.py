import re, os, sys

module=sys.argv[1]
clk_per=sys.argv[2]

results=open('results.csv','a')

areaScores=['MUX', 'FUNC', 'LOGIC', 'BUFFER', 'MEM', 'ROM', 'REG', 'FSM-REG', 'FSM-COMB']
areaScoreDict = {}
for cat in areaScores:
  areaScoreDict[cat]='0.0'

# date__begin
results.write(open('hls.begin').readlines()[0].strip()+',')
# date__end
results.write(open('hls').readlines()[0].strip()+',')
# module_name
results.write(module+',')
# clk_per
results.write(clk_per+',')

ram_count={'single_port':0,'simple_dual_port':0,'true_dual_port':0}
ram_bits={'single_port':0,'simple_dual_port':0,'true_dual_port':0}
counting_components=False
f=open(f"Catapult/{module}.v1/rtl.rpt")
for line in f:
  m=re.search(r"^\s*Design Total:\s+(\S+)\s+(\S+)\s+(\S+)",line)
  if m:
    # realops
    results.write(m.group(1)+',')
    # latency
    results.write(m.group(2)+',')
    # throughput
    results.write(m.group(3)+',')
    continue
  m=re.search(r"^\s*([A-Z\-]+):.*\s([0-9\.]+)\s+\([0-9\.]+%\)\s*$",line)
  if m:
    cat=m.group(1)
    asc=m.group(2)
    # print(cat,asc)
    if cat in areaScores:
      areaScoreDict[cat]=asc
    continue
  m=re.search(r"^\s*Max Delay:\s+(\S+)",line)
  if m:
    # critpath
    results.write(m.group(1)+',')
    continue
  m=re.search(r"^\s*ccs_ram_sync_(\w+)\((\d+),(\d+),(\d+),(\d+)[^\)]*\)\s+[0-9\.]+\s+[0-9\.]+\s+[0-9\.]+\s+[0-9\.]+\s+\d+\s+(\d+)",line)
  if m:
    count=int(m.group(6))
    if 'singleport' in m.group(1):
      data_width=int(m.group(3))
      depth=int(m.group(5))
      ram_count['single_port']=ram_count['single_port']+count
      ram_bits['single_port']=ram_bits['single_port']+count*data_width*depth
      continue
    if '1R1W' in m.group(1):
      data_width=int(m.group(3))
      depth=int(m.group(5))
      ram_count['simple_dual_port']=ram_count['simple_dual_port']+count
      ram_bits['simple_dual_port']=ram_bits['simple_dual_port']+count*data_width*depth
      continue
    if 'dualport' in m.group(1):
      data_width=int(m.group(3))
      depth=int(m.group(5))
      ram_count['true_dual_port']=ram_count['true_dual_port']+count
      ram_bits['true_dual_port']=ram_bits['true_dual_port']+count*data_width*depth
      continue
    else:
      raise Exception(f"ERROR: Found unrecognized RAM: ccs_ram_{m.group(1)}")
f.close()

for cat in areaScores:
  results.write(areaScoreDict[cat]+',')

results.write(f"{ram_count['single_port']},{ram_bits['single_port']},")
results.write(f"{ram_count['simple_dual_port']},{ram_bits['simple_dual_port']},")
results.write(f"{ram_count['true_dual_port']},{ram_bits['true_dual_port']}\n")

results.close()

