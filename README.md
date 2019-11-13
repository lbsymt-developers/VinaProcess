# VinaProcess
Automatized Docking Algorithm

# Dependences
Linux OS

Python

# Installation

Extract file vinaprocess-0.04.tgz

gunzip /Directory/of/the/vivaprocess/home/vinaprocess-0.04.tgz

tar -vxf /Directory/of/the/vivaprocess/home/vinaprocess-0.04.tar



set variable VINAPROCESS to the root of the extracted directory 

export VINAPROCESS=/Directory/of/the/vivaprocess/home

# Usage

In a directory with 2 coumpounds to study (eg ligand.pdb and receptor.pdb)in pdb format file,

the programm will create a directory of the format YYYYMMDDHHMM from the date.

Inside, you will obtain the resulting coumpound in format of "energy-receptor-lingand-X-Y-Z". 

It's not obligatory to have the 2 files of coumpound inside the directory of work.


To run on a single thread:

$VINAPROCESS/vina-process.pl -r receptor.pdb -l ligand.pdb 


To have more help:

$VINAPROCESS/vina-process.pl -h


  OPTIONS:
  
    -r : Receptor file (pdb format)
    
    -l : Ligand file (pdb format)
    
    -c : Cores number (by default 1)
    
    -h : help
