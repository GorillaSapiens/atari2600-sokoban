#!/usr/bin/perl

$maxlevels_per_bank = 9;
$maxlevels = $maxlevels_per_bank * 8;
$maxheight = 16;
$maxboxes = 15;
$maxboxes_last = 12; # max boxes for maze at $ff00
# we cannot go past F4

$levels_so_far = 0;

# ****************************************
# *********************************** ****
# *   *                             *   **
# * 0 1 2 3 4 5 6 7 8 9 A B C D E F G H **
# *   *                             * ****
# * * ***** * * * * * * * * * * * * * ****
# *                                 * ****
# * * * * * * * * * * * * * * * * * * ****
# *                                 * ****
# ********* * * * * * * * * * * * * * ****
# *                                 * ****
# * * * * * * * * * * * * * * * * * * ****
# *                                 * ****
# *********************************** ****

@numbers = (
      " XXX",
      " X X",
      " X X",
      " X X",
      " XXX",
      "    ",

      "   X",
      "   X",
      "   X",
      "   X",
      "   X",
      "    ",

      " XXX",
      "   X",
      " XXX",
      " X  ",
      " XXX",
      "    ",

      " XXX",
      "   X",
      " XXX",
      "   X",
      " XXX",
      "    ",

      " X X",
      " X X",
      " XXX",
      "   X",
      "   X",
      "    ",

      " XXX",
      " X  ",
      " XXX",
      "   X",
      " XXX",
      "    ",

      " XXX",
      " X  ",
      " XXX",
      " X X",
      " XXX",
      "    ",

      " XXX",
      "   X",
      "   X",
      "   X",
      "   X",
      "    ",

      " XXX",
      " X X",
      " XXX",
      " X X",
      " XXX",
      "    ",

      " XXX",
      " X X",
      " XXX",
      "   X",
      " XXX",
      "    ",

      "    ",
      "    ",
      "    ",
      "    ",
      "    ",
      "    ",
      );

sub do_numbers() {
   $numtodo = $levels_so_far;
   $tens = int($numtodo / 10);
   if ($tens == 0) { $tens = 10; }
   $ones = $numtodo % 10;

   for ($j = 0; $j < 5; $j++ )
   {
      $mask = $one;
      $thing = $numbers[$tens * 6 + $j] . $numbers[$ones  * 6 + $j];
      for (my $i = 0; $i < 8; $i++) {
         if (substr($thing, $i, 1) eq "X") {
            $mask |= (1 << (7 - $i));
         }
      }
      $comment = sprintf "%02X", $mask;
      $comment =~ s/0/    /g;
      $comment =~ s/1/   */g;
      $comment =~ s/2/  * /g;
      $comment =~ s/3/  **/g;
      $comment =~ s/4/ *  /g;
      $comment =~ s/5/ * */g;
      $comment =~ s/6/ ** /g;
      $comment =~ s/7/ ***/g;
      $comment =~ s/8/*   /g;
      $comment =~ s/9/*  */g;
      $comment =~ s/A/* * /g;
      $comment =~ s/B/* **/g;
      $comment =~ s/C/**  /g;
      $comment =~ s/D/** */g;
      $comment =~ s/E/*** /g;
      $comment =~ s/F/****/g;
      printf ("   dc.b #\$%02x ; %s\n", $mask, $comment);
   }
   print "   dc.b #\$00\n";
}

sub peek($$) {
   my ($x, $y) = @_;
   return substr($level[$y], $x, 1);
}

sub encode($$) {
   my ($x,$y) = @_;
   return sprintf("#\$%02x,#\$%02x", $x, $y);
}

