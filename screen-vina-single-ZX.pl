#!/usr/bin/env perl

# Con este script pasamos a la segunda etapa del proceso: 
# Segun las partes de Z escogidas, generar la lista y el script para el job que selecionara partes en X

use strict;

use Getopt::Long;

use Cwd;

my $result;
my $help = "";

# Defining the path to the application: VINAPROCESS

my $vinabin = $ENV{"VINAPROCESS"};
$vinabin .= "/bin/vina";

# 4 cores default..
my $numcores = 4;

# To output the log of the study.
my $logFile = "logFile.txt";

# para guardar las partes de Z a usar. ;
our @opt_part = () ;

$result = GetOptions (#"i=i" => \$jobNum,
		      'part=i@', 
		      "c=i" => \$numcores,
		      "g=s" => \$logFile,
		      "h" => \$help);

# -h => help!
if ($help ne "" ) {
    print "$0  -part num1 -part num2 -part....  -c [# thread] -g [Appended log file]\n";
    exit;
}

# Se usa el conf ya existente..
my $baseconfname = "conf_vina.txt";

print "Usaremos el archivo $baseconfname \n";

# Selectionar los Zpart a utilizar.

my $numPart = @opt_part;
print " uso de $numPart part of X\n";

# Conjuntamos la lista de los valores de las partes.
my $ZXnum = 0;

open (LIST_Z_X , ">liste-conf-ZX");

for (my $i = 0; $i<$numPart ;$i++) {
  print "part : $opt_part[$i]\n";

  open (LIST,"liste-conf-ZX-$opt_part[$i]");

  while (<LIST>) {
    $ZXnum += 1;
    #print "$_";
    print LIST_Z_X "$_";
  }
}

print "El file liste-conf-ZX contiene $ZXnum lineas\n";

# Now write the script file...

# Detectamos la ubicacion actual, para definir la ruta completa de los archivos pdbqt y las salidas

my $cwd = getcwd();

open (SCRIPT,">script-vina-ZX.sh");

print SCRIPT "#!/bin/bash \n\n";

print SCRIPT "# Should run $ZXnum   \n";

print SCRIPT "# Extract x,y,z value\n";
print SCRIPT "LISTFILE=liste-conf-ZX \n";

print SCRIPT "for ((id=1;id<=$ZXnum;id++)) \n";
print SCRIPT "do \n";

print SCRIPT "   echo \"Running part ZX \$id / $ZXnum \" \n";

print SCRIPT "   SEED=\$(cat \$LISTFILE | head -n \$id | tail -n 1) \n";
print SCRIPT "   znum=\$(echo \$SEED |cut -d \"\;\" -f1) \n";
print SCRIPT "   xnum=\$(echo \$SEED |cut -d \"\;\" -f2) \n";

print SCRIPT "   xc=\$(echo \$SEED |cut -d \"\;\" -f3) \n";
print SCRIPT "   xs=\$(echo \$SEED |cut -d \"\;\" -f4) \n";
print SCRIPT "   yc=\$(echo \$SEED |cut -d \"\;\" -f5) \n";
print SCRIPT "   ys=\$(echo \$SEED |cut -d \"\;\" -f6) \n";
print SCRIPT "   zc=\$(echo \$SEED |cut -d \"\;\" -f7) \n";
print SCRIPT "   zs=\$(echo \$SEED |cut -d \"\;\" -f8) \n";


print SCRIPT "    # Correr vina \n";
print SCRIPT "    $vinabin --cpu $numcores --config $cwd/$baseconfname ";
print SCRIPT "     --center_x \$xc --size_x \$xs ";
print SCRIPT "     --center_y \$yc --size_y \$ys ";
print SCRIPT "     --center_z \$zc --size_z \$zs ";
print SCRIPT "     --out  $cwd/OutVina-ZX-\$znum-\$xnum --log Log-ZX-\$znum-\$xnum  >>$logFile 2>>$logFile \n";

print SCRIPT "\n";
print SCRIPT "done \n";

print SCRIPT "echo \"END\" \n";

close(SCRIPT);

print "ScriptName:script-vina-ZX.sh \n";

