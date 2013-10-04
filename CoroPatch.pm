package CoroPatch;
use Coro;
use Coro::State;
#use Data::Dumper;
our %thrs,$__DIE__;

$Coro::State::DIEHOOK = sub{
	return if $^S;	
	warn ">>>",@_;
	$__DIE__->(@_) if ref $__DIE__ eq "CODE";
#	warn "Coro::current: ",$Coro::current,"\n";
#	warn Dumper(\@thrs);
	if(my $t = delete $thrs{$Coro::current}){			
		warn "terminate coro...\n";
		$t->terminate;
	}
};
	sub AEasync(&@){
#		print "AEasync..\n";
		my($cb,@param) = @_;
		Coro::async{
			$thrs{$Coro::current} = $Coro::current;
			END{
				delete $thrs{$Coro::current};
			}
			$cb->(@_);
		} @param;
	}

	sub import{
		shift @_;
		$__DIE__ = {@_}->{__DIE__} || sub{};
		*main::async = \&AEasync;
	}
1;
