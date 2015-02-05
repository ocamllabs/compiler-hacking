---
layout: post
title:  Ninth OCaml compiler hacking evening (back in the lab, with a talk from Oleg)
date:   2015-02-05 12:00:00
---

We'll be meeting in the Computer Lab next Tuesday for another evening of compiler hacking.  All welcome!  Please **[add yourself to the Doodle poll](http://doodle.com/zxmeyn2ih92mke85)** if you're planning to come along, and sign up to the [mailing list](http://lists.ocaml.org/listinfo/cam-compiler-hacking) to receive updates.

### Talk: Generating code with polymorphic let (Oleg Kiselyov)

This time we'll be starting with a talk from [Oleg Kiselyov](http://okmij.org/ftp):

<blockquote>
<h4>Generating code with polymorphic let</h4>

<p>One of the simplest ways of implementing staging is source-to-source
translation from the quotation-unquotation code to code-generating
combinators. For example, MetaOCaml could be implemented as a
pre-processor to the ordinary OCaml. However simple, the approach is
surprising productive and extensible, as Lightweight Modular Staging
(LMS) in Scala has demonstrated. However, there is a fatal flaw:
handling quotations that contain polymorphic let. The translation to
code-generating combinators represents a future-stage let-binding with
the present-staging lambda-binding, which is monomorphic. Even if
polymorphic lambda-bindings are allowed, they require type
annotations, which precludes the source-to-source translation.</p>

<p>We show the solution to the problem, using a different translation. It
works with the current OCaml. It also almost works in theory,
requiring a small extension to the relaxed value
restriction. Surprisingly, this extension seems to be exactly the one
needed to make the value restriction sound in a staged language with
reference cells and cross-stage-persistence.</p>

<p>The old, seems completely settled question of value restriction is
thrown deep-open in staged languages. We gain a profound problem to
work on.</p>
</blockquote>

### (Approximate) schedule

**6pm** Start, set up  
**6.30pm** Talk  
**7pm** Pizza  
**7.30pm-10pm** Compiler hacking  

### Further details

**Where**:
  Room [FW11](http://www.cl.cam.ac.uk/research/dtg/openroommap/static/?s=FW11&amp;labels=1), [Computer Laboratory, Madingley Road](http://www.cl.cam.ac.uk/directions/)

**When**: 6pm, Tuesday 10th February

**Who**: anyone interested in improving OCaml. Knowledge of OCaml programming will obviously be helpful, but prior experience of working on OCaml internals isn't necessary.

**What**: fixing bugs, implementing new features, learning about OCaml internals.

**Wiki**: [https://github.com/ocamllabs/compiler-hacking/wiki](https://github.com/ocamllabs/compiler-hacking/wiki)

We're defining "compiler" pretty broadly, to include anything that's part of the standard distribution, which means at least the [standard library][stdlib], [runtime][runtime], tools ([ocamldep][ocamldep], [ocamllex][ocamllex], [ocamlyacc][ocamlyacc], etc.), [ocamlbuild][ocamlbuild], the [documentation][ocaml-documentation], and the compiler itself. We'll have suggestions for [mini-projects][things-to-work-on] for various levels of experience (see also some [things we've done on previous evenings][things-worked-on]), but feel free to come along and work on whatever you fancy.

We'll be ordering pizza, so if you want to be counted for food you should aim to arrive by 6pm.

[stdlib]: http://caml.inria.fr/pub/docs/manual-ocaml-4.01/libref/index.html
[runtime]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual024.html
[ocamldep]: http://caml.inria.fr/pub/docs/manual-ocaml-4.01/depend.html
[ocamllex]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual026.html#toc105
[ocamlyacc]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual026.html#toc107
[ocamlbuild]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual032.html
[ocaml-documentation]: http://caml.inria.fr/resources/doc/index.en.html
[things-to-work-on]: https://github.com/ocamllabs/compiler-hacking/wiki/Things-to-work-on
[things-worked-on]: https://github.com/ocamllabs/compiler-hacking/wiki/Things-previously-worked-on

