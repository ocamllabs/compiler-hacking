The first OCaml Labs compiler hacking session brought together around twenty people from [OCaml Labs][ocamllabs], the wider [Computer Lab][computer-lab], and [various][citrix] [companies][arm] around Cambridge for an enjoyable few hours learning about and improving the OCaml compiler toolchain, fuelled by [pizza][cherry-box] and home-made ice cream (thanks, [Philippe][philippe]!).

We benefited from the presence of a few [experienced][xclerc] [compiler][meyer] [hackers][leo], but for most of us it was the first attempt to modify the OCaml compiler internals.

The first surprise of the day was the discovery that work on the [list of projects][things-to-work-on] was underway before we even arrived!  Keen collaborators from The Internet had apparently spotted our triaged bug reports and [submitted][mantis-4323] [patches][mantis-4737] to Mantis.

### Standard library and runtime

There was an exciting moment early on when it emerged that two teams had been working independently on the same issue!  When [Jon Ludlam][ludlam] and [Euan Harris][euan] submitted a patch to add a `get_extension` function to the [`Filename`][filename-module] module they found that they had been pipped to the post by [Mike McClurg][mmclurg].  There's still the judging stage to go, though, as the patches wait [on Mantis][mantis-5807] for official pronouncement from the Inria team. 

[Vincent Bernardoff][vbmithr] also spent some time improving the standard library, [fleshing out the interface for translating between OCaml and C error codes][mantis-4919], starting from a patch by Goswin von Brederlow.

[Stephen Dolan][stedolan] looked at a [long-standing issue][mantis-1956] with names exported by the OCaml runtime that can clash with other libraries, and submitted a patch which hides the sole remaining offender for the runtime library.  As he noted in the comments, there are still a [couple of hundred][exported-names] global names without the `caml_` prefix in the `otherlibs` section of the standard library.

### Tools

There was a little flurry of work on new command-line options for the standard toolchain.

A [Mantis issue][mantis-6102] submitted by [Gabriel Scherer][gabriel] suggests adding options to stop the compiler at certain stages, to better support tools such as [OCamlfind][ocamlfind] and to make it easier to debug the compiler itself.  The Ludlam / Harris team looked at this, and submitted a patch which provoked further thoughts from Gabriel.

Vincent looked at extending [ocamldep][ocamldep] with support for suffixes other than `.ml` and `.mli`.  Since [the issue][mantis-3725] was originally submitted, `ocamldep` has acquired [`-ml-synonym` and `-mli-synonym` options][ml-synonym] that serve this purpose, so Vincent looked at supporting other suffixes in the compiler, and submitted a patch as a [new issue][mantis-6110].

The OCaml top level has a simple feature for setting up the environment —  when it starts up it looks for the file `.ocamlinit`, and executes its contents.  It's sometimes useful to skip this stage and run the top level in a vanilla environment, so [David Sheets][sheets] submitted a [patch][mantis-6071] that adds a `-no-init` option, [due for inclusion][no-init-changes] in the next release.

### Error-handling/reporting

Error handling issues saw a good deal of activity.  [Raphaël Proust][raphaël] submitted a patch to improve the [reporting of error-enabled warnings][mantis-6112]; David investigated [handling out-of-range integer literals][mantis-3582] and [return-code checking of C functions in the runtime][mantis-5350], leading to some discussions on Mantis.  Stephen submitted a patch to improve the [diagnostics for misuses of `virtual`][mantis-6182].  [Gabriel Kerneis][kerneis] and Wojciech looked at some [typos in ocamlbuild error messages][mantis-6109], and Mike opened an [issue to clarify the appropriate use of the `compiler-libs` package][mantis-6108].

### Language

The `open` operation on modules can make it difficult for readers of a program to see where particular names are introduced, so its use is sometimes discouraged.  The basic feature of making names available without a module prefix is rather useful, though, so various new features (including [local opens][local-open], [warnings for shadowing][open-warnings], and [explicit shadowing][open-bang]) have been introduced to tame its power. Stephen looked at adding a further feature, making it possible to open modules under a particular signature, so that `open M : S` will introduce only those names in `M` that are specified with `S`.  There's an [initial prototype][open-sig-tree] already, and we're looking forward to seeing the final results.

