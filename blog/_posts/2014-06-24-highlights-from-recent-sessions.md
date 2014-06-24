---
layout: post
title:  Highlights from recent sessions
date:   2014-06-24 02:00:00
---

## Highlights from recent sessions

With the [next compiler hacking meeting][sixth-compiler-hacking] due to take place in a couple of days it's time for a look back at some results from our last couple of sessions.

<a name="the-front-end"></a>
### The front end

<figure style="float: right; padding: 15px; width: 350px">
<img style="width: 350px" src="https://farm3.staticflickr.com/2756/4150220583_57a993cc61_z_d.jpg" alt="Camel front end" /><br/>
<figcaption><center><small>(<a href="https://www.flickr.com/photos/paperpariah/4150220583"><i>today I stared a camel in the face</i></a> by <a href="https://www.flickr.com/photos/paperpariah/">Adam Foster</a>)</small></center></figcaption>
</figure>

The front end (i.e. [the parser and type checker][rwo-frontend]) saw a number of enhancements.

<a name="succinct-functor-syntax"></a>
#### Succinct functor syntax

Syntax tweaks are always popular, if [often contentious][wadlers-law].   However, reaching agreement is significantly easier when adding syntax is a simple matter of extending an existing correspondence between two parts of the language.  For example, it was clear which syntax to use when adding support for [lazy patterns][lazy-patterns]: since patterns generally mirror the syntax for the values they match, patterns for destructing lazy values should use the same `lazy` keyword as the expressions which construct them.

A second correspondence in OCaml's syntax relates modules and values.  Module names and variables are both bound with `=`; module signatures and types are both ascribed with `:`; module fields and record fields are both projected with `.`.  The syntax for functors and functions is also similar, but the latter offers a number of shortcuts not available in the module language; you can write

```ocaml
fun x y z -> e
```

instead of the more prolix equivalent:

```ocaml
fun x -> fun y -> fun z -> e
```

but multi-argument functors must be written out in full:

```ocaml
functor (X : R) -> functor (Y : S) -> functor (Z : T) -> M
```

In February's meeting, [Thomas][thomas] wrote a [patch][functor-syntax-pull] that adds an analogue of the shorter syntax to the module language, allowing the repeated `functor` to be left out:

```ocaml
functor (X : R) (Y : S) (Z : T) -> M
```

The patch also adds support for a corresponding abbreviation at the module type level.  Defining the type of a multi-argument functor currently involves writing a rather clunky sequence of `functor` abstractions:

```ocaml
module type F = functor (X : R) -> functor (Y : S) -> functor (Z : T) -> U
```

With Thomas's patch all but the first occurrence of `functor` disappear:

```ocaml
module type F = functor (X : R) (Y : S) (Z : T) -> U
```

Since Thomas's patch has been merged into trunk, you can try out the new syntax using the [4.02.0 beta][ocaml-402-announce], which is available as a compiler switch in the OPAM repository:

```bash
opam switch 4.02.0+trunk
```

The next step is to find out whether the verbose syntax was a symptom or a cause of the infrequency of higher-order functors in OCaml code.  Will we see a surge in the popularity of higher-order modules as the syntax becomes more accommodating?

<a name="integer-ranges"></a>
#### Integer ranges

[David][sheets] started work on extending OCaml's range patterns, which currently support only characters, to support [integer ranges][integer-range-patterns].  For example, consider the following [code from MLDonkey][ml-donkey-example]:

```ocaml
match mdn with
  None       when h >= 0 && h <= 23 -> Some h
| Some false when h > 0 && h <= 11  -> Some h
| Some false when h = 12            -> Some 0
| Some true  when h > 0 && h <= 11  -> Some (h + 12)
| Some true  when h = 12            -> Some 12
| Some _                            -> None
| None                              -> None
```

Although this is fairly clear, it could be made even clearer if we had a [*less* powerful language][rule-of-least-power] for expressing the tests involving `h`.  Since the whole OCaml language is available in the `when` guard of a case, the reader has to examine the code carefully before concluding that the tests are all simple range checks.  Perhaps worse, using guards inhibits the useful checks that the OCaml compiler performs to determine whether patterns are exhaustive or redundant.  David's patch makes it possible to rewrite the tests without guards, making the simple nature of the tests on `h` clear at a glance (and making it possible once again to check exhaustiveness and redundancy):