sub do_pf(@) {
# 4..7 7......0 0......7 4..7 7......0 0......7 REF = 0
# PF0  PF1      PF2      PF0  PF1      PF2
   my $pf0 = 0;
   my $pf1 = 0;
   my $pf2 = 0;
   my $pf3 = 0;
   my $pf4 = 0;
   my $pf5 = 0;

   if (shift(@_) eq "*") { $pf0 |= 1 << 4; }
   if (shift(@_) eq "*") { $pf0 |= 1 << 5; }
   if (shift(@_) eq "*") { $pf0 |= 1 << 6; }
   if (shift(@_) eq "*") { $pf0 |= 1 << 7; }

   if (shift(@_) eq "*") { $pf1 |= 1 << 7; }
   if (shift(@_) eq "*") { $pf1 |= 1 << 6; }
   if (shift(@_) eq "*") { $pf1 |= 1 << 5; }
   if (shift(@_) eq "*") { $pf1 |= 1 << 4; }
   if (shift(@_) eq "*") { $pf1 |= 1 << 3; }
   if (shift(@_) eq "*") { $pf1 |= 1 << 2; }
   if (shift(@_) eq "*") { $pf1 |= 1 << 1; }
   if (shift(@_) eq "*") { $pf1 |= 1 << 0; }

   if (shift(@_) eq "*") { $pf2 |= 1 << 0; }
   if (shift(@_) eq "*") { $pf2 |= 1 << 1; }
   if (shift(@_) eq "*") { $pf2 |= 1 << 2; }
   if (shift(@_) eq "*") { $pf2 |= 1 << 3; }
   if (shift(@_) eq "*") { $pf2 |= 1 << 4; }
   if (shift(@_) eq "*") { $pf2 |= 1 << 5; }
   if (shift(@_) eq "*") { $pf2 |= 1 << 6; }
   if (shift(@_) eq "*") { $pf2 |= 1 << 7; }

   if (shift(@_) eq "*") { $pf3 |= 1 << 4; }
   if (shift(@_) eq "*") { $pf3 |= 1 << 5; }
   if (shift(@_) eq "*") { $pf3 |= 1 << 6; }
   if (shift(@_) eq "*") { $pf3 |= 1 << 7; }

   if (shift(@_) eq "*") { $pf4 |= 1 << 7; }
   if (shift(@_) eq "*") { $pf4 |= 1 << 6; }
   if (shift(@_) eq "*") { $pf4 |= 1 << 5; }
   if (shift(@_) eq "*") { $pf4 |= 1 << 4; }
   if (shift(@_) eq "*") { $pf4 |= 1 << 3; }
   if (shift(@_) eq "*") { $pf4 |= 1 << 2; }
   if (shift(@_) eq "*") { $pf4 |= 1 << 1; }
   if (shift(@_) eq "*") { $pf4 |= 1 << 0; }

   if (shift(@_) eq "*") { $pf5 |= 1 << 0; }
   if (shift(@_) eq "*") { $pf5 |= 1 << 1; }
   if (shift(@_) eq "*") { $pf5 |= 1 << 2; }
   if (shift(@_) eq "*") { $pf5 |= 1 << 3; }
   if (shift(@_) eq "*") { $pf5 |= 1 << 4; }
   if (shift(@_) eq "*") { $pf5 |= 1 << 5; }
   if (shift(@_) eq "*") { $pf5 |= 1 << 6; }
   if (shift(@_) eq "*") { $pf5 |= 1 << 7; }

   my $ret = sprintf(
         "#\$%02x, #\$%02x, #\$%02x, #\$%02x, #\$%02x, #\$%02x",
         $pf0, $pf1, $pf2, $pf3, $pf4, $pf5);
}

