: .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH
export PATH=$PATH:/research_jude/rgs01_jude/applications/hpcf/apps/homer/install/4.5/bin
export PATH=$PATH:/research_jude/rgs01_jude/groups/yu3grp/projects/scRNASeq/yu3grp/qpan/Software/weblogo
export PATH=/research_jude/rgs01_jude/groups/yu3grp/projects/scRNASeq/yu3grp/qpan/Software/R/v3.6.1/bin:$PATH
export PATH=/research_jude/rgs01_jude/groups/yu3grp/projects/software_JY/yu3grp/conda_env/yulab_env/lib/python3.6/site-packages/SJARACNe:$PATH
export PATH=/research_jude/rgs01_jude/groups/yu3grp/projects/scRNASeq/yu3grp/qpan/Software/conda3.6.1/Software/bedtools2/bin:$PATH

export CACHEHOME=$HOME/cache

export LD_LIBRARY_PATH=/lib
export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/research_jude/rgs01_jude/groups/yu3grp/projects/scRNASeq/yu3grp/qpan/Software/gsl-2.5/lib:$LD_LIBRARY_PATH