```ocaml
match mdn, h with
  None      , 0..23
| Some false, 1..11 -> Some h
| Some false, 12    -> Some 0
| Some true , 1..11 -> Some (h + 12)
| Some true , 12    -> Some 12
| _                 -> None
```

The work on range patterns led to a robust exchange of views about which other types should be supported -- should we support any enumerable type (e.g. variants with nullary constructors)? or perhaps even any ordered type (e.g. floats or strings)?  For the moment, there seems to be a much clearer consensus in favour of supporting integer types than there is for generalising range patterns any further.

<a name="extensible-variants"></a>
#### Extensible variants

Since the compiler hacking group only meets for an evening every couple of months or so, most of the [projects we work on][things-to-work-on] are designed so that it's possible to implement them in a few hours.  [Leo][lpw25]'s proposal for extensible variants is a notable exception, [predating][open-types-original-proposal] both the [compiler hacking group][inaugural] and [OCaml Labs][ocaml-labs-announcement] itself.

Extensible variants generalise exceptions: with Leo's patch the exception type `exn` becomes a particular instance of a class of types that can be defined by the user rather than a special builtin provided by the compiler:

```ocaml
(* Define an extensible variant type *)
type exn = ..

(* Extend the type with a constructor *)
type exn += Not_found

(* Extend the type with another constructor *)
type exn += Invalid_argument of string
```

Even better, extensible variants come with all the power of regular variant types: they can take type parameters, and even support GADT definitions:

```ocaml
(* Define a parameterised extensible variant type *)
type 'a error = ..

(* Extend the type with a constructor *)
type 'a error = Error of 'a

(* Extend the type with a GADT constructor *)
type 'a error : IntError : int -> int error
```

On the evening of the last compiler hacking meeting, Leo [completed][open-types-completed] the patch; shortly afterwards it was [merged to trunk][open-types-merge], ready for inclusion in [OCaml 4.02][ocaml-402-announce]!

Extensible variants are a significant addition to the language, and there's more to them than these simple examples show.  A forthcoming post from Leo will describe the new feature in more detail.  In the meantime, since they've been merged into the 4.02 release candidate, you can try them out with OPAM:

```bash
opam switch 4.02.0+trunk
```

<a name="lazy-record-fields"></a>
#### Lazy record fields

Not everything we work on makes is destined to make it upstream.  A few years ago, [Alain Frisch][alain] [described][lazy-records-lexifi] an OCaml extension in use at [Lexifi] for marking record fields lazy, making it possible to delay the evaluation of initializing expressions without writing the `lazy` keyword every time a record is constructed.  Alain's post was received enthusiastically, and lazy record fields seemed like an obvious candidate for inclusion upstream, so in April's meeting Thomas put together a [patch][lazy-records-pull] implementing the design.  Although the OCaml team decided not to merge the patch, it led to an enlightening [discussion][lazy-records-comments] with comments from several core developers, including Alain, who described [subsequent, less positive, experience with the feature at Lexifi][lazy-records-comments], and Xavier, who explained the [rationale underlying the current design][lazy-records-xavier].

<a name="back-end"></a>
### The back end

<figure style="float: right; padding: 15px; width: 350px">
<img style="width: 350px" src="http://farm4.staticflickr.com/3157/2877029132_b34943c8d7_z_d.jpg" alt="Camel back end" /><br/>
<figcaption><center><small>(<a href="http://www.flickr.com/photos/16230215@N08/2877029132"><i>Relief</i></a>
by <a href="http://www.flickr.com/photos/h-k-d/">Hartwig HKD</a>)</small></center></figcaption>
</figure>

The OCaml back end (i.e. the [code generation portion of the compiler][rwo-backend]) also saw a proposed enhancement.

<a name="constant-arithmetic-optimization"></a>
#### Constant arithmetic optimization

Stephen submitted a [patch][arithmetic-optimization-pull] improving the generated code for functions that perform constant arithmetic on integers.

