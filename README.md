gossip
======

A PJSIP-based SIP client library written in ObjC using a bit more object-oriented approach.

Also contains configured sources of the open source [PJSIP](http://www.pjsip.org/) library.

### USAGE

Initializes `GSUserAgent` on application starts.

Follow the instruction here: http://gh.chakrit.net/gossip/interface_g_s_user_agent.html

### BUIDLING PJSIP

Before Gossip will build on **iOS device**, you must do one of the following...

* Run the `pjsip/build-pjsip` command in the terminal after you've checked out the code or...
* Copy the file `pjsip/config_site.h` to `pjlib/include/pj/config_site.h` as this is required
  by both PJSIP and Gossip and use the PJSIP builds already provided by Gossip.

For building on **iOS simulator**, you need to...

* Run `pjsip/build-pjsip_simulator`. It will compile by using **ARCH=i386** instead of **armv7**, plus some other configurations ( **DEVPATH** and **CFLAGS** to be precise ). You will get new `.a` files in `pjsip/lib`, and new files in `pjsip/source`.
* Finally run `Gossip.xcodeproj` and build in iPhone/iPad simulator. 

**NOTE1:** You will have to re-compile again if you want to switch back to build on device.

**NOTE2:** The `libGossip.a` already provided is for device.

### LICENSE

This code is in public domain.

We do not own the license nor the copyright of the PJSIP source code which are included
with Gossip. Check the [PJSIP licensing](http://www.pjsip.org/licensing.htm) for more
information.