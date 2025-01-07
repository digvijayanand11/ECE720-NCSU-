
# New LD_LIBRARY_PATH Entries
newlib=/mnt/coe/workspace/ece/ece720-common/tools/si2/oaRun_22.50p001/lib/linux_rhel50_gcc44x_64/opt
#newlib=/opt/si2/oa22.60p050/lib/linux_rhel60_64/opt

if [ -d $newlib ] && [[ ":$LD_LIBRARY_PATH:" != *":$newlib:"* ]]; then
    export LD_LIBRARY_PATH="$newlib:${LD_LIBRARY_PATH+":$LD_LIBRARY_PATH"}"
fi

export PYTHONPATH=/mnt/coe/workspace/ece/ece720-common/tools/si2/Si2oaScript-v3.4/python/:/afs/eos.ncsu.edu/lockers/research/ece/wdavis/tools/anaconda3
export LM_LICENSE_FILE=27000@ece-lic-31.ece.ncsu.edu

newdir=/mnt/coe/workspace/ece/ece720-common/tools/si2/oaRun_22.50p001/bin
#newdir=/opt/si2/oa22.60p050/bin

if [ -d $newdir ] && [[ ":$PATH:" != *":$newdir:"* ]]; then
    export PATH="$newdir:${PATH+":$PATH"}"
fi


export OA_UNSUPPORTED_PLAT=linux_rhel50_gcc44x
export OA_BIT=64


