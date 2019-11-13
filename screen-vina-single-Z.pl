#!/usr/bin/env perl

# Skeleton para programas de perl
use strict;

use Getopt::Long;

use Cwd;

my $result;
my $help = "";

# Defining the rpath to the application: VINAPROCESS

my $vinabin = $ENV{"VINAPROCESS"};
$vinabin .= "/bin/vina";

# Se vana a generar archivos de conf para los jobs.

my $baseconfname = "conf_vina.txt";

# Name of the script.
my $scriptname = "script-vina-Z.sh";

my $receptorfilename = "receptor.pdbqt";
my $ligandfilename = "ligand.pdbqt";

# 4 cores default..
my $numcores = 4;

# To output the log of the study.
my $logFile = "logFile.txt";

my $xminRec = 100000;
my $xmaxRec = -100000;
my $yminRec = 100000;
my $ymaxRec = -100000;
my $zminRec = 100000;
my $zmaxRec = -100000;

my $xminLig = 100000;
my $xmaxLig = -100000;
my $yminLig = 100000;
my $ymaxLig = -100000;
my $zminLig = 100000;
my $zmaxLig = -100000;

# Suponemos que el radio de un atomo es de 1 A, asi que poniendo 2 mas, estamos bien :-)
my $atomsize = 2;

$result = GetOptions ("r=s" => \$receptorfilename,
		      "l=s" => \$ligandfilename,
		      "c=i" => \$numcores,
		      "g=s" => \$logFile,
		      "h" => \$help);

# -h => help!
if ($help ne "" ) {
    print "$0 -r [receptor file] -l [ligand file] -c [# thread] -g [Appended log file]\n";
    exit;
}

# Information.
print "\n";
print "Init of $0\n";
print "---------------------------------------\n";

# Open the receptor file
open (REC , "$receptorfilename") || die "No se pudo abrir $receptorfilename!\n";

while (<REC>) {
  
  chomp();
  # selectionamos las lineas con ATOM al inicio!
  # ATOM   3018  O   GLY D 123     156.117 100.141 -40.203  1.00 53.68    -0.268 OA

  # Definition of the pdb file: http://www.wwpdb.org/documentation/format33/sect9.html#ATOM
  #31 - 38        Real(8.3)     x            Orthogonal coordinates for X in Angstroms.
  #39 - 46        Real(8.3)     y            Orthogonal coordinates for Y in Angstroms.
  #47 - 54        Real(8.3)     z            Orthogonal coordinates for Z in Angstroms.

  if ($_ =~ /(^ATOM)|(^HETATM)/)  {
    # Extract the value of X,y and Z

    my ($xvalue,$yvalue,$zvalue) = getxyz($_);
    
    # X---
    if ($xvalue > $xmaxRec) {
      $xmaxRec = $xvalue;
      
    }
    if ($xvalue < $xminRec) {
      $xminRec = $xvalue; 
    }
    #print "Xvalue: $xvalue, max: $xmaxRec min : $xminRec\n"; 
   
    # Y --
    if ($yvalue > $ymaxRec) {
      $ymaxRec = $yvalue;
      
    }
    if ($yvalue < $yminRec) {
      $yminRec = $yvalue;
      
    }
    #print "Yvalue: $yvalue, max: $ymaxRec min : $yminRec\n"; 

    # Z--
    if ($zvalue > $zmaxRec) {
      $zmaxRec = $zvalue;
      
    }
    if ($zvalue < $zminRec) {
      $zminRec = $zvalue;
      
    }
    #print "Zvalue: $zvalue, max: $zmaxRec min : $zminRec\n"; 
    
  }
}
close(REC);
print "acabamos con el recepotor!\n";

# abrir el archivo del ligando

open (LIG , "$ligandfilename") || die "No se pudo abrir $ligandfilename!\n";

while (<LIG>) {
  
  chomp();
  # selectionamos las lineas con ATOM al inicio!
  # ATOM   3018  O   GLY D 123     156.117 100.141 -40.203  1.00 53.68    -0.268 OA

  # Con HEATATM, se toma de los numeros 5,6,7
  # con ATM, se toma 6,7,8

  if ($_ =~ /(^ATOM)|(^HETATM)/ )  {

    my ($rankx,$ranky,$rankz) = getxyz($_);

    #print "Linea con $_: rang de $rankx,$ranky,$rankz\n";

    # Selecionamos el 6to, 7to, 8vo rango
    
    # X---
    if ($rankx > $xmaxLig) {
      $xmaxLig = $rankx;
      #print "Xmax trouve: $xmaxLig\n";
    }
    if ( $rankx < $xminLig) {
      $xminLig = $rankx;
      #print "Xmin trouve : $xminLig\n";
    }

    # Y---
    if ($ranky > $ymaxLig) {
      $ymaxLig = $ranky;
      #print "Ymax trouve: $ymaxLig\n";
    }
    if ($ranky < $yminLig) {
      $yminLig = $ranky;
      #print "Ymin trouve : $yminLig\n";
    }

    # Z---
    if ($rankz > $zmaxLig) {
      $zmaxLig = $rankz;
      #print "Lig Zmax trouve: $zmaxLig\n";
    }
    if ($rankz < $zminLig) {
      $zminLig = $rankz;
      #print "Lig Zmin trouve : $zminLig\n";
    }

    
    
  }
}
close(LIG);


