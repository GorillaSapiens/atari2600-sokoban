#!/usr/bin/perl

$total = 0;

$nivelo = 0;

sub process() {
	$count = 0;
	@start = ();
	@goal = ();
	$begin = 0;

	$tmp = $deets;
	$tmp =~ s/Height=\"([0-9]*)/$height=$1/ge;
	$tmp = $deets;
	$tmp =~ s/Width=\"([0-9]*)/$width=$1/ge;

	if ($height > 10 || $width > 10) {
		return;
	}

	print "Nivelo$nivelo\n";
	$nivelo++;
	print "; height=$height width=$width\n";
	foreach $line (@data) {
		print "; $line\n";
	}

	while ($#data != 9) {
		push @data, "        ";
	}

	$top = shift @data;
	$bottom = pop @data;
	$left = $right = $corners = "";


	$tmp = $top;
	while (length($tmp) != 10) {
		$tmp .= " ";
	}
	$corners .= substr($tmp, 0, 1);
	$corners .= substr($tmp, 9, 1);
	$tmp = substr($tmp,1,8);
	$tmp =~ s/#/1/g;
	$tmp =~ s/[^1]/0/g;
	$trunc = $top . "        ";
	$trunc = substr($trunc, 1, 8);
	print "\t.byte \%$tmp ; '$trunc' ; top\n";
	$count++;


	foreach $line (@data) {
		$tmp = $line;
		while (length($tmp) != 10) {
			$tmp .= " ";
		}
		$left .= substr($tmp, 0, 1);
		$right .= substr($tmp, 9, 1);
		$tmp = substr($tmp,1,8);
		$tmp =~ s/#/1/g;
		$tmp =~ s/[^1]/0/g;
		$trunc = $line . "        ";
		$trunc = substr($trunc, 1, 8);
		$nnn = $count - 1;
		print "\t.byte \%$tmp ; '$trunc' ; #$nnn\n";
		$count++;
	}


	$tmp = $bottom;
	while (length($tmp) != 10) {
		$tmp .= " ";
	}
	$corners .= substr($tmp, 0, 1);
	$corners .= substr($tmp, 9, 1);
	$tmp = substr($tmp,1,8);
	$tmp =~ s/#/1/g;
	$tmp =~ s/[^1]/0/g;
	$trunc = $bottom . "        ";
	$trunc = substr($trunc, 1, 8);
	print "\t.byte \%$tmp ; '$trunc' ; bottom\n";
	$count++;


	$tmp = $left;
	$tmp =~ s/#/1/g;
	$tmp =~ s/[^1]/0/g;
	print "\t.byte \%$tmp ; '$left' ; left\n";
	$count++;


	$tmp = $right;
	$tmp =~ s/#/1/g;
	$tmp =~ s/[^1]/0/g;
	print "\t.byte \%$tmp ; '$right' ; right\n";
	$count++;

	# TODO FIX this is for testing
	if ($nivelo == 1) { # really level 0
		$corners = "####";
	}

	$tmp = $corners . "    ";
	$tmp =~ s/#/1/g;
	$tmp =~ s/[^1]/0/g;
	print "\t.byte \%$tmp ; '$corners' ; corners\n";
	$count++;


	$y = 0;
	foreach $line (@data) {
		@pieces = split //, $line;
		shift @pieces;
		$x = 0;
		foreach $piece (@pieces) {
			if ($piece eq "." || $piece eq "*" || $piece eq "+") {
				push @goal, 0x80 + 16*$x+$y;
			}
			if ($piece eq "\$" || $piece eq "*") {
				push @start, 0x80 + 16*$x+$y;
			}
			if ($piece eq "@" || $piece eq "+") {
				$begin = 0x80 + 16*$x+$y;
			}
			$x++;
		}
		$y++;
	}
	printf "\t.byte \$%02x ; begin\n", $begin ;
	$count++;
	while ($#start >= 0) {
		$a = shift @start;
		$b = shift @goal;
		printf "\t.byte \$%02x, \$%02x ; start, goal\n", $a, $b;
		$count += 2;
	}

	# terminate it
	$count++;
	$total += $count;
	print "\t.byte \$00; end count=$count total=$total\n";

	while ($total % 256 > (256-24)) {
		$total++;
		$count++;
		print "\t.byte \$00; alignment padding count=$count total=$total\n";

	}
}

while (<>) {
	$_ =~ s/[\x0a\x0d]//g;
	if ($mode == 0 && /<Level/) {
		$deets = $_;
		$mode = 1;
		@data = ();
	}
	elsif ($mode == 1 && /<\/Level/) {
		$mode = 0;
		process();
	}
	elsif ($mode == 1) {
		s/^.*<L>//g;
		s/<.*//g;
		push @data, $_;
	}
}
print "\t ; total=$total\n";