The second language feature of the evening was support for infix operators (such as the List constructor, `::`) for user-defined types, a feature that is definitely not in any way motivated by envy of Haskell.  Mike's [prototype implementation][https://github.com/mcclurmc/ocaml/tree/infix-constructors] is available, and there's an [additional patch][infix-pull-request] that brings it closer to completion.


### Next session

The next session is planned for 6pm on Wednesday 18th September 2013 at
[Makespace, Cambridge][makespace].  If you're planning to come along it'd be
helpful if you could add yourself to the [Doodle Poll][doodle].  Hope to see
you there!

[makespace]: http://makespace.org/
[doodle]: http://doodle.com/k6y2tiihkrb5vuw4

[raphaël]: http://www.cl.cam.ac.uk/~rp452/
[vbmithr]: http://github.com/vbmithr
[ludlam]: https://github.com/jonludlam
[euan]: http://www.cl.cam.ac.uk/projects/ocamllabs/people/euan.html
[mmclurg]: https://github.com/mcclurmc/
[sheets]: https://github.com/dsheets
[kerneis]: http://www.cl.cam.ac.uk/~gk338/
[meyer]: http://danmey.org/
[stedolan]: https://github.com/stedolan
[leo]: http://lpw25.net/
[xclerc]: http://www.x9c.fr/
[philippe]: http://philippewang.info/CL/
[gabriel]: http://gallium.inria.fr/~scherer/

[arm]: http://www.arm.com/
[citrix]: http://www.citrix.com/
[ocamllabs]: http://www.cl.cam.ac.uk/projects/ocamllabs/
[computer-lab]: http://www.cl.cam.ac.uk
[open-sig-tree]: https://github.com/stedolan/ocaml/commits/compiler-hacking 
[local-open]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual021.html#toc77
[open-warnings]: https://github.com/ocaml/ocaml/commit/f51bc04b55fbe22533f1075193dd3b2e52721f15
[open-bang]: https://github.com/ocaml/ocaml/commit/a3b1c67fffd7de640ee9a0791f1fd0fad965b867
[bat-pervasives]: http://ocaml-batteries-team.github.io/batteries-included/hdoc2/BatPervasives.html#6_Fundamentalfunctionsandoperators
[ml-synonym]: http://caml.inria.fr/pub/docs/manual-ocaml/depend.html#sec288
[intf-suffix]: https://github.com/ocaml/ocaml/blob/master/man/ocamlopt.m#L280,L283
[ocamldep]: http://caml.inria.fr/pub/docs/manual-ocaml/depend.html
[ocamlfind]: http://projects.camlcity.org/projects/findlib.html
[mantis-6109]: http://caml.inria.fr/mantis/view.php?id=6109
[mantis-3725]: http://caml.inria.fr/mantis/view.php?id=3725
[mantis-6110]: http://caml.inria.fr/mantis/view.php?id=6110
[mantis-4919]: http://caml.inria.fr/mantis/view.php?id=4919
[mantis-1956]: http://caml.inria.fr/mantis/view.php?id=1956
[mantis-5807]: http://caml.inria.fr/mantis/view.php?id=5807
[mantis-6102]: http://caml.inria.fr/mantis/view.php?id=6102
[mantis-6071]: http://caml.inria.fr/mantis/view.php?id=6071
[mantis-6112]: http://caml.inria.fr/mantis/view.php?id=6112
[mantis-3582]: http://caml.inria.fr/mantis/view.php?id=3582
[mantis-6182]: http://caml.inria.fr/mantis/view.php?id=6182
[mantis-6108]: http://caml.inria.fr/mantis/view.php?id=6108
[mantis-4323]: http://caml.inria.fr/mantis/view.php?id=4323
[mantis-4737]: http://caml.inria.fr/mantis/view.php?id=4737
[mantis-5350]: http://caml.inria.fr/mantis/view.php?id=5350
[exported-names]: https://gist.github.com/stedolan/6115403
[filename-module]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Filename.html
[cherry-box]: http://www.cherryboxpizza.co.uk
[things-to-work-on]: https://github.com/ocamllabs/compiler-hacking/wiki/Things-to-work-on
[no-init-changes]: https://github.com/ocaml/ocaml/blob/fadcc73c50b89ca80ecc11131c9a23dbd2c1e67a/Changes#L35
[infix-pull-request]: https://github.com/mcclurmc/ocaml/pull/1