# Anadir el radio de atomos
$xminRec = $xminRec - $atomsize;
$yminRec = $yminRec - $atomsize;
$zminRec = $zminRec - $atomsize;

$xmaxRec = $xmaxRec + $atomsize;
$ymaxRec = $ymaxRec + $atomsize;
$zmaxRec = $zmaxRec + $atomsize;

my $xmoyRec = ($xmaxRec + $xminRec) / 2;
my $xradRec = $xmaxRec - $xmoyRec;

my $ymoyRec = ($ymaxRec + $yminRec) / 2;
my $yradRec = $ymaxRec - $ymoyRec;

my $zmoyRec = ($zmaxRec + $zminRec) / 2;
my $zradRec = $zmaxRec - $zmoyRec;


my $ligLarge = sqrt(($xmaxLig-$xminLig)**2 +($ymaxLig-$yminLig)**2 + ($zmaxLig-$zminLig)**2) ;

print "------------------\n";

# Write the simple conf file.

open (CONF ,">$baseconfname");

print CONF "receptor = $receptorfilename\n";
print CONF "ligand = $ligandfilename \n";

print CONF "\n";
print CONF "exhaustiveness = 95\n";

close(CONF);

# Axe Z ..
my $zmin = int($zminRec) ;
my $zmax = int($zmaxRec) + 1;

my $xmin = int($xminRec) ;
my $xmax = int($xmaxRec) + 1;

my $ymin = int($yminRec) ;
my $ymax = int($ymaxRec) +1;

# Doble del tamaño del ligando.
my $maxLarge = int($ligLarge)*2 +1;

print "Zmin: $zminRec .... Integer: $zmin \n";
print "Zmax: $zmaxRec .... Integer: $zmax \n";

print "Xmin: $xminRec .... Integer: $xmin \n";
print "Xmax: $xmaxRec .... Integer: $xmax \n";

print "Ymin: $yminRec .... Integer: $ymin \n";
print "Ymax: $ymaxRec .... Integer: $ymax \n";

print "---------------------------------------\n";

print "Ligand large: $ligLarge .... Integer: $maxLarge\n";

print "---------------------------------------\n";

# Para Log.

open (LOG, ">>$logFile");

print LOG "receptor = $receptorfilename:\n\n";

print LOG "X: [$xminRec ; $xmaxRec]\n";
print LOG "Y: [$yminRec ; $ymaxRec]\n";
print LOG "Z: [$zminRec ; $zmaxRec]\n";

print LOG "\n";

print LOG "Ligand: $ligandfilename:\n\n";

print LOG "X: [$xminLig ; $xmaxLig]\n";
print LOG "Y: [$yminLig ; $ymaxLig]\n";
print LOG "Z: [$zminLig ; $zmaxLig]\n";

print LOG "\nMax Large Ligand: $ligLarge\n";

print LOG "\n";
print LOG "---------------------------\n";
print LOG " Size used:\n\n";

print LOG "X : [ $xmin ; $xmax ] \n";
print LOG "Y : [ $ymin ; $ymax ] \n";
print LOG "Z : [ $zmin ; $zmax ] \n";

print LOG "Ligand large: $maxLarge\n";

close(LOG);

print "Escritura de los archivos $baseconfname \n";

# Ahora, debemos cortar el cubo segun z en trozos de largo maxLarge, avanzando de cada medio maxLarge.

my $Zindice = $zmin;
my $Xindice = $xmin;
my $Yindice = $ymin;

# Por equivocacion, crei que size_z era el rayo!!! por eso lo dejo tal cual aqui.
my $radio = $maxLarge/2;
my $Znum = 0;

open (LIST_Z , ">liste-conf-Z");

