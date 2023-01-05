#!/usr/bin/perl

sub decode($) {
   my $arg = shift @_;

   if($arg =~ /ld[axy] .*,X/) {
#return 5; # TODO FIX, assumes always crosses page
      return 4;
   }
   elsif($arg =~ /ld[axy] \(.*\),X/) {
      return 6;
   }
   elsif($arg =~ /ld[axy] \(/) {
      return 5;
   }
   elsif($arg =~ /ld[axy] #/) {
      return 2;
   }
   elsif($arg =~ /ld[axy] /) {
      return 3;
   }

   if($arg =~ /st[axy] .*,X/) {
#return 5; # TODO FIX, assumes always crosses page
      return 4;
   }
   elsif($arg =~ /st[axy] \(.*\),X/) {
      return 6;
   }
   elsif($arg =~ /st[axy] \(/) {
      return 5;
   }
   elsif($arg =~ /st[axy] #/) {
      return 2;
   }
   elsif($arg =~ /st[axy] /) {
      return 3;
   }

   if($arg =~ /cmp \(/) {
      return 5;
   }
   elsif($arg =~ /cmp #/) {
      return 2;
   }
   elsif($arg =~ /cmp /) {
      return 3;
   }

   if($arg =~ /adc \(/) {
      return 5;
   }
   elsif($arg =~ /adc #/) {
      return 2;
   }
   elsif($arg =~ /adc /) {
      return 3;
   }

   if($arg =~ /sbc \(/) {
      return 5;
   }
   elsif($arg =~ /sbc #/) {
      return 2;
   }
   elsif($arg =~ /sbc /) {
      return 3;
   }

   if ($arg =~ /dec/) {
      return 5;
   }

   if ($arg =~ /jmp \(/) {
      return 5;
   }
   elsif ($arg =~ /jmp/) {
      return 3;
   }

   if ($arg =~ / b/) {
      $tmp = $arg;
      $tmp =~ s/^[ ]+//g;
      ($tmp1, $tmp2) = split / /, $tmp;
      $labels{$tmp2} = $now + 4;
   }

   return 2;
}

$now = 0;
while (<>) {
   @parts = split /;;/;
   if ($#parts <= 0) {
      print $_;
   }
   elsif (!(/^ /)) {
      $label = $_;
      $label =~ s/[ \x0a\x0d].*//g;
      if (defined($labels{$label})) {
         $now = $labels{$label};
      }
      print $_;
   }
   else {
      if ($parts[1] =~ /\[0\]/) { $now = 0; }
      $count = decode($parts[0]);
      $sum = $now + $count;
      while (length($parts[0]) < 40) {
         $parts[0] .= " ";
      }
      print "$parts[0];; [$now] + $count = *$sum*";
      if ($#parts == 2) {
         print " ;;$parts[2]";
      }
      else {
         print "\n";
      }
      $now = $sum;
   }
}
