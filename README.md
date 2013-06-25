gossip
======

A PJSIP-based SIP client library written in ObjC using a bit more object-oriented approach.

Also contains configured sources of the open source [PJSIP](http://www.pjsip.org/) library.

### USAGE

Initializes `GSUserAgent` on application starts.

Follow the instruction here: http://gh.chakrit.net/gossip/interface_g_s_user_agent.html

### MANUAL BUILDS

Before Gossip will build, you must first build a working PJSIP binary either by:

* Running the `pjsip/build-pjsip` script in the terminal after you've checked out the code and
  all the submodules or...
* Use the pre-built binaries provided by Gossip and configure manually by copying
  `pjsip/config_site.h` to `pjsip/source/pjlib/include/pj/config_site.h`
  as this is required by Gossip when building with PJSIP.

The script should builds and configure a working PJSIP binaries for running on
actual devices. If instead you want to run Gossip applications on the **Simulator**,
you can use the `pjsip/build-pjsip-simulator` file which will do pretty much the
same thing but with compilation flags and env vars set for running it on the simulator.

### LICENSE

We do not own the license nor the copyright of the PJSIP source code which are included
with Gossip. Check the [PJSIP licensing](http://www.pjsip.org/licensing.htm) for more
information.

Otherwise the Gossip codebase is public domain. See [LICENSE](LICENSE.md) for the full
text.

