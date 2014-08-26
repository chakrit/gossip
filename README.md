# GOSSIP

An Objective-C convenience wrapper around the PJSIP client library. In addition to that,
the GOSSIP repository also contains:

* [PJSIP][0] - Original source mirror as git submodule so we can track commits that GOSSIP
  will compile against.

* Utility script for compiling PJSIP - This automates the process described by the
  [Getting Started - iPhone][2] guide on the PJSIP website.

* Pre-built fat PJSIP binaries - These run on armv7, armv7s, arm64 and i386 out of the
  box. You can also build each architecture individually by yourself using the
  aforementioned script.

# USAGE

1. Clone the GOSSIP sources.
2. Make sure to also clone PJSIP submodule as we need the PJSIP headers.
3. (optional) Use the provided script to build your custom version of PJSIP.
4. Adds the GOSSIP xcodeproj as reference to your main application project. Either
   workspace reference or as a subproject should works.
5. Initializes `GSUserAgent` on application starts.

Check the [GSUserAgent documentation][5] for further instructions.

Example of a successful `git clone` command:

```bash
git clone git://github.com/chakrit/gossip.git
cd gossip
git submodule init
git submodule update --recursive
```

I can add support for CocoaPods if there is demand. I have opted not to work on this
just yet due to the need to reference PJSIP headers (which in turn has a lot of
architecture-specific macro `#ifdefs` that sometimes break badly.)

# BUILD PJSIPs

Before GOSSIP will build, you must first have a working PJSIP binary either by:

* Using the pre-built binaries already available in this repository. In which case, you
  should not need to do anything.
* Use the `gossip/pjsip/pjsip` script to build a version of PJSIP that suit your needs.

For example, to create a new build for `arm64`, try the following:

```sh
$ cd gossip
$ cd pjsip
$ ./pjsip arm64
$ ./pjsip info arm64
```

Or to create new fat binaries on your machine, try the following:

```sh
cd gossip
cd pjsip
./pjsip all
./pjsip info .
```

# LICENSE

We do not own the license nor the copyright of the PJSIP source code and derivatives which
are required for GOSSIP to function. Check the
[PJSIP licensing][1] page for more information.

Otherwise the Gossip codebase is public domain. See the [LICENSE.md](LICENSE.md) file for
the full details.

# SUPPORT

Please file a [new GitHub issue][3]. I am also available at service [at] chakrit.net or
over Twitter as [@chakrit][4].

# CONTRIBUTORS

```
   144	Chakrit Wichian
     5	Hlung
     1	Thane Brimhall
```


[0]: http://www.pjsip.org/
[1]: http://www.pjsip.org/licensing.htm
[2]: https://trac.pjsip.org/repos/wiki/Getting-Started/iPhone
[3]: https://github.com/chakrit/gossip/issues/new
[4]: http://twitter.com/chakrit
[5]: http://gh.chakrit.net/gossip/interface_g_s_user_agent.html
