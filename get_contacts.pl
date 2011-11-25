#!/usr/bin/perl
# get_contacts.pl
#
# read in adresses from people in a file called contact.dat
# thereby ignoring comments, blank lines, and make
# sure that the adress is properly formatted
#
# Author: Andreas Orthey, 2011

use strict;
use warnings;

#the file where our contacts are listed
my $contacts_file = "contacts.dat";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900; #counted from 1900
$mon += 1; #range [0..11]
print "--------------------------------------\n";
print "Today is $mday.$mon.$year\n";
print "checking for birthdays...\n";
print "--------------------------------------\n";
 
sub error{
  my ($file, $row, $text) = @_;

  #unknown line type or location/birthday before name
  print "Error in reading $file: line $row: $text\n";
  exit;
}

sub send_postcard{
	my (%person) = @_;

  #before we automate this, we should ask the user, if everything is correct,
  #so that we do not send cards to a wrong adress/at a wrong date
  
  print "please send a post card to your dear friend ".$person{'name'}."!\n";
  print "he/she will be ".$person{'age'}." today! (".$person{'birthday'}.")\n";
  print "adress: ".$person{'street'}."//".$person{'location'}."\n";
  print "-------------------------------------------------------------------\n";
}

sub check_person{
	my (%person) = @_;
  my $birthday = $person{'birthday'};
  if( $birthday =~ m/^([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})$/){
    if( $1 == $mday and $2 == $mon){
    	$person{'age'}=$year-$3;
    	send_postcard(%person);
    }else{
      #no birthday today :(
    }
  }else{
  	print "Birthday is not properly formatted: $birthday\n";
  }
}

#read in contact list
open FILE, "<", $contacts_file or die $!;

my ($data, $n, $offset);

my $row = 0;
my $adress_counter = 0;
while( my $line = <FILE> ){
  #check for error
  $row++;
  my %person = ('name', '', 'street', '', 'location', '', 'birthday', '');
  if( $line =~ m/^Name:[ \t]?([a-zA-ZäöüÄÖÜß]+) ([-a-zA-ZäöüÄÖÜß]+)([ \t]?)+$/ ){
    #if found a name, the next lines have to be Street,Location,Birthday,
    #in this order. otherwise we raise an error

  	$adress_counter++;
  	$person{'name'} = $1." ".$2;
  	
  	defined($line = <FILE>) or 
  	        die error($contacts_file, $row, "unexpected end of file");

  	$row++;
  	if( $line =~ m/^Street:[ \t]?([-\. A-Za-zß]+)([0-9]+[a-z]?)([ \t]?)+$/ ){

  	  $person{'street'} = $1.$2;

  	  defined($line = <FILE>) or 
  	          die error($contacts_file, $row, "unexpected end of file");

      $row++;
      if( $line =~ m/^Location:[ \t]?([0-9]{5}) ([A-Za-z]+)([ \t]?)+$/ ){
  	    $person{'location'} = $1." ".$2;

  	    defined($line = <FILE>) or 
  	            die error($contacts_file, $row, "unexpected end of file");

        $row++;

        if( $line =~ 
        	  m/^Birthday:[ \t]?([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})([ \t]?)+/){

          $person{'birthday'} = $1.".".$2.".".$3;
          check_person(%person);
        }else{
          error($contacts_file, $row, $line);
        }

      }else{
        error($contacts_file, $row, $line);
      }

    }else{
      error($contacts_file, $row, $line);
    }
  }else{
    if( $line =~ m/^[ \t]*$/ || $line =~ m/^#/ ){ 
      #comment or blank line, go on
    }else{
      error($contacts_file, $row, $line);
    }
  }
}