In OCaml, integers and characters are [represented as shifted immediate values][ml-value-representations-rwo], with the least significant bit set to distinguish them from pointers.  This makes some arithmetic operations [a little more expensive][rwo-extra-instructions].  For example, consider a function that `int_of_digits` that builds an integer from three character digits:

```ocaml
int_of_digits '3' '4' '5' => 345
```

We might define `int_of_digits` as follows:

```ocaml
let int_of_digits a b c = 
  100 * (Char.code a - Char.code '0') + 
   10 * (Char.code b - Char.code '0') +
    1 * (Char.code c - Char.code '0')
```

Passing the `-dcmm` flag to ocamlopt shows the results of compiling the function to the [C-- intermediate language][cmm]. 

```bash
ocamlopt -dcmm int_of_digits.ml
```

The generated code has the following form (reformatted for readability):

```c
200 * ((a - 96) >> 1) +
 20 * ((b - 96) >> 1) +
  2 * ((c - 96) >> 1) + 1
```

The right shifts convert the tagged representation into native integers, and the final `+ 1` converts the result back to a tagged integer.

Stephen's patch floats the arithmetic operations that involve constant operands outwards, eliminating most of the tag-munging code in favour of a final correcting addition:

```c
(a * 100) +
(b * 10) +
 c - 10766
```

Although these changes are not yet merged, you can easily try them out, thanks to Anil's script that [makes compiler pull requests available as OPAM switches][opam-switches]:

```
opam switch 4.03.0+pr17
```

<a name="standard-library"></a>
### Standard library and beyond

<figure style="float: right; padding: 15px; width: 350px">
<img style="width: 350px" src="http://i.imgur.com/KKsM0tu.jpg" alt="Camel library" /><br/>
<figcaption><center><small>(Literary advocate <a href="http://www.papertigers.org/wordpress/interview-with-dashdondog-jamba-mongolian-author-and-literacy-advocate/">Dashdondog Jamba</a>, and his mobile library, described in <a href="http://www.bookdepository.com/My-Librarian-Is-a-Camel-Margriet-Ruurs/9781590780930"><i>My librarian is a camel</i></a>)</small></center></figcaption>
</figure>

Our compiler hacking group defines "compiler" rather broadly.  As a result people often work on improving the standard library and tools as well as the compiler proper.  For example, in recent sessions, David added a small patch to [expose the is\_inet6\_addr][is_inet6_addr_mantis] function, and [Philippe][philippe] proposed [a patch that eliminates unnecessary bounds checking][bounds-check-pull] in the buffer module.  The last session also saw [Raphaël][raphael] and Simon push a [number][acme-merlin-1] [of][acme-merlin-2] [patches][acme-merlin-3] for integrating [merlin][merlin] with the [acme][acme] editor to OPAM, improving OCaml support in Plan 9.

## Next session

The compiler hacking group is open to anyone with an interest in contributing to the OCaml compiler.  If you're local to Cambridge, you're welcome to join us at the [next session][sixth-compiler-hacking]!

