# VinaProcess
Automatized Docking Algorithm

## Dependences
* Linux OS
* Perl
* Python

## Installation

Extract file vinaprocess-0.04.tgz

```
gunzip /Directory/of/the/vinaprocess/home/vinaprocess-0.04.tgz
tar -vxf /Directory/of/the/vinaprocess/home/vinaprocess-0.04.tar
```

set variable VINAPROCESS to the root of the extracted directory 

```
export VINAPROCESS=/Directory/of/the/vinaprocess/home
```

## Usage

In a directory with 2 coumpounds to study (eg ligand.pdb and receptor.pdb)in pdb format file,

the programm will create a directory of the format YYYYMMDDHHMM from the date.

Inside, you will obtain the resulting coumpound in format of "energy-receptor-lingand-X-Y-Z". 

It's not obligatory to have the 2 files of coumpound inside the directory of work.


##### To run on a single thread:

```
$VINAPROCESS/vina-process.pl -r receptor.pdb -l ligand.pdb 
```

##### For more help:

```
$VINAPROCESS/vina-process.pl -h
```


 ##### Options:
  
    -r : Receptor file (pdb format)
    
    -l : Ligand file (pdb format)
    
    -c : Cores number (by default 1)
    
    -h : help
 
## Developers

* M. en MM. Nidia Beltrán Hernández 1
* M. en C. Jerome Verleyen 2
* Dr. Fidel Alejandro Sánchez Flores 2
* Dr. Heriberto Manuel Rivera 1
 
1 Laboratorio Biología de Sistemas y Medicina Translacional, Facultad de Nutrición-Universidad Autónoma del Estado de Morelos. 
2 Unidad Universitaria de Secuenciación Masiva y Apoyo Bioinformático, Instituto de Biotecnología-Universidad Nacional Autónoma de México

