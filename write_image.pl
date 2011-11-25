#!/usr/bin/perl
use Image::Magick;
use strict;
use warnings;

# changeable paths/variables
my $image_folder = "images/";
my $greetings = "greetings.txt";
my $font_path = "/usr/share/fonts/truetype/msttcorefonts/";
my $font_type = "comic.ttf";


my $final_postcard_name = "postcard.png";
my @images_avaiable = <$image_folder*>;
my $image = Image::Magick->new;

open FILE, "<", $greetings, or die $!;
my @str;
while(my $line =<FILE>){
	if($line =~ m/^[ \t]?+$/ or $line =~ m/^#/){
    #comment or blank line
  }else{
  	$line =~ s/(%YEAR%)/100/ig;
  	print $line;
  	push(@str, $line);
  }
}

my $choosen_background_card = int(rand(scalar(@images_avaiable)));
$image->ReadImage($images_avaiable[$choosen_background_card]);
$image->Scale(width => '1000', height => '600');
print "background for postcard from ".$image->Get('filename')."\n";
my $y='y';
my $x='x';

my ($width, $height) = $image->Get('width','height');
print "size: $width x $height";

my $choosen_greeting = $str[int(rand(scalar(@str)))];
print "greeting formula: $choosen_greeting\n";

my $x_c = 0.4*$width;
my $y_c = 0.8*$height;

$image->OilPaint(radius=>1);

my $x_start = $x_c-50;
my $y_start = $y_c-0.05*$height;
my $x_end = $width;
my $y_end = $y_c + 0.05*$height;
my $points = "$x_start,$y_start $x_end,$y_end";
#$image ->Draw(strike => 'white', primitive => 'rectangle', points => $points);

#Annotate  text=>string, font=>string, family=>string, style=>{Normal, Italic,
#Oblique, Any}, stretch=>{Normal, UltraCondensed, ExtraCondensed, Condensed,
#SemiCondensed, SemiExpanded, Expanded, ExtraExpanded, UltraExpanded},
#weight=>integer, pointsize=>integer, density=>geometry, stroke=>color name,
#strokewidth=>integer, fill=>color name, undercolor=>color name, kerning=>float,
#geometry=>geometry, gravity=>{NorthWest, North, NorthEast, West, Center, East,
#SouthWest, South, SouthEast}, antialias=>{true, false}, x=>integer,
#y=>integer, affine=>array of float values, translate=>float, float,
#scale=>float, float, rotate=>float. skewX=>float, skewY=> float, align=>{Left,
#Center, Right}, encoding=>{UTF-8}, interline-spacing=>double,
#interword-spacing=>double, direction=>{right-to-left, left-to-right}

$image -> Annotate(
   text => "$choosen_greeting",
   strokewidth => 4,
   stretch => 'ExtraCondensed',
   stroke => "black",
   antialias=> 'true',
   fill => "white",
   aligh => 'Center',
   gravity => 'South',
   pointsize => int(0.1*$height),
   font => $font_path.$font_type);

close FILE;
$image->Write($final_postcard_name);
