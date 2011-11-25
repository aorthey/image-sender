#!/usr/bin/perl
use Image::Magick;
use strict;
use warnings;

my $image_folder = "images/";
my @images_avaiable = <$image_folder*>;
my $final_postcard_name = "postcard.png";
my $image = Image::Magick->new;

my $greetings = "greetings.txt";
open FILE, "<", $greetings, or die $!;
my @str = <FILE>;

my $choosen_background_card = int(rand(scalar(@images_avaiable)));
$image->ReadImage($images_avaiable[$choosen_background_card]);
print "background for postcard from $choosen_background_card\n";
my $y='y';
my $x='x';

my ($width, $height) = $image->Get('width','height');
print " size: $width x $height";

my $choosen_greeting = $str[int(rand(scalar(@str)))];
print "greeting formula: $choosen_greeting\n";

my $x_c = 0.4*$width;
my $y_c = 0.8*$height;

$image->OilPaint(radius=>3);

close FILE;
$image->Write($final_postcard_name);