$mode = 0;
while (<>) {
   s/[\x0a\x0d]//g;
   if (/<Level /) {
      $height = $width = 0;
      $tmp = $_;
      $tmp =~ s/Height=\"([^\"]+)/$height = $1/ge;
      $tmp = $_;
      $tmp =~ s/Width=\"([^\"]+)/$width = $1/ge;

      if ($height > 0 && $height < $maxheight) {
         if ($width > 0 && $width < 20) {
            @out = ();

            @boxes = ();
            @goals = ();
            @start = ();

            push @out, "   align 256\n";
            push @out, "; begin $width x $height\n";
            $mode = 1;
            $max = 0;
            @level = ();
         }
      }
   }
   elsif (/<\/Level>/) {
      if ($mode == 1) {
         $phase = 0;
         while ($#level + 1 < $maxheight) {
            if ($phase) {
               unshift @level, " ";
            }
            else {
               push @level, " ";
            }
            $phase = !$phase;
            $height++;
         }
         foreach $line (@level) {
            while (length($line) < $max) {
               $line .= " ";
            }
         }
         while ($width < 20) {
            foreach $line (@level) {
               if ($phase) {
                  $line .= " ";
               }
               else {
                  $line = " " . $line;
               }
            }
            $phase = !$phase;
            $width++;
         }
         foreach $line (@level) {
            push @out, ";|$line|\n";
         }
# 4..7 7......0 0......7 4..7 7......0 0......7 REF = 0
# PF0  PF1      PF2      PF0  PF1      PF2
         $egoals = 0;
         for ($y = 0; $y < $height; $y++) {
            @pf0 = split //, "                                        ";
            @pf1 = split //, "                                        ";
            for ($x = 0; $x < $width; $x++) {
               $pixel = peek($x, $y);
               if ($pixel eq "#") {

                  $pf0[$x*2] = "*";

                  $walls = 0;

                  $wb = $wr = 0;

                  if ($y > 0) { # wall above?
                     $up = peek($x, $y - 1);
                     if ($up eq "#") {
                        $walls++;
                     }
                  }

                  if ($y < $height - 1) { # wall below?
                     $down = peek($x, $y+1);
                     if ($down eq "#") {
                        $pf1[$x*2] = "*";
                        $walls++;
                        $wb = 1;
                     }
                  }

                  if ($x > 0) { # wall left?
                     $left = peek($x - 1, $y);
                     if ($left eq "#") {
                        $walls++;
                     }
                  }

                  if ($x < $width - 1) { # wall_right?
                     $right = peek($x+1, $y);
                     if ($right eq "#") {
                        $pf0[$x*2+1] = "*";
                        $walls++;
                        $wr = 1;
                     }
                  }

                  if ($wb && $wr) {
                     $tmp = peek($x+1, $y+1);
                     if ($tmp eq "#") {
                        $pf1[$x*2+1] = "*";
                     }
                  }

                  if ($walls == 0) {
                     $mode = 0;
                  }
               }
               elsif ($pixel eq ".") {
                  $pf0[$x*2] = "*";
                  push @goals, encode($x,$y);
                  $egoals++;
               }
               elsif ($pixel eq "*") {
                  $pf0[$x*2] = "*";
                  push @goals, encode($x,$y);
                  push @boxes, encode($x,$y);
               }
               elsif ($pixel eq "\$") {
                  push @boxes, encode($x,$y);
               }
               elsif ($pixel eq "@") {
                  push @start, encode($x,$y);
               }
               elsif ($pixel eq "+") {
                  $pf0[$x*2] = "*";
                  push @goals, encode($x,$y);
                  push @start, encode($x,$y);
               }
            }
            push @out, "   dc.b " . do_pf(@pf0) . " ; " . join("", @pf0) . " ; map\n";
            if ($y != $height - 1) {
               push @out, "   dc.b " . do_pf(@pf1) . " ; " . join("", @pf1) . "\n";
            }
         }
# max boxes checks (there are two!)
         if ($levels_so_far % $maxlevels_per_bank == ($maxlevels_per_bank - 1)) {
            if ($#boxes + 1 > $maxboxes_last) {
               $mode = 0;
            }
         }
         if ($#boxes + 1 > $maxboxes) { # max boxes
            $mode = 0;
         }
# eliminate trivial levels
         if ($egoals == 0) {
            $mode = 0;
         }

         for ($n = 0; $n <= $#boxes; $n++) {
            push @out, "   dc.b $boxes[$n],$goals[$n] ; box,goal\n";
         }
         push @out, "   dc.b " . $start[0] . ",#\$FF,#\$FF ; start+terminator\n";
      }

      if ($mode == 1) {
         if ($levels_so_far % $maxlevels_per_bank == 0) {
            $bank = int($levels_so_far / $maxlevels_per_bank);
            if ($bank != 0) {
               print "   ENDM\n";
            }
            print "   MACRO BANK$bank\n";
         }

         print @out;
         $levels_so_far++;
         do_numbers();
         if ($levels_so_far >= $maxlevels) {
            print "   ENDM\n";
            exit 0;
         }
      }

      $mode = 0;
   }
   elsif ($mode == 1) {
      s/^.*<L>//g;
      s/<\/L>.*$//g;
      if (length($_) > $max) {
         $max = length($_);
      }
      push @level, $_;
   }
}
