---
layout: post
title:  Sixth OCaml compiler hacking session
date:   2014-06-20 18:50:00
---

(Update (2014-06-24): Stephen Dolan will be giving a demo of multicore OCaml!)

It's time for the sixth Cambridge OCaml compiler-hacking session!  We'll be meeting in the [Computer Lab](http://www.cl.cam.ac.uk/) again next Wednesday evening (25th June).

If you're planning to come along, it'd be helpful if you could [*indicate interest via Doodle*](http://doodle.com/2ps9gunbkiy3tp6i) and [*sign up to the mailing list*](http://lists.ocaml.org/listinfo/cam-compiler-hacking) to receive updates:

*Where*: Room [FW11](http://www.cl.cam.ac.uk/research/dtg/openroommap/static/?s=FW11&amp;labels=1), [Computer Laboratory, Madingley Road](http://www.cl.cam.ac.uk/directions/)

*When*: 6.30pm, Wednesday 25th June

*Who*: anyone interested in improving OCaml. Knowledge of OCaml programming will obviously be helpful, but prior experience of working on OCaml internals isn't necessary.

*What*: fixing bugs, implementing new features, learning about OCaml internals

*Wiki*: [https://github.com/ocamllabs/compiler-hacking/wiki](https://github.com/ocamllabs/compiler-hacking/wiki)

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
[multicore]: http://www.cl.cam.ac.uk/projects/ocamllabs/tasks/compiler.html#Multicore