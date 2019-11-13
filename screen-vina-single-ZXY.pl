#!/usr/bin/env perl

# Con este script pasamos a la segunda etapa del proceso: 
# Segun las partes de Z y de X escogidas, generar la lista y el script para el job que selecionara partes en Y

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

# para guardar las partes de Z-X a usar. ;
# GetOpt guarde les option dans @opt_variable
our @opt_part = () ;

$result = GetOptions (#"i=i" => \$jobNum,
		      'part=s@',
		      "c=i" => \$numcores,
		      "g=s" => \$logFile,
		      "h" => \$help);

# -h => help!
if ($help ne "" ) {
    print "$0 -part z-x -part z-y -part.... -c [# thread] \n";
    exit;
}

# Se usa el conf ya existente..
my $baseconfname = "conf_vina.txt";

print "Usaremos el archivo $baseconfname \n";

# Selectionar los Z-Xpart a utilizar.

my $numPart = @opt_part;
print " uso de $numPart part of Y\n";

# Conjuntamos la lista de los valores de las partes Z - X.
my $ZXYnum = 0;

open (LIST_Z_X_Y , ">liste-conf-ZXY");

for (my $i = 0; $i<$numPart ;$i++) {
  # part of this form:  6-5 
  # splitting with "-"

  my ($Znum,$Xnum) = split ( "-",  $opt_part[$i]);
  #print "part : $opt_part[$i]: Zpart: $Znum ; Xpart: $Xnum\n";
  open (LIST,"liste-conf-ZXY-$Znum-$Xnum");

  while (<LIST>) {
    $ZXYnum += 1;
    #print "$_";
    print LIST_Z_X_Y "$_";
  }
  
   close(LIST);

}

print "El file liste-conf-ZXY contiene $ZXYnum lineas\n";

# Now write the script file...

# Detectamos la ubicacion actual, para definir la ruta completa de los archivos pdbqt y las salidas

my $cwd = getcwd();

open (SCRIPT,">script-vina-ZXY.sh");

print SCRIPT "#!/bin/bash \n\n";

print SCRIPT "# Should run $ZXYnum   \n";

print SCRIPT "# Extract x,y,z value\n";
print SCRIPT "LISTFILE=liste-conf-ZXY \n";

print SCRIPT "for ((id=1;id<=$ZXYnum;id++)) \n";
print SCRIPT "do \n";

print SCRIPT "   echo \"Running part ZXY \$id / $ZXYnum \" \n";

print SCRIPT "   SEED=\$(cat \$LISTFILE | head -n \$id | tail -n 1) \n";
print SCRIPT "   znum=\$(echo \$SEED |cut -d \"\;\" -f1) \n";
print SCRIPT "   xnum=\$(echo \$SEED |cut -d \"\;\" -f2) \n";
print SCRIPT "   ynum=\$(echo \$SEED |cut -d \"\;\" -f3) \n";

print SCRIPT "   xc=\$(echo \$SEED |cut -d \"\;\" -f4) \n";
print SCRIPT "   xs=\$(echo \$SEED |cut -d \"\;\" -f5) \n";
print SCRIPT "   yc=\$(echo \$SEED |cut -d \"\;\" -f6) \n";
print SCRIPT "   ys=\$(echo \$SEED |cut -d \"\;\" -f7) \n";
print SCRIPT "   zc=\$(echo \$SEED |cut -d \"\;\" -f8) \n";
print SCRIPT "   zs=\$(echo \$SEED |cut -d \"\;\" -f9) \n";


print SCRIPT "   # Correr vina \n";
print SCRIPT "   $vinabin --cpu $numcores --config $cwd/$baseconfname ";
print SCRIPT "    --center_x \$xc --size_x \$xs ";
print SCRIPT "    --center_y \$yc --size_y \$ys ";
print SCRIPT "    --center_z \$zc --size_z \$zs ";
print SCRIPT "    --out  $cwd/OutVina-ZXY-\$znum-\$xnum-\$ynum --log Log-ZXY-\$znum-\$xnum-\$ynum >>$logFile 2>>$logFile \n";

print SCRIPT "\n";
print SCRIPT "done \n";

print SCRIPT "echo \"END\" \n";

close(SCRIPT);

print "ScriptName:script-vina-ZXY.sh \n";

