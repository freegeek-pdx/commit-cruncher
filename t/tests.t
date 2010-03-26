use Test::More tests => 7; # echo $(( $(ls t/inputs/ | grep -v "^\." | grep -v "~$" | wc -l) * 2 + 1 ))

BEGIN { use_ok( 'Commit::Cruncher' ); }

use File::Spec;
use File::Copy;

sub slurp {
    open my $F, shift;
    my @A = <$F>;
    close $F;
    my $a = join '', @A;
    return $a;
}

sub do_test {
    my $filename = shift;
    my $input = File::Spec->catfile("t","inputs",$filename);
    my $output = File::Spec->catfile("t","outputs",$filename);
    my $tmp = File::Spec->catfile("t","tmp", $filename);
    copy($input, $tmp);
    Commit::Cruncher->go($tmp);
    if(!-f $output) { # automatically generate our output
        copy($tmp, $output);
        fail($filename . "--gen");
        fail($filename . "--gen");
        return;
    }
    is(slurp($tmp), slurp($output), $filename);
    Commit::Cruncher->go($tmp); # test it twice, to ensure that if the cruncher is ran over an already-processed file that it handles it correctly.
    is(slurp($tmp), slurp($output), $filename . "x2");
}

if(!-d File::Spec->catfile("t","tmp")) {
    mkdir(File::Spec->catfile("t","tmp"));
}

my $dir = File::Spec->catfile("t","inputs");
opendir(my $dh, $dir);
my @tests = grep { !/^\./ && !/~$/ && -f "$dir/$_" } readdir($dh);
closedir $dh;
foreach(@tests) {
    do_test($_);
}

system("rm", "-fr", File::Spec->catfile("t","tmp"));
