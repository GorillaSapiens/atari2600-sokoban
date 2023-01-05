#!/usr/bin/perl

sub ccount($) {
   my ($arg) = @_;
   $ccount2 = $ccount + $arg;
   my $ret = "[$ccount] + $arg = *$ccount2*";
   $ccount = $ccount2;
   return $ret;
}

sub thingie($$) {
   my ($i, $arg) = @_;
   $arg =~ s/[\x0a\x0d]//g;
   @arg = split //, $arg;

# 4..7 7..0 0..7
   $pf0 = 0;
   $pf1 = 0;
   $pf2 = 0;
   $pf3 = 0;
   $pf4 = 0;
   $pf5 = 0;

   $a = shift @arg;
   if ($a ne ' ') {
      $pf0 |= 1 << 4;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf0 |= 1 << 5;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf0 |= 1 << 6;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf0 |= 1 << 7;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf1 |= 1 << 7;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf1 |= 1 << 6;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf1 |= 1 << 5;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf1 |= 1 << 4;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf1 |= 1 << 3;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf1 |= 1 << 2;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf1 |= 1 << 1;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf1 |= 1 << 0;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf2 |= 1 << 0;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf2 |= 1 << 1;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf2 |= 1 << 2;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf2 |= 1 << 3;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf2 |= 1 << 4;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf2 |= 1 << 5;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf2 |= 1 << 6;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf2 |= 1 << 7;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf3 |= 1 << 4;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf3 |= 1 << 5;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf3 |= 1 << 6;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf3 |= 1 << 7;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf4 |= 1 << 7;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf4 |= 1 << 6;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf4 |= 1 << 5;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf4 |= 1 << 4;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf4 |= 1 << 3;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf4 |= 1 << 2;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf4 |= 1 << 1;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf4 |= 1 << 0;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf5 |= 1 << 0;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf5 |= 1 << 1;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf5 |= 1 << 2;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf5 |= 1 << 3;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf5 |= 1 << 4;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf5 |= 1 << 5;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf5 |= 1 << 6;
   }

   $a = shift @arg;
   if ($a ne ' ') {
      $pf5 |= 1 << 7;
   }

   $pf0 = sprintf("#\$%02X", $pf0);
   $pf1 = sprintf("#\$%02X", $pf1);
   $pf2 = sprintf("#\$%02X", $pf2);
   $pf3 = sprintf("#\$%02X", $pf3);
   $pf4 = sprintf("#\$%02X", $pf4);
   $pf5 = sprintf("#\$%02X", $pf5);

   $ccount = 0;
   print "      sta WSYNC\n";
   print "         ldx tmp0         ; " . ccount(3) . "\n";
   print "         stx COLUPF       ; " . ccount(3) . "\n";
   print "         ldy #$i           ; " . ccount(2) . "\n";
   print "         lda (LevelEnd),Y ; " . ccount(5) . " (maybe 6???)\n";
   print "         sta GRP1         ; " . ccount(3) . "\n";

   print "         lda $pf0         ; " . ccount(2) . "\n";
   print "         sta PF0          ; " . ccount(3) . " < 22\n";
   print "         lda $pf1         ; " . ccount(2) . "\n";
   print "         sta PF1          ; " . ccount(3) . " < 28\n";
   print "         lda $pf2         ; " . ccount(2) . "\n";
   print "         sta PF2          ; " . ccount(3) . " < 38\n";
   print "         lda $pf3         ; " . ccount(2) . "\n";
   print "         sta PF0          ; " . ccount(3) . " >= 28 < 49\n";
   print "         lda $pf4         ; " . ccount(2) . "\n";
   print "         sta PF1          ; " . ccount(3) . " >= 39 < 54\n";
   print "         stx COLUP1       ; " . ccount(3) . "\n";
   print "         nop              ; " . ccount(2) . "\n";
#   print "         nop              ; " . ccount(2) . "\n";
#   print "         nop              ; " . ccount(2) . "\n";
   print "         lda $pf5         ; " . ccount(2) . "\n";
   print "         sta PF2          ; " . ccount(3) . " >= 50 < 63\n";
   print "         lda tmp0         ; " . ccount(3) . "\n";
   print "         clc              ; " . ccount(2) . "\n";
   print "         adc #\$F0         ; " . ccount(2) . "\n";
   print "         ora #\$0F         ; " . ccount(2) . "\n";
   print "         sta tmp0         ; " . ccount(3) . "\n";

}

print "   MAC LOGO\n";
for ($i = 0; $i < 6; $i++) {
   thingie($i, <>);
}
print "   ENDM\n";
