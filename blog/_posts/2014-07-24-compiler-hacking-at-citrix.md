---
layout: post
title:  Seventh OCaml compiler hacking session (at Citrix)
date:   2014-07-24 09:00:00
---

For the seventh Cambridge OCaml compiler-hacking session we'll be meeting at [the Citrix office in the Cambridge Science Park][building-101] on 6.30pm Friday 1st August.  Thanks to Citrix for supporting and hosting the session!

We'll kick off with a demo from [Frédéric Bour][fred] of modular implicits, an OCaml extension that adds support for overloading.

If you're planning to come along, it'd be helpful if you could [**indicate interest via Doodle**](http://doodle.com/46f2bnk4xny724in) and [sign up to the mailing list](http://lists.ocaml.org/listinfo/cam-compiler-hacking) to receive updates:

**Where**:
  Citrix Systems Research & Development Ltd.  
  [Building 101][building-101]  
  Cambridge Science Park  
  Milton Road  
  Cambridge, CB4 0FY  
  United Kingdom  

**When**: 6.30pm, Friday 1st August

**Who**: anyone interested in improving OCaml. Knowledge of OCaml programming will obviously be helpful, but prior experience of working on OCaml internals isn't necessary.

**What**: fixing bugs, implementing new features, learning about OCaml internals

**Wiki**: [https://github.com/ocamllabs/compiler-hacking/wiki](https://github.com/ocamllabs/compiler-hacking/wiki)

We're defining "compiler" pretty broadly, to include anything that's part of the standard distribution, which means at least the [standard library][stdlib], [runtime][runtime], tools ([ocamldep][ocamldep], [ocamllex][ocamllex], [ocamlyacc][ocamlyacc], etc.), [ocamlbuild][ocamlbuild], the [documentation][ocaml-documentation], and the compiler itself. We'll have suggestions for [mini-projects][things-to-work-on] for various levels of experience (see also some [things we've worked on in previous sessions][things-worked-on]), but feel free to come along and work on whatever you fancy.

We'll also be ordering pizza, so if you want to be counted for food you should aim to arrive by 6.45pm.

[stdlib]: http://caml.inria.fr/pub/docs/manual-ocaml-4.01/libref/index.html
[runtime]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual024.html
[ocamldep]: http://caml.inria.fr/pub/docs/manual-ocaml-4.01/depend.html
[ocamllex]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual026.html#toc105
[ocamlyacc]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual026.html#toc107
[ocamlbuild]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual032.html
[ocaml-documentation]: http://caml.inria.fr/resources/doc/index.en.html
[things-to-work-on]: https://github.com/ocamllabs/compiler-hacking/wiki/Things-to-work-on
[things-worked-on]: https://github.com/ocamllabs/compiler-hacking/wiki/Things-previously-worked-on
[building-101]: https://maps.google.co.uk/maps?q=101+Cambridge+Science+Park+Milton+Road,+Cambridge&hl=en&ll=52.232955,0.150338&spn=0.003082,0.006947&sll=52.231717,0.144648&sspn=0.012327,0.027788&oq=101Cambrideg+Science&t=h&hq=101+Cambridge+Science+Park+Milton+Road,&hnear=Cambridge,+United+Kingdom&z=18
[fred]: https://github.com/def-lkb