# Axe Z
while ($Zindice < $zmax ) {
  #print "Entramos en Z..: $Znum\n";
  my $zinit = $Zindice;
  my $zfin = $Zindice + $maxLarge;
  
  
  # avanzamos medio largo.
  $Zindice += $radio;
  
  # Axe X 
  $Xindice = ($xmax + $xmin)/2;
  # El radio es finalemente el tamaño total!
  my $size_x = ($xmax - $xmin);
  
  # Axe Y 
  $Yindice = ($ymax + $ymin)/2;
  # El radio es finalemente el tamaño total!
  my $size_y = ($ymax - $ymin);
  
  $Znum += 1;
      
  #print "Conf para : Z [$zinit - $zfin] Z centro: $Zindice, rayon : $radio\n";
  
  # Para archivo conf..

  # Ligne of the list file:
  # center_x;size_x;center_y;center_y;center_z;size_z 

  print LIST_Z "$Znum;$Xindice;$size_x;$Yindice;$size_y;$Zindice;$maxLarge\n";

  #print "-------------------------------------\n";
 
  # Preparation of the future step: x parts and y part...
  # For the X axe, define the conf -Z-X

  open (LIST_Z_X,">liste-conf-ZX-$Znum");
  
  $Xindice = $xmin;
  my $Xnum=0;

  while ($Xindice < $xmax) { 
    #print "Entramos en X..: $Xnum\n";
    
    $Yindice = $ymin;
    $Xnum += 1;

    my $xinit = $Xindice;
    my $xfin = $Xindice + $maxLarge;
    $Xindice += $radio;

    $Yindice = ($ymax + $ymin)/2;


    # print "center_x = $Xindice \n";
    # print "size_x = $radio \n";

    print LIST_Z_X "$Znum;$Xnum;$Xindice;$maxLarge;$Yindice;$size_y;$Zindice;$maxLarge\n";

    # Preparation of the future step: Y parts
    # For the X axe, define the conf -ZXY

    open (LISTZXY,">liste-conf-ZXY-$Znum-$Xnum");
    $Yindice = $ymin;
    my $Ynum=0;

    # open (CONF,">$baseconfname$Znum-$Xnum");

    while ($Yindice < $ymax) { 
      #print "Entramos en Y..: $Ynum\n";
      
      $Ynum += 1;
   
      my $yinit = $Yindice;
      my $yfin = $Yindice + $maxLarge;
      $Yindice += $radio;

      print LISTZXY "$Znum;$Xnum;$Ynum;$Xindice;$maxLarge;$Yindice;$maxLarge;$Zindice;$maxLarge\n";

    }

    close(LISTZXY);

  }
  close(LIST_Z_X);
}

close(LIST_Z);

close (OUTFILE);


print "Hay que generar $Znum veces script \n";

# # Detectamos la ubicacion actual, para definir la ruta completa de los archivos pdbqt y las salidas

# my $vinabin = $ENV{"VINAPROCESS"};
# $vinabin .= "/bin/vina";

open (SCRIPT,">$scriptname");

print SCRIPT "#!/bin/bash \n\n";

print SCRIPT "# Should run $Znum   \n";


print SCRIPT "# Extract x,y,z value\n";
print SCRIPT "LISTFILE=liste-conf-Z \n";

print SCRIPT "for ((id=1;id<=$Znum;id++)) \n";
print SCRIPT "do \n";


print SCRIPT "   echo \"Running part Z \$id / $Znum \" \n";
print SCRIPT "   SEED=\$(cat \$LISTFILE | head -n \$id | tail -n 1) \n";
print SCRIPT "   xc=\$(echo \$SEED |cut -d \"\;\" -f2) \n";
print SCRIPT "   xs=\$(echo \$SEED |cut -d \"\;\" -f3) \n";
print SCRIPT "   yc=\$(echo \$SEED |cut -d \"\;\" -f4) \n";
print SCRIPT "   ys=\$(echo \$SEED |cut -d \"\;\" -f5) \n";
print SCRIPT "   zc=\$(echo \$SEED |cut -d \"\;\" -f6) \n";
print SCRIPT "   zs=\$(echo \$SEED |cut -d \"\;\" -f7) \n";


print SCRIPT "#    Correr vina \n";
#print SCRIPT "   time $cwd/../bin/vina --cpu $numcores --config $cwd/$baseconfname ";
print SCRIPT "   $vinabin --cpu $numcores --config $baseconfname ";
print SCRIPT "--center_x \$xc --size_x \$xs ";
print SCRIPT "--center_y \$yc --size_y \$ys ";
print SCRIPT "--center_z \$zc --size_z \$zs ";
print SCRIPT "--out  OutVina-Z-\$id  >>$logFile 2>>$logFile ";

print SCRIPT "\n";
print SCRIPT "done \n";
print SCRIPT "echo \"finished..\" \n";

print SCRIPT "echo \"END\" \n";

close(SCRIPT);

print "ScriptName:$scriptname \n";


##################################################################
# Return a triple x,y,z of a line of pdb format.

sub getxyz {
  my $line = $_;
  #print "chaine recu: $line\n";
  my @car = split (// , $line);
  
  # my @ligne = @_;
  # my @line = split (// , @ligne);
  # #my @ligne = split (// , @_);
  my ($x,$y,$z) = (0,0,0);

  # Extract X
  my $string="";
  
  for (my $i = 30; $i <38; $i++) {
    $string .= $car[$i];
  }
  
  $x = $string + 0.0;
  
  # Extract Y:
  $string="";
  
  for (my $i = 38; $i <46; $i++) {
    #print "$ligne[$i]";
    $string .= $car[$i];
  }
  $y = $string + 0.0;
  
  # to transform a sting in a number.
  my $yvalue = $string + 0.0;
  
  # Extract Z:
  $string = "";
  for (my $i = 46; $i <54; $i++) {
    #print "$car[$i]";
    $string .= $car[$i];
  }

  # to transform a sting in a number.
  $z = $string + 0.0;
  
  return ($x,$y,$z);
}
	  