[sixth-compiler-hacking]: http://ocamllabs.github.io/compiler-hacking/2014/06/20/sixth-compiler-hacking-session.html
[bounds-check-pull]: https://github.com/ocaml/ocaml/pull/15
[arithmetic-optimization-pull]: https://github.com/ocaml/ocaml/pull/17
[functor-syntax-pull]: https://github.com/ocaml/ocaml/pull/16
[integer-division-fix]: http://caml.inria.fr/mantis/view.php?id=6042
[pdenys]: https://github.com/pdenys
[is_inet6_addr_mantis]: http://caml.inria.fr/mantis/view.php?id=6105
[acme]: http://en.wikipedia.org/wiki/Acme_%28text_editor%29
[merlin]: https://github.com/the-lambda-church/merlin
[mirage]: http://www.openmirage.org/
[integer-range-patterns]: https://github.com/ocamllabs/compiler-hacking/wiki/Things-to-work-on#wiki-integer-range-patterns
[thomas]: http://gazagnaire.org
[sheets]: http://github.com/dsheets
[ml-donkey-example]: https://github.com/ygrek/mldonkey/blob/03896bfc/src/utils/ocamlrss/rss_date.ml#L195-L202
[tofte-92]: http://www.cs.cmu.edu/~rwh/courses/modules/papers/tofte92/paper.pdf‎
[tofte]: https://www.itu.dk/people/tofte/
[cambridge-brewery]: http://www.cambridge-brewery.co.uk/
[cherry-box]: http://cherryboxpizzaonline.com
[ml-value-representations-rwo]: https://realworldocaml.org/v1/en/html/memory-representation-of-values.html#table20-1_ocaml
[rwo-extra-instructions]: https://realworldocaml.org/v1/en/html/memory-representation-of-values.html#idm181610127856
[char-identity]: https://github.com/ocaml/ocaml/blob/def31744/stdlib/char.mli#L16
[leffe]: http://www.leffe.com/en
[opam-switches]: http://anil.recoil.org/2014/03/25/ocaml-github-and-opam.html
[rwo-frontend]: https://realworldocaml.org/v1/en/html/the-compiler-frontend-parsing-and-type-checking.html
[rwo-backend]: https://realworldocaml.org/v1/en/html/the-compiler-backend-byte-code-and-native-code.html
[module-type-monoid]: http://cstheory.stackexchange.com/questions/20032/is-there-a-language-with-strong-typed-interfaces-where-types-resolution-are-del/20036#20036
[integer-ranges]: https://github.com/ocamllabs/compiler-hacking/wiki/Things-to-work-on#integer-range-patterns
[rule-of-least-power]: http://en.wikipedia.org/wiki/Rule_of_least_power
[open-types-original-proposal]: https://sympa.inria.fr/sympa/arc/caml-list/2012-01/msg00050.html
[large-projects]: https://github.com/ocamllabs/compiler-hacking/wiki/Things-to-work-on#large-projects
[things-to-work-on]: https://github.com/ocamllabs/compiler-hacking/wiki/Things-to-work-on
[lpw25]: http://www.lpw25.net/
[inaugural]: http://ocamllabs.github.io/compiler-hacking/2013/09/17/compiler-hacking-july-2013.html
[ocaml-labs-announcement]: http://anil.recoil.org/2012/10/19/announcing-ocaml-labs.html
[open-types-mantis]: http://caml.inria.fr/mantis/view.php?id=5584
[open-types-completed]: http://caml.inria.fr/mantis/view.php?id=5584#c11335
[open-types-merge]: https://github.com/ocaml/ocaml/commit/b56dc4b3df8d022b54f40682a9d5d4168c690413
[ocaml-402-announce]: http://alan.petitepomme.net/cwn/2014.05.27.html#2
[naggum-rant]: http://www.schnada.de/grapt/eriknaggum-xmlrant.html
[ocaml-distribution]: http://caml.inria.fr/ocaml/release.en.html
[philippe]: http://philippewang.info/
[raphael]: http://www.cl.cam.ac.uk/~rp452/
[acme-merlin-1]: https://github.com/ocaml/opam-repository/pull/1961
[acme-merlin-2]: https://github.com/ocaml/opam-repository/pull/1968
[acme-merlin-3]: https://github.com/ocaml/opam-repository/pull/1972
[wadlers-law]: http://www.haskell.org/haskellwiki/Wadler%27s_Law
[lazy-patterns]: http://caml.inria.fr/pub/docs/manual-ocaml-400/manual021.html#toc73
[lazy-records-lexifi]: http://www.lexifi.com/blog/ocaml-extensions-lexifi-semi-implicit-laziness
[alain]: http://alain.frisch.fr/
[lexifi]: http://lexifi.com/
[lazy-records-comments]: https://github.com/ocaml/ocaml/pull/48#issuecomment-41758626
[lazy-records-pull]: https://github.com/ocaml/ocaml/pull/48
[lazy-records-alain]: https://github.com/ocaml/ocaml/pull/48#issuecomment-41769516
[lazy-records-xavier]: https://github.com/ocaml/ocaml/pull/48#issuecomment-41779525
[cmm]: https://github.com/ocaml/ocaml/blob/trunk/asmcomp/cmm.mli
