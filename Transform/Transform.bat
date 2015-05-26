@rem = ' PERL for Windows NT - ccperl must be in search path
@echo off
perl %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
goto waitDueToErrors
@rem ';

BEGIN {
	$0=~/^(.+[\\\/])[^\\\/]+[\\\/]*$/;
	my $physicalDir= $1 || "./";
	chdir($physicalDir);
}

use Tk;
use Data::Dumper;

my $InputFile = 'C:/Users/e_nbienv/Desktop/Transform/40A1_40A2.csv';
my $OutputFile = 'C:/Users/e_nbienv/Desktop/Transform/truc.csv';
my $Separateur = ';';
# my $InputFile;
# my $OutputFile;
# my $Separateur;


my %Balise;

my $InputTypes = [ ['TXT files', '.xls'],['CSV files', '.csv'],['All Files', '*'],];
my $OutputTypes = [ ['CSV files', '.csv'],['All Files', '*'],];

my $mw = MainWindow->new(-title => 'Transform');
$mw->minsize(400,200);

my $ButtonFrame = $mw->Frame()->pack(-fill =>'x', -side => 'bottom', -padx => 10, -pady => 10);
my $InputFrame = $mw->Frame()->pack(-fill =>'both', -expand => 1, -side => 'top', -padx => 10, -pady => 10);
my $OutputFrame = $mw->Frame()->pack(-fill =>'both', -expand => 1, -side => 'top', -padx => 10, -pady => 10);
my $SepareFrame = $mw->Frame()->pack(-fill =>'both', -expand => 1, -side => 'top', -padx => 10, -pady => 10);

$InputFrame->Entry(-textvariable => \$InputFile)->pack(-side => "left", -expand => 1, -fill => 'x');
$InputFrame->Button(-text => ' ... ', -command => sub { $InputFile = $mw->getOpenFile(-filetypes => $InputTypes, -defaultextension => '.txt');})->pack(-side => "left", -pady => 10);
$OutputFrame->Entry(-textvariable => \$OutputFile)->pack(-side => "left", -expand => 1, -fill => 'x');
$OutputFrame->Button(-text => ' ... ', -command => sub { $OutputFile = $mw->getSaveFile(-filetypes => $OutputTypes, -defaultextension => '.csv');})->pack(-side => "left", -pady => 10);
$SepareFrame->Label(-text => 'Separator : ')->pack(-side => "left");
$SepareFrame->Entry(-textvariable => \$Separateur, -validate => 'key', -validatecommand => \&Validate, -width => 2)->pack(-side => "left");

my $ButtonLaunch = $ButtonFrame->Button(-text => 'Launch', -command => \&Launch)->pack(-ipadx => 10, -ipady => 10, -expand => 1, -side => 'left');
my $ButtonQuit = $ButtonFrame->Button(-text => 'Exit', -command => sub{exit;})->pack(-ipadx => 10, -ipady => 10, -expand => 1, -side => 'left');

MainLoop;

sub Launch{
	my $Balnum = 0;
	$ButtonLaunch->configure(-state => 'disabled');
	$ButtonQuit->configure(-state => 'disabled');
	
	my $message = '';
	if (!-e $InputFile){$message.="$InputFile don't exist\n";}
	elsif (!$InputFile=~/\.(csv|txt)$/){$message.="$InputFile have not good type\n";}
	if (!$OutputFile=~/\.csv$/){$message.="$OutputFile have not good type\n";}
	if ($Separateur eq ''){$message.= "separator empty";}
	
	if($message eq ''){
		my $Header = '';
		my $Body = '';
		my $Footer = '';
		my $State = '';
		open INFILE, "<$InputFile" or die "impossible to open $InputFile";
		while (my $ligne = <INFILE>){
			if ($ligne =~ /^<BEGIN_HEADER>/){ $State = 'Header';}
			elsif ($ligne =~ /^<BEGIN_BODY>/){ $State = 'Body';}
			elsif ($ligne =~ /^<BEGIN_FOOTER>/){ $State = 'Footer';}
			elsif ($State eq 'Header'){$Header.=$ligne; }
			elsif ($State eq 'Body'){$Body.=$ligne; }
			elsif ($State eq 'Footer'){$Footer.=$ligne; }
			else {
				$ligne =~ s/^\"(.*?)\"/$1/;
				$ligne =~ s/[;\n]+$//g;
				my ($bal, $inst) = split('=', $ligne);
				$Balise{++$Balnum}{balise}=$bal;
				my @inst = split($Separateur, $inst);
				foreach (@inst){$Balise{$Balnum}{inst}{$_}=() if $_  ne '';};
			}
		}
		
		close INFILE;
		
		
		my $TempTexte = $Body;
		foreach my $indice (keys %Balise){
			my $Temp2Texte = '';
			my $AddTexte = $TempTexte;
			my $bal = $Balise{$indice}{balise};
			foreach (sort {$a cmp $b} keys %{$Balise{$indice}{inst}}){
				my $Temp3Texte = $AddTexte;
				$Temp3Texte =~ s/$bal/$_/g;
				$Temp2Texte .= $Temp3Texte;
			}
			$TempTexte = $Temp2Texte;
		}
		
		open OUTFILE, ">$OutputFile" or die "impossible to open $OutputFile";
		print OUTFILE $Header . $TempTexte . $Footer;
		close OUTFILE;
	}
	else{
		$mw->messageBox(-icon => 'error', -title => 'Error', -type => 'OK', -message => $message,);
	}
	
	$ButtonLaunch->configure(-state => 'normal');
	$ButtonQuit->configure(-state => 'normal');
}

sub Validate{
	my ($text) = @_;
	if(length($text)>1){return 0;}
	else{ return 1;}
}

__END__
:waitDueToErrors
pause