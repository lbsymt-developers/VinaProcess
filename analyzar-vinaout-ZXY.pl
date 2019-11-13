#!/usr/bin/env perl

# Analyzarlos archivos Log-ZXY-$Z-$X-$Y
# Sacar la informacion de la afinidad:

# Ejemplo de salida:

# MODEL 1
# REMARK VINA RESULT:      -2.9      0.000      0.000
# REMARK  4 active torsions:
# REMARK  status: ('A' for Active; 'I' for Inactive)
# REMARK    1  A    between atoms: N_1  and  C_2 
# REMARK    2  A    between atoms: N_1  and  C_3 
# REMARK    3  A    between atoms: N_1  and  C_4 

use strict;

use Getopt::Long;

use Cwd;

my $result;
my $help = "";
my @vacio;

# cutoff percent of max energy
my $percent = 90;

my %listfile =();

# Se van a generar archivos de conf para los jobs.
my $basefilename = "OutVina-ZXY-";

$result = GetOptions ("p=i" => \$percent,
		      "h" => \$help);

# -h => help!
if ($help ne "" ) {
    print "$0  \n";
    exit;
}

# Detectar los archivos existente.

my $command = "find . -name \"$basefilename*\" -printf \"\%f\\n\" ";
print "command find: $command \n";

open (CMD, "$command |");

while (<CMD>) {
  chomp(); 
  my $file = $_;
  #print "archivo $_\n";
  my $afinidad = analyzar($file);

  $listfile{$file} =$afinidad;
  #print "File $file vale $afinidad\n";

}

my @list = %listfile;
print "listefile: @list \n";

# Now to order by afinity.
my $part;

my $order =0;
my $maxaf = 1000000;

printf ("#Part\tAfinity (kcal/mol) \n");

foreach $part (sort {$listfile{$a} <=> $listfile{$b} }

		keys %listfile)
{ 
  $order += 1;
  #print "Value: $value FIN\n";
  my @line = split (/-/,$part);

  if ($order == 1) {
    print "max is $listfile{$part}\n";
    $maxaf = $listfile{$part};
  }
  
  if ( $listfile{$part} <= $percent / 100 *$maxaf ) {
    printf ("G %i-%i-%i\t%0.4f \n",$line[2],$line[3],$line[4],$listfile{$part});
  }
  else {
    printf ("%i-%i-%i\t[%0.4f] \n",$line[2],$line[3],$line[4],$listfile{$part});
  }
  
}


sub analyzar {
  my $file= $_[0];
  #print "analyzamos el archivo $file \n";
    
  open (FILE , "$file");

  my $valor = 0;
  my $count = 0;

  while (<FILE>) {

    #buscamos la linea que empieza con "REMARK VINA RESULT:"
    # REMARK VINA RESULT:      -2.9      0.000      0.000

    chomp();
    if ($_ =~ /^REMARK VINA RESULT:/) {
      #print "$_\n";
      # Sacamos la afinidad, que es el segundo numero.
      my @line = split ( /\s+/, $_);
      $valor += $line[3];
      $count += 1;

    }

  }

  close(FILE);
  print "file $file: valor : $valor por/ $count \n";
  return ($valor/$count);

}
