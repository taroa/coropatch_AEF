package AEF;
use AE;
use Guard;
use strict;
our $timeout = 0;
use base qw(Exporter);
our @EXPORT = qw(&AEFS);
=c

code serializing in AE.

example:

        use AEF;
        use AE;
        my $cv = AE::cv;
        AEFS(
                $cv,
                3, # timeout, optional not necessary
                sub{
                        my $CB = shift @_;
                        my $t;$t=AE::timer 4.5,0,sub{
                                undef $t;
                                print "1\n";
                                AEFS(sub{
                                                $t=AE::timer 4,0,sub{
                                                        print "lulu\n";
                                                        undef $t;
                                                        $CB->("haha");
                                                }
                                        }
                                )
                        };
                },
                sub{
                        my ($CB,$val) = @_;
                        my $t;$t=AE::timer 1,0,sub{
                                undef $t;
                                print "2 $val\n";
                                $CB->();
                        };


                },
        sub{
                        my $CB = shift @_;
                        my $t;$t=AE::timer 1,0,sub{
                                undef $t;
                                print "3\n";
                                $CB->();
                        };


                },
        );

        $cv->recv;



=cut
	
sub AEFS{
	return warn "no callbacks given!!\n" unless @_;
	my $cv = shift @_ if (ref $_[0] eq "AnyEvent::CondVar");
	local $timeout = shift @_ if $_[0] =~ /^\d+$/;
	for(@_){
		return warn "not valid callback!!  check your parameters\n" if (ref $_ ne "CODE");         
	}
	my @cb = (@_);
	my ($t,$watcher,$guard);
	$guard = guard { undef $watcher;};
	my $logstr = join ' -> ',caller;
	
	my $callee;$callee = sub{
		$t;
		$guard;
		if(! @cb ){
			undef $t;
			undef $guard;
			return $cv ? $cv->send : 0;
		}
#		print @cb,"\n";
		(shift @cb)->($callee,@_);

	};
	$watcher = AE::timer $timeout,0,sub{
		undef $watcher;
		warn "from $logstr\nAEF timeout, terminate....\n";
		@cb = ();
		$cv->send if $cv;
	} if $timeout;
	$t = AE::timer 0,0,$callee;
}

1;
