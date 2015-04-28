#!/usr/bin/perl

#This Perl script reads through the Test Bench (a Verilog file) 
#It returns the input vectors in the form acceptable to ODIN
#This is going to change your life
#use strict;
#use warnings;
use Verilog::Netlist;
use File::Copy;
# Prepare the netlist for a given file 
# TO DO : Substitute with the Session id and the uploader_dut.v file that the user uploads in the VLABs website
$file_name=$ARGV[0];
copy("$file_name","testbench_always.v") or die "Copy failed: $!";
my $nl = new Verilog::Netlist();
$nl->read_file(filename => $file_name);
#The above command parses the Verilog file into a hash of ports, signals and instantiations
#copy("$file_name","testbench_always.v") or die "Copy failed: $!";
my @input_ports;
my @output_ports;
for my $mod ( $nl->top_modules_sorted() ) {
@input_ports = show_port_names_directions($mod, '', '', '');
}
@output_ports = insert_always($mod, '', '', '');
print "The Test Bench is created successfully with the always block and named as testbench_always.v\n";

######################################## SUB ROUTINES #################################################################################
sub sigdir {
   # Change "in"  to "input" and "out" to "output"
   my $dir = shift;
   return ($dir eq 'inout') ? $dir: $dir . 'put';
}

sub show_port_names_directions {
   # Recursively descend through module hierarchy,
   # printing each module name and full hierarchical
   # specifier, all module port names, and all
   # instance port connections.
    $mod      = shift;
    $indent   = shift;
    $hier     = shift;
    $cellname = shift;
    @inputs;
    @temp_array;
    @temp_array1;
   if ($cellname) {
       $hier .= ".$cellname";
   }
   else {	
       $hier = $mod->name();
   }

for my $cell ($mod->cells_sorted()) {
       for my $pin ($cell->pins_sorted()) {
           print 'CellName=', $cell->name(), ' PinName=', $pin->name(),' NetName=', $pin->netname(), "\n";
       }
       show_port_names_directions($cell->submod(), $indent, $hier, $cell->name()) if $cell->submod();
   }
}

sub insert_always{
open (my $fh1, ">>testbench_always.v");
print $fh1 "integer fh1_v,fh2_v;\n";
print $fh1 'fh1_v= fopen("inputvectors.txt");';
print $fh1 "\n";
print $fh1 'fh2_v= fopen("outputvectors.txt");';
print $fh1 "\n";
print $fh1 'always@(clk)';
print $fh1 "\nbegin\n";
for my $sig ($mod->ports_sorted()) {
	       if (sigdir($sig->direction()) eq 'input'){
		print $fh1 "fdisplay(fh1_v,The value stored in the input port ", $sig->name() ," is %b ,", $sig->name() , ");\n";
		}
		else{
		print $fh1 "fdisplay(fh2_v,The value stored in the output port ", $sig->name() ," is %b ,", $sig->name() , ");\n";
		}}
print $fh1 "end\n";
print $fh1 "fclose(fh1_v);\n";
print $fh1 "fclose(fh2_v);\n";
close $fh1;
# return (@inputs);
}
        
  
