#!/usr/bin/perl
use Image::Magick;
use Tk;
use Tk::PNG;
use Tk::JPEG;
use Tk::Toplevel;
use MIME::Base64;
use strict;
use warnings;

# changeable paths/variables
my $image_folder = "images/";
my $greetings = "greetings.txt";
my $font_path = "/usr/share/fonts/truetype/msttcorefonts/";
my $font_type = "comic.ttf";

my $final_postcard_name = "postcard.gif";

my @images_avaiable = <$image_folder*>;
my $image = Image::Magick->new;
my $choosen_greeting = "";
my $choosen_background_card = 0;
my $rotation = 0;
my $blob = 0;
my $img_tk = 0;
my $send_email_card = 0;
my $send_post_card = 0;

#get current desktop resolution of linux system

(my @xdpy_output)= `xdpyinfo|grep dimension`;

my $desktop_height=768;
my $desktop_width=1024;

foreach my $xdpy_line (@xdpy_output){
  if($xdpy_line =~ m/([0-9]+)x([0-9]+)/){
    print "desktop dimensions are: $1x$2\n";
    $desktop_width = $1;
    $desktop_height = $2;
  }
}

my $main = new MainWindow;

#create a new image for the first time
&create_image;

my $control_frame = $main->Frame()->pack(-side => 'top');
my $image_frame = $main->Frame()->pack(-side => 'bottom');

my $label = $control_frame->Label(-text=>"Image sender 0.1");

my $check_button_mail = 
    $control_frame->Checkbutton(-text => 'Send Email Card', 
                                -variable=>\$send_email_card)
                                ->pack(-side => 'left');
$check_button_mail->deselect();
my $check_button_post = 
    $control_frame->Checkbutton(  -text => 'Send PostCard', 
                                  -variable=>\$send_post_card)
                                  ->pack(-side => 'left');

$check_button_post->deselect();

my $button_create_new = 
    $control_frame->Button( -text => "Create New", 
                            -command =>\&create_image)
                            ->pack(-side => 'left');
my $button_rotate = 
    $control_frame->Button( -text => "Rotate", 
                            -command => \&rotate_image)
                            ->pack(-side => 'left');
my $button_exit = 
    $control_frame->Button( -text => "Exit", 
                            -command => \&exit)
                            ->pack(-side => 'left');
my $button_send = 
    $control_frame->Button( -text => "Send Card!", 
                            -command => \&send_card)
                            ->pack(-side => 'left');


#$check_button_post->grid(-row=>1, -column=>1);
#$check_button_mail->grid(-row=>1, -column=>2);
#$button_create_new->grid(-row=>1, -column=>3);
#$button_rotate->grid(-row=>1, -column=>4);
#$button_exit->grid(-row=>1, -column=>5);
#$button_create_new;
#$button_rotate;

my $img = $image_frame->Label('-image' => $img_tk)->pack();
my $scroll_y = $image_frame->Scrollbar(-orient=>'v',
  -command=>[yview => $img])->pack();
my $scroll_x = $image_frame->Scrollbar(-orient=>'h',
  -command=>[xview => $img])->pack();

$scroll_x->grid(-row=>1, -column=>3, -sticky=>"ns");
$scroll_y->grid(-row=>2, -column=>3, -sticky=>"ns");
$img->grid(-row=>2, -column=>1, -columnspan=>2);


sub send_card{

  my $check = $main->Toplevel();
  my $label = $check->Label(-text => "Are you sure?")->pack();

  my $button_no = $check->Button(-text => "Cancel",
                                  -command => sub{
                                  	$check->destroy()})->pack(-side=>'left');

  my $button_yes = $check->Button(-text => "Send",
                                  -command => \&exit)->pack(-side => 'left');
	
}#send_card
MainLoop;






#image manipulation methods
sub rotate_image{
	$rotation += 90;
	if($rotation > 360){
		$rotation -= 360;
  }
	&write_image;
  $blob = ($image->ImageToBlob(-magick => 'jpg'))[0];
  $img_tk = $main->Photo('img', -format=>'jpeg', -data=>encode_base64($blob));
}#creat_image


sub create_image{
	$rotation=0;
	&choose_image;
	&write_image;
  $blob = ($image->ImageToBlob(-magick => 'jpg'))[0];
  $img_tk = $main->Photo('img', -format=>'jpeg', -data=>encode_base64($blob));
}#creat_image

sub choose_image{

  #choose random greeting from file
  open FILE, "<", $greetings, or die $!;
  my @str;
  while(my $line =<FILE>){
    if($line =~ m/^[ \t]?+$/ or $line =~ m/^#/){
      #comment or blank line
    }else{
      $line =~ s/(%YEAR%)/100/ig;
      #print $line;
      push(@str, $line);
    }
  }

  $choosen_greeting = $str[int(rand(scalar(@str)))];
  $choosen_background_card = int(rand(scalar(@images_avaiable)));

}#choose_image


sub write_image{

  $image = Image::Magick->new;
  $image->ReadImage($images_avaiable[$choosen_background_card]);
  $image->Scale(width => $desktop_width/2, height => $desktop_height/2);
  $image->Rotate(degrees => $rotation);
  print "background for postcard from ".$image->Get('filename')."\n";
  my $y='y';
  my $x='x';

  my ($width, $height) = $image->Get('width','height');
  print "size: $width x $height";

  print "greeting formula: $choosen_greeting\n";

  my $x_c = 0.4*$width;
  my $y_c = 0.8*$height;

  #$image->OilPaint(radius=>1);

  my $x_start = $x_c-50;
  my $y_start = $y_c-0.05*$height;
  my $x_end = $width;
  my $y_end = $y_c + 0.05*$height;
  my $points = "$x_start,$y_start $x_end,$y_end";
#$image ->Draw(strike => 'white', primitive => 'rectangle', points => $points);
  $image -> Annotate(
     text => "$choosen_greeting",
     strokewidth => int(0.001*$height),
     stretch => 'ExtraCondensed',
     stroke => "black",
     antialias=> 'true',
     fill => "white",
     aligh => 'Center',
     gravity => 'South',
     pointsize => int(0.1*$height),
     font => $font_path.$font_type);

  close FILE;
  #$image->Write($final_postcard_name);

}#create_image
