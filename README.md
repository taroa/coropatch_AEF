coropatch_AEF
=============

some tool for using Coro in AE without using eval inside Coros other than AE loop Coro 、 and AnyEvent code serialization.
they're just examples of how to do that, maybe quite buggy and should not be used in serious situation.

CoroPatch: 

it's not very well documented. but when you use AnyEvent as your platform base, and want to combine Coro for it's
useful features ( semaphore、dedicated cede_to another Coro and so on), original AE loop will reside inside a Coro thread.
AND when you want to pick DIE, things are getting tricky. you CANNOT kill the AE loop Coro for that will crash your program.
Just keep track of Coros you created other than AE loop Coro, and hen call $coro->terminate in DIEHOOK, that's all.

keep in mind you should follow what AE and Coro author recommends, use eval inside each async{} to prevent program exit on dying.

this pm file just shows another (complicated) way to deal with this problem, no big deal.




AEF:

code serialization in AE environment, just passing the sub needs to be executed to the current sub, and then run it, so it's 
a recursive way, main benefit is you can push subs you need to run and then run them one by one.
you may want to take a look at Combinator created by Cindy Wang which offers far more sophisticated features and troublesome 
macro-like syntax ( it's in deed really MACRO inside perl ! XDrz ). hope this might help some :)
