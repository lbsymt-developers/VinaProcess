#!/usr/bin/perl

use strict;

use Getopt::Long;
use vars;

my $result;
my $help="";
my $file="filename.txt";

# difference beetween 2 axes
my $diff = 2;

my %hash_file = ();

# para guardar los archivos a analyzar ;
our @opt_file = () ;

$result = GetOptions ('file=s@',
		      "h" => \$help);

if ($help ne "" ) {
    print "$0 -file [file1] -file [file2] ...] \n";
    exit;
}

print "Use of the files @opt_file\n";


foreach $file (@opt_file) {

  print "Etude de $file\n";

  my ($xmin,$xmax,$ymin,$ymax,$zmin,$zmax) = analyse_file($file);

  #If hash empty, put it on the hash directly;
  if ( keys( %hash_file ) == 0 ) {
    print "Hash empty!!! Full it with the first one!\n";
     $hash_file{$file} = "$xmin;$xmax;$ymin;$ymax;$zmin;$zmax";
  }

  # hash not empty: to analyze...
  else {
  
    # Define if the data of the file is the same as others
    my $in_hash = 0;
    
    while ( my ($key, $value) = each(%hash_file) )  {
    # checar si existe esos valores dentro de los rangos.. 1A de tolerancia.
    #while ( my ($key, $value) = each(%hash_file) ) {
      print "En el hash: check de : $key => $value\n";
      
      my ($xhashmin,$xhashmax,$yhashmin,$yhashmax,$zhashmin,$zhashmax) = split /;/, $value;
      
      #print "String vale $xhashmin,$xhashmax,$yhashmin,$yhashmax,$zhashmin,$zhashmax\n";
      
      # Comparar los valores, y deben de ser >1A pour etre considere differents.
      
      if ( (abs($xhashmin - $xmin) <= $diff) && (abs($xhashmax - $xmax) <= $diff) 
	   && (abs($yhashmin - $ymin) <= $diff) && (abs($yhashmax - $ymax) <= $diff) 
	   && (abs($zhashmin - $zmin) <= $diff) && (abs($zhashmax - $zmax) <= $diff) ) { 
	print "\n$file  PARECIDO a $key: \n";
	print "$xmin,$xmax,$ymin,$ymax,$zmin,$zmax\n";
	print "$value\n";
	print "$file descartado por parecido existente\n";
	
	$in_hash = 1;
	last;
	
      }
    }
    print "End of the while!\n";

    # In this case, the ligand is different from the others in the hash
    if (! $in_hash ) {
      print "$file DIFFERENT: put it in the hash\n";
      $hash_file{$file} = "$xmin;$xmax;$ymin;$ymax;$zmin;$zmax";
    }   
  }

  #Printing the size of the hash..
  my $num = keys(%hash_file);
  print " Hash contient $num \n";

  print "---------------------------\n";

}

# Printing final result...

my $num = keys(%hash_file);
print " Hash contient $num \n";

while ( my ($key, $value) = each(%hash_file) ) {
  #print "hash contient : $key => $value\n";
  print "G $key :  $value\n";
}



########################################
# Analysar el archivo: obtain min and max for each axe.
# Return: Xmin Xmax Ymin Ymax Zmin Zmax

sub analyse_file {
  
  my $filename = shift();
  
  # Value default
  my $xmin = 100000;
  my $xmax = -100000;
  my $ymin = 100000;
  my $ymax = -100000;
  my $zmin = 100000;
  my $zmax = -100000;
  
  print "File a analyser: $filename\n";
  
  open (FILE,"$filename") || die "Can't open file $filename !\n";
  while (<FILE>) {

    chomp();
    #print "Ligne: $_\n";

    if ($_ =~ /^(HETATM)|(^ATOM)/) {
      #print "DETECTEE Ligne: $_\n";
      my @car = split (// , $_);
      
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
      
      # detecter les max y min
      # X---
      if ($x > $xmax) {
	$xmax = $x;
	
      }
      if ($x < $xmin) {
	$xmin = $x; 
      }
      #print "Xvalue: $xvalue, max: $xmaxRec min : $xminRec\n"; 
      
      # Y --
      if ($y > $ymax) {
	$ymax = $y;
	
      }
      if ($y < $ymin) {
	$ymin = $y;
	
      }
      #print "Yvalue: $yvalue, max: $ymaxRec min : $yminRec\n"; 
      
      # Z--
      if ($z > $zmax) {
	$zmax = $z;
	
      }
      if ($z < $zmin) {
	$zmin = $z;
	
      }
    }
    
    
  }
  close(FILE);

  print "Xvalue: [$xmin ; $xmax]\n";
  print "Yvalue: [$ymin ; $ymax]\n";
  print "Zvalue: [$zmin ; $zmax]\n";

  return ($xmin,$xmax,$ymin,$ymax,$zmin,$zmax);

}

