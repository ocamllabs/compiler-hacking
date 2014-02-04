---
layout: post
title:  How to handle success
date:   2014-02-04 16:05:05
---

(Update: there's a [Mantis issue open](http://caml.inria.fr/mantis/view.php?id=6318) to discuss this proposal.)

OCaml's `try` construct is good at dealing with exceptions, but not so good at handling the case where no exception is raised.  This post describes a simple extension to `try` that adds support for handling the "success" case.

Here's an example of code that benefits from the extension.  On a recent [caml-list][caml-list] thread, [Simon Cruanes][simon-cruanes] posted [the following function][simon-cruanes-message] for iterating over a stream:

> ```ocaml
> let rec iter_stream f s =
>   match (try Some (MyStream.get s) with End_of_stream -> None) with
>   | None -> ()
>   | Some (x, s') ->
>       f x;
>       iter_stream f s'
> ```

For each element of a stream, `iter_stream` wraps the element with `Some`, then unwraps it again and passes it to `f`.  At first glance, wrapping and immediately unwrapping in this way seems like needless obfuscation.  However, moving the last two lines out of the body of the `try` in this way serves two essential purposes: it turns the recursive call to `iter_stream` into a tail call, and it allows exceptions raised by `f` to propagate.  More generally, this use of options makes it easy to specify the *success continuation* of a `try` expression, i.e. the piece of code that receives the value of the body when no exception is raised.

As Simon notes, the `match (try Some ...)` idiom is widely used in OCaml code.  Examples can be found in the source of [lwt][lwt-match-try-some], [batteries][batteries-match-try-some], [liquidsoap][liquidsoap-match-try-some], [sexplib][sexplib-match-try-some], [opa][opa-match-try-some], [uri][uri-match-try-some], [coq][coq-match-try-some], [unison][unison-match-try-some], and many other packages.  

In response to Simon's message, [Oleg][oleg] pointed out [a solution][oleg-response]: the 2001 paper [Exceptional Syntax][exceptional-syntax]  ([Benton][benton] and [Kennedy][kennedy]) extends `try` with a `let`-like binding construct that supports the success continuation idiom directly without the need for the option value.

<!-- Perhaps expand on Exceptional Syntax. -->

This post describes a patch to OCaml that implements a variant of Benton and Kennedy's design called *handler case*.  Like Exceptional Syntax, handler case extends `try` with explicit success continuation handling.  However, unlike Exceptional syntax, handler case uses `match` binding for both the success continuation and the exception-handling clauses.  Here's the extended `try` syntax:

```ocaml
try expr
with pattern_1 -> expr_1
   | ...
   | pattern_n -> expr_n
   | val pattern_1' -> expr_1'
   | ...
   | val pattern_n' -> expr_n'
```

As in [current OCaml][try-language-manual], the clauses `pattern_1 -> expr_1` ... `pattern_n -> expr_n` handle exceptions raised during the evaluation of `expr`.  The clauses  `val pattern_1' -> expr_1'` ... `val pattern_n' -> expr_n'` handle the case where no exception is raised; in this case the value of `expr` is matched against `pattern_1'` ... `pattern_n'` to select the expression to evaluate to produce the result value.  (The actual syntax is implemented slightly more permissively: it allows value-matching and exception-matching clauses to be freely interleaved.)

Using handler case we can rewrite `iter_stream` to remove the extraneous option value:

```ocaml
let rec iter_stream f s =
  try MyStream.get s
  with End_of_stream -> ()
     | val (x, s') -> f x;
                      iter_stream f s'
```

We don't need to look far to find other code that benefits from the new construct.  Here's a function from the [Big_int][big-int-example] module in the standard library: 

```ocaml
let int_of_big_int bi =
  try let n = int_of_nat bi.abs_value in
    if bi.sign = -1 then - n else n
  with Failure _ ->
    if eq_big_int bi monster_big_int then monster_int
    else failwith "int_of_big_int"
```

The core of the function --- the call to `int_of_nat` --- is rather buried in the complex control flow.  There are two `if`-`then`-`else` constructs, a `let` binding, and a `try` expression with a complex body.  Using handler case we can disentangle the code to make the four possible outcomes from the call to `int_of_nat` explicit:

```ocaml
let int_of_big_int bi =
  try int_of_nat bi.abs_value with
  | val n when bi.sign = -1 ->
     -n
  | val n ->
     n
  | Failure _ when eq_big_int bi monster_big_int ->
     monster_int
  | Failure _ ->
     failwith "int_of_big_int"
```

Here's a simpler example from [the String module](https://github.com/ocaml/ocaml/blob/6a296a02/stdlib/string.ml#L195), which also involves code that cannot raise an exception in the body of a `try` block:

```ocaml
try ignore (index_rec s l i c); true with Not_found -> false
```

Using handler case we can separate the code that may raise an exception (the call to `index_rec`) from the expression that produces the result:

```ocaml
try index_rec s l i c with val _ -> true | Not_found -> false
```

### Trying it out

Using [opam][opam] you can install an OCaml compiler extended with handler case as follows:

```
$ opam remote add ocamllabs git@github.com:ocamllabs/opam-repo-dev.git
ocamllabs Fetching git@github.com:ocamllabs/opam-repo-dev.git
[...]
$ opam switch 4.02.0dev+handler-syntax
# To complete the configuration of OPAM, you need to run:
eval `opam config env`
$ eval `opam config env`
```

#### js_of_ocaml

You can also try out the handler case construct in your browser, using the following modified version of [OCamlPro][ocamlpro]'s [Try OCaml][try-ocaml] application:

### The discoveries of success continuations

As [Philip Wadler][wadler] [notes][wadler-post], constructs for handling success continuations have been independently discovered multiple times.  In fact, the history goes back even further than described in Wadler's blog; constructs like handler case date back over thirty years and have been introduced, apparently independently, into at least four languages.  Curiously, all the languages use `let`-binding for success continuations and `match` binding for failure continuations.

#### Lisp

In [Common Lisp][clhs] the construct analogous to `try` is [`handler-case`][handler-case-no-error] (from which the construct discussed here borrows its name).  A `handler-case` expression has a body and a sequence of clauses which specify how various conditions (exceptions) should be handled.  The special condition specification `:no-error` specifies the code to run when no condition is signalled.  The `iter_stream` function might be written as follows in Common Lisp:

```common-lisp
(defun iter-stream (f s)
   (handler-case (get-stream s)
      (end-of-stream (_) nil)
      (:no-error (x |s'|)
         (funcall f x)
         (iter-stream f |s'|))))
```

The Common Lisp specification was completed in 1994 but the `handler-case` construct and its `:no-error` clause were present in some of Common Lisp's progenitors.  The construct was apparently introduced to Symbolics Lisp some time around 1982: it appears in the [5th edition][lisp-machine-1983] of the Lisp Machine manual (January 1983) but not the [4th edition][lisp-machine-1981] from 18 months earlier (July 1981).

#### Python

Python has supported success continuations in exception handlers since May 1994, when the `else` clause was added to `try` blocks.  The [Changelog in old versions of the Grammar/Grammar file][python-grammar-changelog] has an entry

> ```
> # 3-May-94:
> #Added else clause to try-except
> ```

introduced in a [commit from August 1994][python-changelog-commit]:

> ```
> changeset:   1744:6c0e11b94009
> branch:      legacy-trunk
> user:        Guido van Rossum <guido@python.org>
> date:        Mon Aug 01 11:00:20 1994 +0000
> summary:     Bring alpha100 revision back to mainline
> ```

Unlike the `:no-error` clause in Lisp's `handler-case`, Python's `else` clause doesn't bind variables.  Since Python variables have function scope, not block scope, bindings in the body of the try block are visible throughout the function.  In Python we might write `iter_stream` as follows:

```python
def iter_stream(f, s):
   try:
      (x, s_) = MyStream.get(s)
   except End_of_stream:
      pass
   else:
      f(x)
      iter_stream(f, s_)
```

The provenance of the `else` clause is unclear, but it doesn't seem to derive from Lisp's `handler-case`.  The design of Python's exception handling constructs [comes from Modula-3][python-modula-3], but the exception handling construct described in the [Modula-3 report][modula-3-reference] does not include a way of specifying the success continuation.  The syntax of the Modula-3 `TRY`/`EXCEPT` statement (found on p21 of the report) does include an `ELSE` clause:

```
   TRY    
     Body
   EXCEPT
     id1 (v1) => Handler1
   | ...
   | idn (vn) => Handlern
   ELSE Handler0
   END
```

However, whereas Python's `else` handles the case where no exception is raised, Modula-3's `ELSE` handles the case where an exception not named in one of the `EXCEPT` clauses is raised: it is equivalent to Python's catch-all `except:`.

Python also adds success handlers to other constructs.  Both the [`for`][python-for-else] and the [`while`][python-while-else] statements have an optional `else` clause which is executed unless the loop terminates prematurely with an exception or `break`.

<a name="exceptional-syntax"></a>
#### Exceptional Syntax

The 2001 paper [Exceptional Syntax][exceptional-syntax] ([Benton][benton] and [Kennedy][kennedy]) proposed the following construct for handling exceptions in Standard ML:

```ocaml
let val pattern_1 <= expr_1
    ...
    val pattern_n <= expr_n
 in
    expr
unless
    pattern_1' => expr_1'
  | ...
  | pattern_n' => expr_n'
end
```

Evaluation of the `let` binding proceeds as normal, except that if any of `expr_1` to `expr_n` raises an exception, control is transferred to the right hand side of the first of the clauses after `unless` whose left hand side matches the exception.  The construct is largely similar to our proposed variation, except that the bindings used in the success continuation are based on `let`, so scrutinising the values requires a separate `case` (i.e. `match`) expression.

Using the Exceptional Syntax construct we might write `iter_stream` as follows:

```ocaml
fun iter_stream f s =
 let val (x, s') <= MyStream.get s in
     f x;
     iter_stream f s'
 unless End_of_stream => ()
 end
```

Exceptional Syntax has been implemented in the SML-to-Java compiler [MLj][mlj].

#### Erlang

The 2004 paper [Erlang's Exception Handling Revisited](http://erlang.se/workshop/2004/exception.pdf) (Richard Carlsson, Björn Gustavsson and Patrik Nyblom) proposed an exception-handling construct for Erlang along the same lines as exceptional syntax, although apparently developed independently.  In the proposed extension to Erlang we might write `iter_stream` as follows:

```erlang
iter_stream(F, S) ->
   try Mystream:get(S) of
      {X, S_} ->
        _ = F(X),
        iter_stream(F, S_)
   with
    End_of_stream -> {}
```

#### Eff

[Plotkin][plotkin] and [Pretnar][pretnar]'s work on [handlers for algebraic effects][handling-algebraic-effects] generalises Exceptional Syntax to support effects other than exceptions.  The programming language [eff][eff] implements a design based on this work, and supports Exceptional Syntax, again with `let` binding for the success continuation.  (Although the success continuation is incorporated into the exception matching construct, only a single success continuation pattern is allowed.)  In eff we might write `iter_stream` as follows:

```ocaml
let rec iter_stream f s =
  handle my_stream_get s
  with exn#end_of_stream _ _ -> ()
     | val (x, s') -> f x;
                      iter_stream f s'
```

The second argument in the `end_of_stream` clauses binds the continuation of the effect, allowing handling strategies other than the usual stack unwinding.  Since we ignore the continuation argument the behaviour is the same as for a regular exception handler.

The [eff implementation][eff-handler-case-grammar] uses the term "handler case" for the clauses of the `handle` construct.

#### OCaml

Several OCaml programmers have proposed or implemented constructs related to handler case.

[Martin Jambon][jambon] has [implemented][micmatch-extension] a construct equivalent to Exceptional Syntax for OCaml as part of the [micmatch extension][micmatch].  His implementation allows us to write `iter_stream` in much the same way as Benton and Kennedy's proposal:

```ocaml
let rec iter_stream f s =
  let try (x, s') = my_stream_get s
   in f x;
      iter_stream f s'
  with End_of_stream -> ()
```

The details of the implementation are discussed in [Jake Donham][donham]'s [articles on Camlp4][donham-camlp4].  The micmatch implementation has a novel feature: the `let` binding associated with the success continuation may be made recursive.

[Alain Frisch][frisch] has proposed and implemented a more powerful extension to OCaml, [Static Exceptions][static-exceptions], which allow transfer of control to lexically-visible handlers (along the lines of Common Lisp's [`block`][cl-block] and [`return-from`][cl-return-from]).  Static exceptions are based on an equivalent feature in OCaml's intermediate language.

There is a straightforward translation from OCaml extended with handler case into OCaml extended with static exceptions by wrapping the body of each `try` expression in ``raise (`Val (...))``, and changing the `val` keyword in the binding section to `` `Val``.  For example, `iter_stream` can be written using static exceptions as follows:

```ocaml
let rec iter_stream f s =
  try raise (`Val (MyStream.get s))
  with End_of_stream -> ()
     | `Val (x, s') -> f x;
                       iter_stream f s'
```

Of course, static exceptions allow many other programs to be expressed that are not readily expressible using handler case.

Finally, I discovered while writing this article that Christophe Raffalli proposed the handler case design fifteen years ago in a [message to caml-list][raffalli-message]!  Christophe's proposal wasn't picked up back then, but perhaps the time has now come to give OCaml programmers a way to handle success.

### Postscript: a symmetric extension

The `try` construct in current OCaml supports matching against raised exceptions but not against the value produced when no exception is raised.  Contrariwise, the `match` construct supports matching against the value produced when no exception is raised, but does not support matching against raised exceptions.  As implemented, the patch addresses this asymmetry, extending `match` with clauses that specify the "failure continuation":

```ocaml
match expr
with pattern_1 -> expr_1
   | ...
   | pattern_n -> expr_n
   | exception pattern_1' -> expr_1'
   | ...
   | exception pattern_n' -> expr_n'
```

With this additional extension the choice between `match` and `try` becomes purely stylistic.  We might optimise for succinctness, and use `try` in the case where exceptions are expected (for example, where they're used for control flow), reserving `match` for the case where exceptions are truly exceptional.

For the sake of completeness, here's `iter_stream` written with the extended `match` construct:

```ocaml
let rec iter_stream f s =
  match MyStream.get s with
     (x, s') -> f x;
                iter_stream f s'
   | exception End_of_stream -> ()
```

Since both `val` and `exception` are existing keywords, the extensions to both `try` and `match` are fully backwards compatible. 

[opam]: http://opam.ocaml.org/
[froc-result]: https://github.com/jaked/froc/blob/7ad00380/src/froc/froc.mli#L93
[lisp-machine-1983]: http://bitsavers.informatik.uni-stuttgart.de/pdf/mit/cadr/chinual_5thEd_Jan83/chinualJan83_27_Errors.pdf
[lisp-machine-1981]: http://bitsavers.trailing-edge.com/pdf/mit/cadr/chinual_4thEd_Jul81.pdf
[handler-case-no-error]: http://clhs.lisp.se/Body/m_hand_1.htm
[handling-algebraic-effects]: http://matija.pretnar.info/pdf/handling-algebraic-effects.pdf
[exceptional-syntax]: http://research.microsoft.com/~akenn/sml/exceptionalsyntax.pdf
[python-try-except-else]: http://docs.python.org/2/tutorial/errors.html#handling-exceptions
[python-modula-3]: http://docs.python.org/3/faq/general.html#why-was-python-created-in-the-first-place
[static-exceptions]: http://www.lexifi.com/blog/static-exceptions
[jambon]: http://mjambon.com/
[donham]: https://twitter.com/jakedonham
[pretnar]: http://matija.pretnar.info/
[plotkin]: http://homepages.inf.ed.ac.uk/gdp/
[frisch]: http://alain.frisch.fr/
[benton]: http://research.microsoft.com/~nick/
[kennedy]: http://research.microsoft.com/~akenn/
[simpsons-already-did-it]: http://en.wikipedia.org/wiki/Simpsons_Already_Did_It
[modula-3-reference]: http://www.hpl.hp.com/techreports/Compaq-DEC/SRC-RR-52.pdf
[lwt-match-try-some]: https://github.com/ocsigen/lwt/blob/b63b2a/src/unix/lwt_unix.ml#L118-L125
[clhs]: http://www.lispworks.com/documentation/HyperSpec/Front/
[batteries-match-try-some]: https://github.com/ocaml-batteries-team/batteries-included/blob/92ea390c/benchsuite/bench_nreplace.ml#L45-L48
[liquidsoap-match-try-some]: https://github.com/savonet/liquidsoap/blob/a81cd8b6/src/decoder/metadata_decoder.ml#L53-L55
[sexplib-match-try-some]: https://github.com/janestreet/sexplib/blob/f9bd413/lib/conv.ml#L256-L259
[opa-match-try-some]: https://github.com/MLstate/opalang/blob/0802728/compiler/opalang/opaParser.ml#L127-L135
[unison-match-try-some]: https://github.com/pascal-bach/Unison/blob/4788644/src/ubase/prefs.ml#L97-L106
[uri-match-try-some]: https://github.com/avsm/ocaml-uri/blob/35af64db/lib/uri.ml#L250-L255
[coq-match-try-some]: https://github.com/coq/coq/blob/724c9c9f/tools/coqdoc/tokens.ml#L36-L41
[simon-cruanes-message]: https://sympa.inria.fr/sympa/arc/caml-list/2014-01/msg00113.html
[big-int-example]: https://github.com/ocaml/ocaml/blob/6a296a02/otherlibs/num/big_int.ml#L323-L328
[eff-handler-case-grammar]: https://github.com/matijapretnar/eff/blob/2a9a36cc/src/parser.mly#L4-L7
[caml-list]: http://caml.inria.fr/resources/forums.en.html
[python-grammar-changelog]: http://hg.python.org/cpython/file/36214c861144/Grammar/Grammar#l9
[python-for-else]: http://docs.python.org/2/reference/compound_stmts.html#the-for-statement
[python-while-else]: http://docs.python.org/2/reference/compound_stmts.html#the-while-statement
[oleg-response]: https://sympa.inria.fr/sympa/arc/caml-list/2014-01/msg00146.html
[simon-cruanes]: http://cedeela.fr/~simon/
[oleg]: http://okmij.org/ftp
[wadler-post]: http://wadler.blogspot.co.uk/2008/02/great-minds-think-alike.html
[wadler]: http://homepages.inf.ed.ac.uk/wadler
[eff]: http://math.andrej.com/eff/
[try-language-manual]: http://caml.inria.fr/pub/docs/manual-ocaml-4.00/expr.html#@manual.kwd50
[micmatch]: http://mjambon.com/micmatch.html
[micmatch-extension]: http://mjambon.com/mikmatch-manual.html#htoc16
[python-changelog-commit]: http://hg.python.org/cpython/rev/6c0e11b94009
[mlj]: http://www.dcs.ed.ac.uk/home/mlj/
[donham-camlp4]: http://ambassadortothecomputers.blogspot.co.uk/2010/09/reading-camlp4-part-11-syntax.html
[cl-block]: http://clhs.lisp.se/Body/s_block.htm#block
[cl-return-from]: http://clhs.lisp.se/Body/s_ret_fr.htm#return-from
[raffalli]: http://www.lama.univ-savoie.fr/~raffalli
[raffalli-message]: http://caml.inria.fr/pub/ml-archives/caml-list/1999/12/a6d3ce9671b16a33530035c2b42df011.en.html
[try-ocaml]: http://try.ocamlpro.com/
[ocamlpro]: http://www.ocamlpro.com/
