# netlib
So, what is this?  Netlib is a library for network access that targets 8-bit systems.  It is designed to be included in your asssembly-language projects.  My compiler of choice in 2006 was DASM, so the syntax is DASM-leaning, but it should be easily compiled using your assembler of choice.  This is the library Leif Bloomquist used in his famous "Netrunner" game, hats off to Leif for finding something useful to do with it :)

# What should you know before you use it?
* There is a newer version in the works that uses pointers instead of copying buffers around
* TCP support is experimental at best, UDP won't catch your C64 on fire
* Failed ARP queries can be an issue if you don't have a catcher.
* ETH64/TFE/RR-Net support has been tested, but RR-Net won't work in Vice < 3.2 due to a Vice bug.



