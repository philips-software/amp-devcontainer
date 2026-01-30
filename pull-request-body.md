> [!NOTE]
> Before merging this PR, please conduct a manual test checking basic functionality of the updated plug-ins. There are limited automated tests for the VS Code Extension updates.

Updates `usernamehw.errorlens` from 3.26.0 to 3.28.0
<details>
<summary>Release notes</summary>
<blockquote>


</blockquote>
</details>

Updates `sonarsource.sonarlint-vscode` from 4.39.0 to 4.41.0
<details>
<summary>Release notes</summary>
<blockquote>

Bugfixes and technical improvements

* Update Text & Secrets analyzer 2.36 -> 2.38
* Update CFamily analyzer 6.76 -> 6.77
* Upadte XML analyzer 2.14.2 to [2.15](https://www.github.com/SonarSource/sonar-xml/releases/tag/2.15.0.7513)
* Update IaC analyzer 2.3 -> 2.5
* Update PHP analyzer 3.53 -> [3.54](https://www.github.com/SonarSource/sonar-php/releases/tag/3.54.0.15452)
* Update Go analyzer 1.31 -> 1.32
* Update C# analyzer 10.17 -> [10.18](https://www.github.com/SonarSource/sonar-dotnet/releases/tag/10.18.0.131500)
* Bugfix - Can't setup SonarQube Cloud connection when there are many organisations to pick from
* Enable AI Agent configurations for Kiro
* Capture data locally with flight recorder
</blockquote>
</details>

Updates `rust-lang.rust-analyzer` from 0.3.2743 to 0.3.2769
<details>
<summary>Release notes</summary>
<blockquote>

Commit: [`2532c48`](https://www.github.com/rust-lang/rust-analyzer/commit/2532c48f1ed25de1b90d0287c364ee4f306bec0e) \
Release: [`2026-01-26`](https://www.github.com/rust-lang/rust-analyzer/releases/2026-01-26) (`v0.3.2769`)

## Fixes

- [`#21497`](https://www.github.com/rust-lang/rust-analyzer/pull/21497) (first contribution) allow const evaluation errors in method resolution.
- [`#21491`](https://www.github.com/rust-lang/rust-analyzer/pull/21491) insert type variables for statics.
- [`#21490`](https://www.github.com/rust-lang/rust-analyzer/pull/21490) don't mix up regular and built-in derives in "Expand macro recursively".
- [`#21485`](https://www.github.com/rust-lang/rust-analyzer/pull/21485) avoid emitting redundant block in `move_guard`.
- [`#21499`](https://www.github.com/rust-lang/rust-analyzer/pull/21499) don't offer `apply_demorgan` on `if let`.

## Internal Improvements

- [`#21492`](https://www.github.com/rust-lang/rust-analyzer/pull/21492) fix parameter capture and drop order in async functions.
- [`#21385`](https://www.github.com/rust-lang/rust-analyzer/pull/21385) parallelize proc macro expansion.
- [`#21479`](https://www.github.com/rust-lang/rust-analyzer/pull/21479) add tests for bidirectional communication in proc macro expansion.
- [`#21509`](https://www.github.com/rust-lang/rust-analyzer/pull/21509) add tests for renaming keywords in imports.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2026/01/26/changelog-312.html).

Commit: [`080e703`](https://www.github.com/rust-lang/rust-analyzer/commit/080e70378c543d26a3a817899cb66934ba76360b) \
Release: [`2026-01-19`](https://www.github.com/rust-lang/rust-analyzer/releases/2026-01-19) (`v0.3.2761`)

## New Features

- [`#21483`](https://www.github.com/rust-lang/rust-analyzer/pull/21483) trigger flycheck when non-workspace files get modified.

## Fixes

- [`#21475`](https://www.github.com/rust-lang/rust-analyzer/pull/21475) (first contribution) look up flycheck by ID instead of vector index.
- [`#21462`](https://www.github.com/rust-lang/rust-analyzer/pull/21462) sync cast checks to `rustc` once again.
- [`#21456`](https://www.github.com/rust-lang/rust-analyzer/pull/21456) make `naked_asm!()` always return `!`.
- [`#21364`](https://www.github.com/rust-lang/rust-analyzer/pull/21364) fix lowering crash with supertrait predicates.
- [`#21445`](https://www.github.com/rust-lang/rust-analyzer/pull/21445) disable `unused_variables` and `unused_mut` warnings.
- [`#21459`](https://www.github.com/rust-lang/rust-analyzer/pull/21459) hide macro-generated renamed imports from symbol index.
- [`#21464`](https://www.github.com/rust-lang/rust-analyzer/pull/21464) respect re-exports in path symbol search.
- [`#21484`](https://www.github.com/rust-lang/rust-analyzer/pull/21484) don't show sysroot dependencies in symbol search.
- [`#21451`](https://www.github.com/rust-lang/rust-analyzer/pull/21451) complete `mut` and `raw` on `&x.foo()`.
- [`#21442`](https://www.github.com/rust-lang/rust-analyzer/pull/21442) keep `+#[cfg]+` and `+#[track_caller]+` after `extract_function`.
- [`#21412`](https://www.github.com/rust-lang/rust-analyzer/pull/21412) keep guard expression in `move_guard`.
- [`#20946`](https://www.github.com/rust-lang/rust-analyzer/pull/20946) offer `convert_to_guarded_return` on `if let ... else`.
- [`#21465`](https://www.github.com/rust-lang/rust-analyzer/pull/21465) don't offer `remove_parentheses` on `(2 as i32) < 3`.

## Internal Improvements

- [`#21458`](https://www.github.com/rust-lang/rust-analyzer/pull/21458), [`#21443`](https://www.github.com/rust-lang/rust-analyzer/pull/21443) migrate `unwrap_block` and `generate_mut_trait_impl` assists to `SyntaxEditor`.
- [`#21466`](https://www.github.com/rust-lang/rust-analyzer/pull/21466) remove `postcard-legacy` proc macro server protocol.
- [`#21468`](https://www.github.com/rust-lang/rust-analyzer/pull/21468) improve `workspace.discoverConfig` docs.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2026/01/19/changelog-311.html).

Commit: [`dd48777`](https://www.github.com/rust-lang/rust-analyzer/commit/dd4877761e927e985593f756e8d71e64f1a99241) \
Release: [`2026-01-12`](https://www.github.com/rust-lang/rust-analyzer/releases/2026-01-12) (`v0.3.2753`)

## New Features

- [`#21415`](https://www.github.com/rust-lang/rust-analyzer/pull/21415), [`#21446`](https://www.github.com/rust-lang/rust-analyzer/pull/21446) allow Rust paths in symbol search.
- [`#18043`](https://www.github.com/rust-lang/rust-analyzer/pull/18043) support configuring flycheck using `workspace.discoverConfig`.

## Performance Improvements

- [`#21407`](https://www.github.com/rust-lang/rust-analyzer/pull/21407) reuse scratch allocations for `try_evaluate_obligations`.

## Fixes

- [`#21414`](https://www.github.com/rust-lang/rust-analyzer/pull/21414) (first contribution) include traits defined in other crates in flyimport.
- [`#21436`](https://www.github.com/rust-lang/rust-analyzer/pull/21436) (first contribution) handle `#[ignore = "reason"]` on tests.
- [`#21405`](https://www.github.com/rust-lang/rust-analyzer/pull/21405) (first contribution) support `Span::line` and `Span::column` in proc macro expansion.
- [`#21416`](https://www.github.com/rust-lang/rust-analyzer/pull/21416) support `Span::byte_range` in proc macro expansion.
- [`#21421`](https://www.github.com/rust-lang/rust-analyzer/pull/21421) fix recursive built-in derive expansion.
- [`#21399`](https://www.github.com/rust-lang/rust-analyzer/pull/21399) properly lower `SelfOnly` predicates.
- [`#21434`](https://www.github.com/rust-lang/rust-analyzer/pull/21434) remove code made redundant by method resolution rewrite.
- [`#21432`](https://www.github.com/rust-lang/rust-analyzer/pull/21432) fix missing lifetimes diagnostics with function pointers.
- [`#21420`](https://www.github.com/rust-lang/rust-analyzer/pull/21420) ignore escapes when string highlighting is disabled.

## Internal Improvements

- [`#21438`](https://www.github.com/rust-lang/rust-analyzer/pull/21438), [`#21439`](https://www.github.com/rust-lang/rust-analyzer/pull/21439) add integration test infrastructure to proc macro server.
- [`#21433`](https://www.github.com/rust-lang/rust-analyzer/pull/21433) include private definitions in generated docs.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2026/01/12/changelog-310.html).

Commit: [`6a1246b`](https://www.github.com/rust-lang/rust-analyzer/commit/6a1246b69ca761480b9278df019f717b549cface) \
Release: [`2026-01-05`](https://www.github.com/rust-lang/rust-analyzer/releases/2026-01-05) (`v0.3.2743`)

## New Features

- [`#21376`](https://www.github.com/rust-lang/rust-analyzer/pull/21376) allow finding references from doc comments.
- [`#21308`](https://www.github.com/rust-lang/rust-analyzer/pull/21308) add configuration options to override the `test`, `bench` and `doctest` subcommands.
- [`#21370`](https://www.github.com/rust-lang/rust-analyzer/pull/21370) add #[rust_analyzer::macro_style()] attribute to control macro completion brace style.

## Performance Improvements

- [`#21362`](https://www.github.com/rust-lang/rust-analyzer/pull/21362), [`#21363`](https://www.github.com/rust-lang/rust-analyzer/pull/21363) compress token trees to reduce memory usage (saves 120 MB on `self`).
- [`#21396`](https://www.github.com/rust-lang/rust-analyzer/pull/21396) only compute lang items for `#![feature(lang_items)]` crates.
- [`#21390`](https://www.github.com/rust-lang/rust-analyzer/pull/21390) pre-allocate interner storage with 64 KB of data or 1024 elements.
- [`#21391`](https://www.github.com/rust-lang/rust-analyzer/pull/21391) reduce `impl_signature` query dependencies in method resolution.

## Fixes

- [`#21374`](https://www.github.com/rust-lang/rust-analyzer/pull/21374) (first contribution) suppress `non_camel_case_types` lint for `+#[repr(C)]+` structs and enums.
- [`#21403`](https://www.github.com/rust-lang/rust-analyzer/pull/21403) suppress false positive missing associated item diagnostics when specialization is used.
- [`#21397`](https://www.github.com/rust-lang/rust-analyzer/pull/21397) fix `Span::source_text` in proc macro expansion.
- [`#21377`](https://www.github.com/rust-lang/rust-analyzer/pull/21377), [`#21400`](https://www.github.com/rust-lang/rust-analyzer/pull/21400) support `Span::file` and `Span::local_file` in proc macro expansion.
- [`#21393`](https://www.github.com/rust-lang/rust-analyzer/pull/21393) add location links for generic parameter type hints.
- [`#21375`](https://www.github.com/rust-lang/rust-analyzer/pull/21375) fix incorrect `dyn` hint in `impl Tr for`.
- [`#21361`](https://www.github.com/rust-lang/rust-analyzer/pull/21361) ignore `try_into_` prefix when suggesting a name.

## Internal Improvements

- [`#21367`](https://www.github.com/rust-lang/rust-analyzer/pull/21367) add an `upvars_mentioned` that computes the closure captures.
- [`#21369`](https://www.github.com/rust-lang/rust-analyzer/pull/21369) migrate `move_arm_cond_to_match_guard` assist to `SyntaxEditor`.
- [`#21388`](https://www.github.com/rust-lang/rust-analyzer/pull/21388) remove unnecessary `ConstLiteralRef` enum.
- [`#21401`](https://www.github.com/rust-lang/rust-analyzer/pull/21401) add a `README.md` to `proc-macro-srv-cli`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2026/01/05/changelog-309.html).

Commit: [`be6975f`](https://www.github.com/rust-lang/rust-analyzer/commit/be6975f8f90d33a3b205265a0a858ee29fabae13) \
Release: [`2025-12-29`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-12-29) (`v0.3.2735`)

## New Features

- [`#21200`](https://www.github.com/rust-lang/rust-analyzer/pull/21200) don't expand built-in derives, treat them specifically instead (saves 180 MB on `self`).
- [`#21337`](https://www.github.com/rust-lang/rust-analyzer/pull/21337) stabilize type mismatch diagnostic.
- [`#20193`](https://www.github.com/rust-lang/rust-analyzer/pull/20193) add setting to disable showing rename conflicts.
- [`#20741`](https://www.github.com/rust-lang/rust-analyzer/pull/20741) add macro segment completion.

## Fixes

- [`#21326`](https://www.github.com/rust-lang/rust-analyzer/pull/21326) keep flycheck generations in sync across multiple workspaces.
- [`#21348`](https://www.github.com/rust-lang/rust-analyzer/pull/21348) re-enable fixpoint variance analysis.
- [`#21351`](https://www.github.com/rust-lang/rust-analyzer/pull/21351) fix parsing of `format_args!(..., keyword=...)`.
- [`#21358`](https://www.github.com/rust-lang/rust-analyzer/pull/21358) fix type inference when hovering on `_`.
- [`#21354`](https://www.github.com/rust-lang/rust-analyzer/pull/21354) fix duplicate `default` item in record update syntax.
- [`#21330`](https://www.github.com/rust-lang/rust-analyzer/pull/21330) fix indent in `convert_to_guarded_return`.
- [`#20595`](https://www.github.com/rust-lang/rust-analyzer/pull/20595) fix indent in `convert_iter_for_each_to_for`.
- [`#20521`](https://www.github.com/rust-lang/rust-analyzer/pull/20521) handle `break` in expected type analysis.
- [`#21359`](https://www.github.com/rust-lang/rust-analyzer/pull/21359) prompt the user to add the `rust-analyzer` component to the toolchain file.
- [`#21297`](https://www.github.com/rust-lang/rust-analyzer/pull/21297) fix LSP configuration request handling.

## Internal Improvements

- [`#21249`](https://www.github.com/rust-lang/rust-analyzer/pull/21249), [`#21340`](https://www.github.com/rust-lang/rust-analyzer/pull/21340), [`#21345`](https://www.github.com/rust-lang/rust-analyzer/pull/21345) implement bidirectional proc macro server messaging prototype.
- [`#21335`](https://www.github.com/rust-lang/rust-analyzer/pull/21335) store closures with "tupled" inputs.
- [`#21341`](https://www.github.com/rust-lang/rust-analyzer/pull/21341) move library and local root inputs to `base-db`.
- [`#21344`](https://www.github.com/rust-lang/rust-analyzer/pull/21344) stop using MIR `ProjectionElem` in closure analysis.
- [`#21349`](https://www.github.com/rust-lang/rust-analyzer/pull/21349) make token trees no longer generic over the span.
- [`#21353`](https://www.github.com/rust-lang/rust-analyzer/pull/21353) pre-allocate some buffers for parsing.
- [`#21355`](https://www.github.com/rust-lang/rust-analyzer/pull/21355) reduce channel lock contention for drop threads.
- [`#21357`](https://www.github.com/rust-lang/rust-analyzer/pull/21357) drop `AstIdMap` asynchronously.
- [`#21356`](https://www.github.com/rust-lang/rust-analyzer/pull/21356) collect garbage when quiescient after events.
- [`#21334`](https://www.github.com/rust-lang/rust-analyzer/pull/21334) add `cargo-machete` CI step.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/12/29/changelog-308.html).

Commit: [`9d58a93`](https://www.github.com/rust-lang/rust-analyzer/commit/9d58a93602913a1a2ecff29422eb4da67d304d9d) \
Release: [`2025-12-22`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-12-22) (`v0.3.2727`)

## New Features

- [`#21295`](https://www.github.com/rust-lang/rust-analyzer/pull/21295), [`#21307`](https://www.github.com/rust-lang/rust-analyzer/pull/21307) use GC instead of `salsa` interning for solver types (salves 648 MB and 31 s on `self`).
- [`#21240`](https://www.github.com/rust-lang/rust-analyzer/pull/21240) show parameter inlay hints for missing arguments.
- [`#20996`](https://www.github.com/rust-lang/rust-analyzer/pull/20996) add "Insert explicit method call derefs" assist.
- [`#21309`](https://www.github.com/rust-lang/rust-analyzer/pull/21309) add LSP extension to get failed obligations for a given function.
- [`#21282`](https://www.github.com/rust-lang/rust-analyzer/pull/21282) add `crate_attrs` field to `rust-project.json`.

## Fixes

- [`#21270`](https://www.github.com/rust-lang/rust-analyzer/pull/21270) (first contribution) fix "file emitted multiple times" errors in `rust-analyzer scip`.
- [`#21276`](https://www.github.com/rust-lang/rust-analyzer/pull/21276) fix reference-style links in hover.
- [`#21304`](https://www.github.com/rust-lang/rust-analyzer/pull/21304) strip invisible delimiters in MBE.
- [`#21262`](https://www.github.com/rust-lang/rust-analyzer/pull/21262) use the HIR to check for used locals.
- [`#21032`](https://www.github.com/rust-lang/rust-analyzer/pull/21032) don't add semicolons to unit-returning function calls in argument lists.
- [`#21278`](https://www.github.com/rust-lang/rust-analyzer/pull/21278) suggest `&mut T` for `&T` in completions.
- [`#21289`](https://www.github.com/rust-lang/rust-analyzer/pull/21289) suggest `&T` for `&&T` in completions.
- [`#21212`](https://www.github.com/rust-lang/rust-analyzer/pull/21212) use variant name as variable in postfix completions for enums.
- [`#21166`](https://www.github.com/rust-lang/rust-analyzer/pull/21166) support `this` parameter name in closures.
- [`#21277`](https://www.github.com/rust-lang/rust-analyzer/pull/21277) fix reference stripping in expected type analysis.
- [`#21291`](https://www.github.com/rust-lang/rust-analyzer/pull/21291) fix expected type analysis for match arms.
- [`#20438`](https://www.github.com/rust-lang/rust-analyzer/pull/20438) fix guessing of braces for renamed macros.
- [`#21293`](https://www.github.com/rust-lang/rust-analyzer/pull/21293) don't offer `move_guard` in blocks with multiple statements.
- [`#21258`](https://www.github.com/rust-lang/rust-analyzer/pull/21258) support `add_return_type` for functions defined inside closures.
- [`#20576`](https://www.github.com/rust-lang/rust-analyzer/pull/20576) support nested `if-let` in `merge_nested_if`.
- [`#20577`](https://www.github.com/rust-lang/rust-analyzer/pull/20577) fix indent in `merge_nested_if`.
- [`#21266`](https://www.github.com/rust-lang/rust-analyzer/pull/21266) keep expression in `replace_let_with_if_let`.
- [`#21272`](https://www.github.com/rust-lang/rust-analyzer/pull/21272) prepend workspace root to target file for sysroot metadata.
- [`#21273`](https://www.github.com/rust-lang/rust-analyzer/pull/21273) fix method resolution for incoherent impls when there are two sysroots in the crate graph.

## Internal Improvements

- [`#21316`](https://www.github.com/rust-lang/rust-analyzer/pull/21316) call out feature freeze on IDE assists.
- [`#21314`](https://www.github.com/rust-lang/rust-analyzer/pull/21314) add "Use of AI tools" [section](https://www.github.com/rust-lang/rust-analyzer/blob/master/CONTRIBUTING.md#use-of-ai-tools) to developer docs.
- [`#21279`](https://www.github.com/rust-lang/rust-analyzer/pull/21279) add special `ErasedFileAstId` used to bypassing downmapping.
- [`#21298`](https://www.github.com/rust-lang/rust-analyzer/pull/21298) pretty-print attributes up to `cfg(false)`.
- [`#21284`](https://www.github.com/rust-lang/rust-analyzer/pull/21284) bump `rustc` crates.
- [`#20439`](https://www.github.com/rust-lang/rust-analyzer/pull/20439) add hint to use `T![]` instead of `T! {}`.
- [`#20472`](https://www.github.com/rust-lang/rust-analyzer/pull/20472) drop style guide entry about precondition checks.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/12/22/changelog-307.html).

Commit: [`87cf663`](https://www.github.com/rust-lang/rust-analyzer/commit/87cf6631c60b7e7c9f4a53693a68920a80966c6f) \
Release: [`2025-12-15`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-12-15) (`v0.3.2719`)

## New Features

- [`#21243`](https://www.github.com/rust-lang/rust-analyzer/pull/21243) support `#[feature(associated_type_defaults)]`.
- [`#21242`](https://www.github.com/rust-lang/rust-analyzer/pull/21242) support the 1.93 `format_args!` lowering.

## Fixes

- [`#21253`](https://www.github.com/rust-lang/rust-analyzer/pull/21253) (first contribution) don't register twice for `didSaveTextDocument`.
- [`#21265`](https://www.github.com/rust-lang/rust-analyzer/pull/21265) (first contribution) properly handle multiple lint attributes on the same item.
- [`#21238`](https://www.github.com/rust-lang/rust-analyzer/pull/21238) (first contribution) add a stub `is_transmutable` to avoid panicking.
- [`#21226`](https://www.github.com/rust-lang/rust-analyzer/pull/21226) (first contribution) show generic args when displaying traits.
- [`#21235`](https://www.github.com/rust-lang/rust-analyzer/pull/21235) pass environment to fix a const generics panic.
- [`#21251`](https://www.github.com/rust-lang/rust-analyzer/pull/21251) fix a panic in `TypeBound::kind()`.
- [`#21233`](https://www.github.com/rust-lang/rust-analyzer/pull/21233) revert "turn `BlockLoc` into a tracked struct".
- [`#21244`](https://www.github.com/rust-lang/rust-analyzer/pull/21244) support `#[rustc_deprecated_safe_2024(audit_that = reason)]`.
- [`#21210`](https://www.github.com/rust-lang/rust-analyzer/pull/21210) fix completion with `{{{` and `_` in format strings.
- [`#20754`](https://www.github.com/rust-lang/rust-analyzer/pull/20754) keep labels and attributes in `convert_for_to_while_let`.
- [`#21239`](https://www.github.com/rust-lang/rust-analyzer/pull/21239) add missing parameter in `replace_method_eager_lazy`.
- [`#21044`](https://www.github.com/rust-lang/rust-analyzer/pull/21044) keep generics in `generate_fn_type_alias`.
- [`#21175`](https://www.github.com/rust-lang/rust-analyzer/pull/21175) fix indent in `toggle_ignore`.
- [`#21264`](https://www.github.com/rust-lang/rust-analyzer/pull/21264) don't offer `bind_unused_param` in closures.
- [`#21256`](https://www.github.com/rust-lang/rust-analyzer/pull/21256) demote `add_return_type`.
- [`#21187`](https://www.github.com/rust-lang/rust-analyzer/pull/21187) include overloaded operators in SCIP index.
- [`#21221`](https://www.github.com/rust-lang/rust-analyzer/pull/21221) don't needlessly add visibility in `no_such_field` quick fix.

## Internal Improvements

- [`#21225`](https://www.github.com/rust-lang/rust-analyzer/pull/21225) give `FileSymbol` a `'db` lifetime.
- [`#21263`](https://www.github.com/rust-lang/rust-analyzer/pull/21263) use generated names in old `format_args!` lowering.
- [`#21174`](https://www.github.com/rust-lang/rust-analyzer/pull/21174), [`#21199`](https://www.github.com/rust-lang/rust-analyzer/pull/21199) migrate `convert_iter_for_each_to_for` and `generate_delegate_trait` assists to `SyntaxEditor`.
- [`#21209`](https://www.github.com/rust-lang/rust-analyzer/pull/21209) do not create stale expressions in body lowering.
- [`#21252`](https://www.github.com/rust-lang/rust-analyzer/pull/21252) fix two Clippy lints.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/12/15/changelog-306.html).

Commit: [`5e3e9c4`](https://www.github.com/rust-lang/rust-analyzer/commit/5e3e9c4e61bba8a5e72134b9ffefbef8f531d008) \
Release: [`2025-12-08`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-12-08) (`v0.3.2711`)

## New Features

- [`#21218`](https://www.github.com/rust-lang/rust-analyzer/pull/21218) bump minimum supported toolchain version from 1.78 to 1.90.

## Fixes

- [`#21205`](https://www.github.com/rust-lang/rust-analyzer/pull/21205) (first contribution) handle `#[cfg]` in macro input attribute stripping.
- [`#21203`](https://www.github.com/rust-lang/rust-analyzer/pull/21203) add configuration option to hide placeholder type hints.
- [`#21222`](https://www.github.com/rust-lang/rust-analyzer/pull/21222) don't complete unit return type in async associated items.
- [`#21215`](https://www.github.com/rust-lang/rust-analyzer/pull/21215) don't implement sizedness check via `all_field_tys`.
- [`#21190`](https://www.github.com/rust-lang/rust-analyzer/pull/21190), [`#21195`](https://www.github.com/rust-lang/rust-analyzer/pull/21195) more proc macro server fixes.
- [`#21223`](https://www.github.com/rust-lang/rust-analyzer/pull/21223) temporarily disable `postcard`.
- [`#21198`](https://www.github.com/rust-lang/rust-analyzer/pull/21198) add missing semicolon in incomplete `let` completion.
- [`#21183`](https://www.github.com/rust-lang/rust-analyzer/pull/21183) register `define_opaque` built-in attribute macro.
- [`#21164`](https://www.github.com/rust-lang/rust-analyzer/pull/21164) allow multiple active discovery operations.

## Internal Improvements

- [`#21182`](https://www.github.com/rust-lang/rust-analyzer/pull/21182) remove `TraitEnvironment`.
- [`#21178`](https://www.github.com/rust-lang/rust-analyzer/pull/21178) make `ModuleId` and `BlockLoc` tracked structs.
- [`#21208`](https://www.github.com/rust-lang/rust-analyzer/pull/21208) handle lint attribute expansion in `hir`.
- [`#21188`](https://www.github.com/rust-lang/rust-analyzer/pull/21188) fix rustdoc warnings and enable them on CI.
- [`#21189`](https://www.github.com/rust-lang/rust-analyzer/pull/21189) remove `mdbook-toc` usage from the book.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/12/08/changelog-305.html).

Commit: [`d646b23`](https://www.github.com/rust-lang/rust-analyzer/commit/d646b23f000d099d845f999c2c1e05b15d9cdc78) \
Release: [`2025-12-01`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-12-01) (`v0.3.2702`)

## New Features

- [`#21027`](https://www.github.com/rust-lang/rust-analyzer/pull/21027) (first contribution) build releases with static CRT for `-windows-msvc` targets.
- [`#21121`](https://www.github.com/rust-lang/rust-analyzer/pull/21121) add basic support for declarative attribute and derive macros.
- [`#20125`](https://www.github.com/rust-lang/rust-analyzer/pull/20125) display inferred placeholder types inlay hints and use them in "Extract type as type alias".

## Fixes

- [`#21077`](https://www.github.com/rust-lang/rust-analyzer/pull/21077) (first contribution) handle more block types and show modifiers in closing brace inlay hints.
- [`#21151`](https://www.github.com/rust-lang/rust-analyzer/pull/21151) don't run cache priming when disabled.
- [`#21095`](https://www.github.com/rust-lang/rust-analyzer/pull/21095) fix iterator completions after auto-deref.
- [`#20937`](https://www.github.com/rust-lang/rust-analyzer/pull/20937) don't suggest duplicate `const` completions after `raw`.
- [`#20976`](https://www.github.com/rust-lang/rust-analyzer/pull/20976) fix completion after inner attributes.
- [`#21144`](https://www.github.com/rust-lang/rust-analyzer/pull/21144) fix completion after `extern` and add `crate` completion.
- [`#21028`](https://www.github.com/rust-lang/rust-analyzer/pull/21028) complete enum aliases in patterns.
- [`#21126`](https://www.github.com/rust-lang/rust-analyzer/pull/21126) fix parameter info with missing arguments.
- [`#20163`](https://www.github.com/rust-lang/rust-analyzer/pull/20163) use per-token, not global, edition in the parser.
- [`#20164`](https://www.github.com/rust-lang/rust-analyzer/pull/20164) pass the per-token, not global, edition when expanding declarative macros.
- [`#20217`](https://www.github.com/rust-lang/rust-analyzer/pull/20217) use root hygiene for speculative resolution.
- [`#21170`](https://www.github.com/rust-lang/rust-analyzer/pull/21170) support multiple ``enable``d features in `#[target_feature]`.
- [`#21159`](https://www.github.com/rust-lang/rust-analyzer/pull/21159), [`#21172`](https://www.github.com/rust-lang/rust-analyzer/pull/21172) rewrite `dyn Trait` lowering to follow rustc.
- [`#20685`](https://www.github.com/rust-lang/rust-analyzer/pull/20685) support multiple variants in `generate_enum_{is,projection}_method`.
- [`#20967`](https://www.github.com/rust-lang/rust-analyzer/pull/20967) offer `replace_method_eager_lazy` on `and`.
- [`#21141`](https://www.github.com/rust-lang/rust-analyzer/pull/21141) set `enclosing_range` in the SCIP index.
- [`#21131`](https://www.github.com/rust-lang/rust-analyzer/pull/21131) check snippet capabilities in `#[cfg(…)]` key completion.
- [`#21023`](https://www.github.com/rust-lang/rust-analyzer/pull/21023) fix handling of cloned elements in `SyntaxEditor`.
- [`#21147`](https://www.github.com/rust-lang/rust-analyzer/pull/21147) show a dropdown in the UI for `rust-analyzer.imports.granularity.group`.

## Internal Improvements

- [`#20892`](https://www.github.com/rust-lang/rust-analyzer/pull/20892) reintroduce attribute rewrite.
- [`#21097`](https://www.github.com/rust-lang/rust-analyzer/pull/21097), [`#21145`](https://www.github.com/rust-lang/rust-analyzer/pull/21145), [`#21146`](https://www.github.com/rust-lang/rust-analyzer/pull/21146), [`#21154`](https://www.github.com/rust-lang/rust-analyzer/pull/21154) reimplement proc macro server token trees as immutable, to speed up concatenation.
- [`#20986`](https://www.github.com/rust-lang/rust-analyzer/pull/20986), [`#21133`](https://www.github.com/rust-lang/rust-analyzer/pull/21133), [`#21135`](https://www.github.com/rust-lang/rust-analyzer/pull/21135), [`#21139`](https://www.github.com/rust-lang/rust-analyzer/pull/21139), [`#21179`](https://www.github.com/rust-lang/rust-analyzer/pull/21179) integrate `postcard` into the proc-macro server.
- [`#21149`](https://www.github.com/rust-lang/rust-analyzer/pull/21149) use a single query per crate for lang items.
- [`#21167`](https://www.github.com/rust-lang/rust-analyzer/pull/21167) shrink `InferenceResult` by ~40 bytes.
- [`#21169`](https://www.github.com/rust-lang/rust-analyzer/pull/21169) use new `salsa` API for `infer`.
- [`#21115`](https://www.github.com/rust-lang/rust-analyzer/pull/21115) bump `rustc` crates.
- [`#21177`](https://www.github.com/rust-lang/rust-analyzer/pull/21177) fix `SmolStr` pretty-printing for `Repr::Static`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/12/01/changelog-304.html).

Commit: [`4a2b38f`](https://www.github.com/rust-lang/rust-analyzer/commit/4a2b38f49f2c15f4302502027b6ac09914679a8f) \
Release: [`2025-11-24`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-11-24) (`v0.3.2693`)

## New Features

- [`#21100`](https://www.github.com/rust-lang/rust-analyzer/pull/21100) (first contribution) add semantic token modifier for deprecated items.
- [`#21068`](https://www.github.com/rust-lang/rust-analyzer/pull/21068) (first contribution) make `dyn` inlay hints configurable.
- [`#21093`](https://www.github.com/rust-lang/rust-analyzer/pull/21093) add assist to convert char literals.
- [`#20974`](https://www.github.com/rust-lang/rust-analyzer/pull/20974) rewrite method resolution to follow rustc more closely.
- [`#21015`](https://www.github.com/rust-lang/rust-analyzer/pull/21015) parse cargo config files with origins.

## Fixes

- [`#21090`](https://www.github.com/rust-lang/rust-analyzer/pull/21090), [`#21092`](https://www.github.com/rust-lang/rust-analyzer/pull/21092) (first contribution) don't offer to remove parantheses around control flow expressions.
- [`#21083`](https://www.github.com/rust-lang/rust-analyzer/pull/21083) complete `#[cfg(…)]` keys.
- [`#20980`](https://www.github.com/rust-lang/rust-analyzer/pull/20980) remove some deep normalizations from inference.
- [`#21084`](https://www.github.com/rust-lang/rust-analyzer/pull/21084) fix formatting request blocking on the `crate_def_map` query.
- [`#21061`](https://www.github.com/rust-lang/rust-analyzer/pull/21061) infer array lengths.
- [`#21060`](https://www.github.com/rust-lang/rust-analyzer/pull/21060), [`#21113`](https://www.github.com/rust-lang/rust-analyzer/pull/21113), [`#21026`](https://www.github.com/rust-lang/rust-analyzer/pull/21026) improve pattern inference.
- [`#21036`](https://www.github.com/rust-lang/rust-analyzer/pull/21036) handle references in postfix completions.
- [`#21053`](https://www.github.com/rust-lang/rust-analyzer/pull/21053) fix panic in `extract_function` when a variable is used multiple times in a macro call.
- [`#21074`](https://www.github.com/rust-lang/rust-analyzer/pull/21074) support parameters with the same name as a macro in `add_missing_impl_members`.
- [`#21065`](https://www.github.com/rust-lang/rust-analyzer/pull/21065) fix field completion in irrefutable patterns.
- [`#21018`](https://www.github.com/rust-lang/rust-analyzer/pull/21018) handle comments in `private_field` quick fix.
- [`#21042`](https://www.github.com/rust-lang/rust-analyzer/pull/21042) import full path in `replace_qualified_name_with_use` when triggered on the first segment.
- [`#21038`](https://www.github.com/rust-lang/rust-analyzer/pull/21038) support multiple selected variants in `generate_from_impl_for_enum`.
- [`#20559`](https://www.github.com/rust-lang/rust-analyzer/pull/20559) add digit group separators in `add_explicit_enum_discriminant`.
- [`#21111`](https://www.github.com/rust-lang/rust-analyzer/pull/21111) fill unguarded arms in `add_missing_match_arms`.
- [`#21047`](https://www.github.com/rust-lang/rust-analyzer/pull/21047) add `#[unsafe(…)]` completion.
- [`#21048`](https://www.github.com/rust-lang/rust-analyzer/pull/21048) don't report `incorrect_case` on `#[no_mangle]` static items.
- [`#21098`](https://www.github.com/rust-lang/rust-analyzer/pull/21098) load targets of all types with paths outside package root.

## Internal Improvements

- [`#21094`](https://www.github.com/rust-lang/rust-analyzer/pull/21094) (first contribution) make `DefMap` dumps more verbose.
- [`#21114`](https://www.github.com/rust-lang/rust-analyzer/pull/21114) (first contribution) disable the `tracing/attributes` in some crates.
- [`#21011`](https://www.github.com/rust-lang/rust-analyzer/pull/21011) (first contribution) provide a gdb pretty printer for `SmolStr`.
- [`#21017`](https://www.github.com/rust-lang/rust-analyzer/pull/21017) speed up cloning of inline `SmolStr` variants at the expense of heap ones.
- [`#21046`](https://www.github.com/rust-lang/rust-analyzer/pull/21046), [`#21088`](https://www.github.com/rust-lang/rust-analyzer/pull/21088) improve start-up speed.
- [`#21087`](https://www.github.com/rust-lang/rust-analyzer/pull/21087) gather trait implementations during cache priming.
- [`#21085`](https://www.github.com/rust-lang/rust-analyzer/pull/21085) produce fewer progress reports on start-up.
- [`#21086`](https://www.github.com/rust-lang/rust-analyzer/pull/21086) reduce allocations in `try_evaluate_obligations`.
- [`#21059`](https://www.github.com/rust-lang/rust-analyzer/pull/21059) derive `ParamEnv` from `GenericPredicates`.
- [`#21109`](https://www.github.com/rust-lang/rust-analyzer/pull/21109) migrate `replace_qualified_name_with_use` assist to `SyntaxEditor`.
- [`#21057`](https://www.github.com/rust-lang/rust-analyzer/pull/21057) implement precedence in HIR printing.
- [`#21103`](https://www.github.com/rust-lang/rust-analyzer/pull/21103) record lang item queries in `analysis-stats`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/11/24/changelog-303.html).

Commit: [`2efc800`](https://www.github.com/rust-lang/rust-analyzer/commit/2efc80078029894eec0699f62ec8d5c1a56af763) \
Release: [`2025-11-17`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-11-17) (`v0.3.2683`)

## Fixes

- [`#20985`](https://www.github.com/rust-lang/rust-analyzer/pull/20985) allow renaming label after `add_label_to_loop`.
- [`#21003`](https://www.github.com/rust-lang/rust-analyzer/pull/21003) add block on postfix `.const` completion.
- [`#20542`](https://www.github.com/rust-lang/rust-analyzer/pull/20542) handle guards in `replace_if_let_with_match`.
- [`#20972`](https://www.github.com/rust-lang/rust-analyzer/pull/20972) parse `impl ! {}`.

## Internal Improvements

- [`#21021`](https://www.github.com/rust-lang/rust-analyzer/pull/21021) fix Docs.rs builds after moving `smol_str`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/11/17/changelog-302.html).

Commit: [`21f8445`](https://www.github.com/rust-lang/rust-analyzer/commit/21f8445ea523e83cd4f11b0a67a3a5ced2b1f56f) \
Release: [`2025-11-10`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-11-10) (`v0.3.2675`)

## New Features

- [`#20565`](https://www.github.com/rust-lang/rust-analyzer/pull/20565) add "Convert range `for` to ``while``" assist.

## Fixes

- [`#20964`](https://www.github.com/rust-lang/rust-analyzer/pull/20964) canonicalize `custom-target.json` paths when fetching sysroot metadata.
- [`#20961`](https://www.github.com/rust-lang/rust-analyzer/pull/20961) consider more expression types as `in_value`.
- [`#20963`](https://www.github.com/rust-lang/rust-analyzer/pull/20963) expand literals with wrong suffixes into `LitKind::Err`.
- [`#20971`](https://www.github.com/rust-lang/rust-analyzer/pull/20971) fix panic while resolving callable signatures for `AsyncFnMut`.
- [`#20957`](https://www.github.com/rust-lang/rust-analyzer/pull/20957) keep associated items in `generate_blanket_trait_impl`.
- [`#20973`](https://www.github.com/rust-lang/rust-analyzer/pull/20973) handle method calls in `apply_demorgan`.

## Internal Improvements

- [`#21005`](https://www.github.com/rust-lang/rust-analyzer/pull/21005) (first contribution) improve wording in testing docs.
- [`#20994`](https://www.github.com/rust-lang/rust-analyzer/pull/20994) reduce memory usage of symbol index.
- [`#20997`](https://www.github.com/rust-lang/rust-analyzer/pull/20997) only populate public items in dependency symbol index.
- [`#20995`](https://www.github.com/rust-lang/rust-analyzer/pull/20995) use new `salsa` API for `SymbolsDatabase`.
- [`#20991`](https://www.github.com/rust-lang/rust-analyzer/pull/20991), [`#20990`](https://www.github.com/rust-lang/rust-analyzer/pull/20990), [`#20988`](https://www.github.com/rust-lang/rust-analyzer/pull/20988) merge `text-size`, `ungrammar` and `smol_str` into rust-analyzer.
- [`#21002`](https://www.github.com/rust-lang/rust-analyzer/pull/21002) bump library editions to 2024 and remove legacy files.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/11/10/changelog-301.html).

Commit: [`bacc5bb`](https://www.github.com/rust-lang/rust-analyzer/commit/bacc5bbd3020b8265e472ff98000ef477ff86e4a) \
Release: [`2025-11-03`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-11-03) (`v0.3.2667`)

## New Features

- [`#20186`](https://www.github.com/rust-lang/rust-analyzer/pull/20186) add option to exclude nearby derives from "Go to implementations" and implementations lens.
- [`#20906`](https://www.github.com/rust-lang/rust-analyzer/pull/20906) support opaques properly.

## Fixes

- [`#20921`](https://www.github.com/rust-lang/rust-analyzer/pull/20921) avoid calling `specializes()` query on crates that do not define `#![feature(specialization)]`.
- [`#20920`](https://www.github.com/rust-lang/rust-analyzer/pull/20920) resolve `target-dir` more precisely.
- [`#20369`](https://www.github.com/rust-lang/rust-analyzer/pull/20369) change method to associated function calls when renaming `self`.
- [`#20931`](https://www.github.com/rust-lang/rust-analyzer/pull/20931) show proper async function signatures in the signature help.
- [`#20930`](https://www.github.com/rust-lang/rust-analyzer/pull/20930) fix handling of nested block modules.
- [`#20919`](https://www.github.com/rust-lang/rust-analyzer/pull/20919) consider all matches for flyimport even when searched with a qualifier.
- [`#20942`](https://www.github.com/rust-lang/rust-analyzer/pull/20942) fix false positive syntax errors on frontmatters.
- [`#20934`](https://www.github.com/rust-lang/rust-analyzer/pull/20934) improve error recovery with malformed function return types.
- [`#20915`](https://www.github.com/rust-lang/rust-analyzer/pull/20915) offer `replace_is_method_with_if_let_method` in `while` expression.

## Internal Improvements

- [`#20922`](https://www.github.com/rust-lang/rust-analyzer/pull/20922) reduce `client_commands` allocations in LSP conversion.
- [`#20927`](https://www.github.com/rust-lang/rust-analyzer/pull/20927) support memory profiling using `dhat`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/11/03/changelog-300.html).



Commit: [`049767e`](https://www.github.com/rust-lang/rust-analyzer/commit/049767e6faa84b2d1a951d8f227e6ebd99d728a2) \
Release: [`2025-10-27`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-10-27) (`v0.3.2658`)

## New Features

- [`#20854`](https://www.github.com/rust-lang/rust-analyzer/pull/20854) feat (first contribution) parse script frontmatter.
- [`#20837`](https://www.github.com/rust-lang/rust-analyzer/pull/20837) feat (first contribution) expose `addConfiguration` API from the Code extension.
- [`#20329`](https://www.github.com/rust-lang/rust-analyzer/pull/20329), [`#20445`](https://www.github.com/rust-lang/rust-analyzer/pull/20445), [`#20446`](https://www.github.com/rust-lang/rust-analyzer/pull/20446), [`#20454`](https://www.github.com/rust-lang/rust-analyzer/pull/20454), [`#20470`](https://www.github.com/rust-lang/rust-analyzer/pull/20470), [`#20447`](https://www.github.com/rust-lang/rust-analyzer/pull/20447), [`#20496`](https://www.github.com/rust-lang/rust-analyzer/pull/20496), [`#20497`](https://www.github.com/rust-lang/rust-analyzer/pull/20497), [`#20502`](https://www.github.com/rust-lang/rust-analyzer/pull/20502), [`#20506`](https://www.github.com/rust-lang/rust-analyzer/pull/20506), [`#20523`](https://www.github.com/rust-lang/rust-analyzer/pull/20523), [`#20527`](https://www.github.com/rust-lang/rust-analyzer/pull/20527), [`#20537`](https://www.github.com/rust-lang/rust-analyzer/pull/20537), [`#20545`](https://www.github.com/rust-lang/rust-analyzer/pull/20545), [`#20553`](https://www.github.com/rust-lang/rust-analyzer/pull/20553), [`#20563`](https://www.github.com/rust-lang/rust-analyzer/pull/20563), [`#20586`](https://www.github.com/rust-lang/rust-analyzer/pull/20586), [`#20609`](https://www.github.com/rust-lang/rust-analyzer/pull/20609), [`#20578`](https://www.github.com/rust-lang/rust-analyzer/pull/20578), [`#20647`](https://www.github.com/rust-lang/rust-analyzer/pull/20647), [`#20645`](https://www.github.com/rust-lang/rust-analyzer/pull/20645), [`#20649`](https://www.github.com/rust-lang/rust-analyzer/pull/20649), [`#20654`](https://www.github.com/rust-lang/rust-analyzer/pull/20654), [`#20665`](https://www.github.com/rust-lang/rust-analyzer/pull/20665), [`#20671`](https://www.github.com/rust-lang/rust-analyzer/pull/20671), [`#20677`](https://www.github.com/rust-lang/rust-analyzer/pull/20677), [`#20664`](https://www.github.com/rust-lang/rust-analyzer/pull/20664), [`#20717`](https://www.github.com/rust-lang/rust-analyzer/pull/20717), [`#20728`](https://www.github.com/rust-lang/rust-analyzer/pull/20728), [`#20733`](https://www.github.com/rust-lang/rust-analyzer/pull/20733), [`#20735`](https://www.github.com/rust-lang/rust-analyzer/pull/20735), [`#20738`](https://www.github.com/rust-lang/rust-analyzer/pull/20738), [`#20765`](https://www.github.com/rust-lang/rust-analyzer/pull/20765), [`#20777`](https://www.github.com/rust-lang/rust-analyzer/pull/20777), [`#20785`](https://www.github.com/rust-lang/rust-analyzer/pull/20785), [`#20814`](https://www.github.com/rust-lang/rust-analyzer/pull/20814), [`#20834`](https://www.github.com/rust-lang/rust-analyzer/pull/20834), [`#20841`](https://www.github.com/rust-lang/rust-analyzer/pull/20841), [`#20867`](https://www.github.com/rust-lang/rust-analyzer/pull/20867), [`#20873`](https://www.github.com/rust-lang/rust-analyzer/pull/20873), [`#20882`](https://www.github.com/rust-lang/rust-analyzer/pull/20882), [`#20888`](https://www.github.com/rust-lang/rust-analyzer/pull/20888), [`#20896`](https://www.github.com/rust-lang/rust-analyzer/pull/20896), [`#20893`](https://www.github.com/rust-lang/rust-analyzer/pull/20893), [`#20895`](https://www.github.com/rust-lang/rust-analyzer/pull/20895) switch from Chalk to the next trait solver.
- [`#20632`](https://www.github.com/rust-lang/rust-analyzer/pull/20632) support navigation on primitives.
- [`#20760`](https://www.github.com/rust-lang/rust-analyzer/pull/20760) add `all`, `any` and `not` completions in `#[cfg]`.
- [`#20806`](https://www.github.com/rust-lang/rust-analyzer/pull/20806), [`#20835`](https://www.github.com/rust-lang/rust-analyzer/pull/20835) log flycheck `stdout` and `stderr` to files.
- [`#19771`](https://www.github.com/rust-lang/rust-analyzer/pull/19771) add "Generate blanket trait impl" assist.
- [`#20705`](https://www.github.com/rust-lang/rust-analyzer/pull/20705) add "Flip range expression" assist.
- [`#19918`](https://www.github.com/rust-lang/rust-analyzer/pull/19918) add "Remove `else` branches" assist.
- [`#20855`](https://www.github.com/rust-lang/rust-analyzer/pull/20855) improve fixture support.

## Fixes

- [`#20583`](https://www.github.com/rust-lang/rust-analyzer/pull/20583) (first contribution) add `rust-analyzer.semanticHighlighting.comments.enable` option.
- [`#20697`](https://www.github.com/rust-lang/rust-analyzer/pull/20697), [`#20745`](https://www.github.com/rust-lang/rust-analyzer/pull/20745) (first contribution) fix negative literals in const generics.
- [`#19867`](https://www.github.com/rust-lang/rust-analyzer/pull/19867) (first contribution) allow `&raw [mut | const]` for union fields in safe code.
- [`#20432`](https://www.github.com/rust-lang/rust-analyzer/pull/20432) (first contribution) improve identifier pattern handling in assists.
- [`#20891`](https://www.github.com/rust-lang/rust-analyzer/pull/20891) (first contribution) add `negation` semantic token type.
- [`#20425`](https://www.github.com/rust-lang/rust-analyzer/pull/20425) (first contribution) add parser heuristic to warn on unterminated strings.
- [`#20520`](https://www.github.com/rust-lang/rust-analyzer/pull/20520) add option to hide reborrows in adjustment inlay hints.
- [`#20721`](https://www.github.com/rust-lang/rust-analyzer/pull/20721) implement fallback properly.
- [`#20755`](https://www.github.com/rust-lang/rust-analyzer/pull/20755) add `#[doc = include_str!(…)]` completion.
- [`#20423`](https://www.github.com/rust-lang/rust-analyzer/pull/20423) make import sorting order follow the 2024 edition style.
- [`#20801`](https://www.github.com/rust-lang/rust-analyzer/pull/20801) small fixes for import insertion.
- [`#20866`](https://www.github.com/rust-lang/rust-analyzer/pull/20866) run `cargo metadata` on sysroot right from its path.
- [`#20554`](https://www.github.com/rust-lang/rust-analyzer/pull/20554) improve handling of the `env!` macro.
- [`#20587`](https://www.github.com/rust-lang/rust-analyzer/pull/20587) deduplicate methods in completion by function ID and not by name.
- [`#20803`](https://www.github.com/rust-lang/rust-analyzer/pull/20803) replace `--show-output` task defaults with `--nocapture`.
- [`#20459`](https://www.github.com/rust-lang/rust-analyzer/pull/20459) track diagnostic generations per package.
- [`#20689`](https://www.github.com/rust-lang/rust-analyzer/pull/20689) make flycheck clearing dependency-aware.
- [`#20635`](https://www.github.com/rust-lang/rust-analyzer/pull/20635) don't trigger two flychecks when saving files that are part of targets.
- [`#20402`](https://www.github.com/rust-lang/rust-analyzer/pull/20402) add more workarounds for incorrect startup diagnostics.
- [`#20787`](https://www.github.com/rust-lang/rust-analyzer/pull/20787) fix spurious `incorrect_generics_len` on generic enum variants used through type aliases.
- [`#20770`](https://www.github.com/rust-lang/rust-analyzer/pull/20770) don't trigger `trait-impl-incorrect-safety` on unresolved traits.
- [`#20642`](https://www.github.com/rust-lang/rust-analyzer/pull/20642) make `#[target_feature]` safe on WASM.
- [`#20504`](https://www.github.com/rust-lang/rust-analyzer/pull/20504) avoid infinite recursion while lowering associated type bounds from supertraits.
- [`#20720`](https://www.github.com/rust-lang/rust-analyzer/pull/20720) prevent rustup from automatically installing toolchains.
- [`#20528`](https://www.github.com/rust-lang/rust-analyzer/pull/20528) masquerade as nightly cargo when invoking flycheck with `-Zscript`.
- [`#20612`](https://www.github.com/rust-lang/rust-analyzer/pull/20612) fix "Expand macro recursively" on nested macro calls.
- [`#20517`](https://www.github.com/rust-lang/rust-analyzer/pull/20517) only compute unstable paths on nightly toolchains for IDE features.
- [`#20639`](https://www.github.com/rust-lang/rust-analyzer/pull/20639) resolve paths to snapshot test libraries absolutely.
- [`#20547`](https://www.github.com/rust-lang/rust-analyzer/pull/20547) don't highlight unrelated unsafe operation on `unsafe` blocks.
- [`#20579`](https://www.github.com/rust-lang/rust-analyzer/pull/20579) don't pass `--target` to `rustc` twice while fetching target data layout.
- [`#20475`](https://www.github.com/rust-lang/rust-analyzer/pull/20475) don't duplicate lang items with overridden sysroot crates.
- [`#20518`](https://www.github.com/rust-lang/rust-analyzer/pull/20518) fix `else` completion in `let _ = if x {} $0`.
- [`#20390`](https://www.github.com/rust-lang/rust-analyzer/pull/20390) add `if`-`else` completions in `let` statements and argument lists.
- [`#20620`](https://www.github.com/rust-lang/rust-analyzer/pull/20620), [`#20657`](https://www.github.com/rust-lang/rust-analyzer/pull/20657) add `else` keyword completion after `let` statements.
- [`#20653`](https://www.github.com/rust-lang/rust-analyzer/pull/20653) don't output an empty generic parameters list in `generate_function`.
- [`#20708`](https://www.github.com/rust-lang/rust-analyzer/pull/20708) fix panic in `destructure_struct_binding`.
- [`#20702`](https://www.github.com/rust-lang/rust-analyzer/pull/20702) fix `else` completion before `else` keyword.
- [`#20700`](https://www.github.com/rust-lang/rust-analyzer/pull/20700) fix `extract_variable` on `if`-`let`.
- [`#20709`](https://www.github.com/rust-lang/rust-analyzer/pull/20709) fix panic in `destructure_struct_binding`.
- [`#20710`](https://www.github.com/rust-lang/rust-analyzer/pull/20710) fix shorthand fields in `unused_variables`.
- [`#20661`](https://www.github.com/rust-lang/rust-analyzer/pull/20661) tighten up expected type completions in `if`.
- [`#20507`](https://www.github.com/rust-lang/rust-analyzer/pull/20507) handle expected `return` type in completions.
- [`#20725`](https://www.github.com/rust-lang/rust-analyzer/pull/20725) fix lifetime elision handling for `Fn`-style trait bounds.
- [`#20624`](https://www.github.com/rust-lang/rust-analyzer/pull/20624) fix `lifetime_bounds`.
- [`#20723`](https://www.github.com/rust-lang/rust-analyzer/pull/20723) fix `bind_unused_param` with binding modes and underscore prefixes.
- [`#20722`](https://www.github.com/rust-lang/rust-analyzer/pull/20722) fix `pull_assignment_up` on chained ``if``s.
- [`#20679`](https://www.github.com/rust-lang/rust-analyzer/pull/20679) fix type completion with nested patterns.
- [`#20592`](https://www.github.com/rust-lang/rust-analyzer/pull/20592) handle closures inside `match` in `add_braces`.
- [`#20543`](https://www.github.com/rust-lang/rust-analyzer/pull/20543) don't suggest invalid transformation in `replace_if_let_with_match`.
- [`#20742`](https://www.github.com/rust-lang/rust-analyzer/pull/20742) don't turn unused variables into raw identifier.
- [`#20598`](https://www.github.com/rust-lang/rust-analyzer/pull/20598) support `let` chains in `convert_to_guarded_return`.
- [`#20731`](https://www.github.com/rust-lang/rust-analyzer/pull/20731) handle tuple and slice rest patterns in `expand_rest_pattern`.
- [`#20729`](https://www.github.com/rust-lang/rust-analyzer/pull/20729) add `const` generic parameter keyword completion.
- [`#20793`](https://www.github.com/rust-lang/rust-analyzer/pull/20793) add missing parentheses on ambiguity in `missing_unsafe`.
- [`#20513`](https://www.github.com/rust-lang/rust-analyzer/pull/20513) complete `let` in `let`-chains.
- [`#20812`](https://www.github.com/rust-lang/rust-analyzer/pull/20812) complete `self` parameters in associated trait functions.
- [`#20805`](https://www.github.com/rust-lang/rust-analyzer/pull/20805) improve parse errors for `static` and `const`.
- [`#20824`](https://www.github.com/rust-lang/rust-analyzer/pull/20824) fix completion type analysis in empty closures.
- [`#20817`](https://www.github.com/rust-lang/rust-analyzer/pull/20817) support `add_explicit_type` on parameters in `let` statements.
- [`#20816`](https://www.github.com/rust-lang/rust-analyzer/pull/20816) handle closure return type adjustments in `add_return_type`.
- [`#20526`](https://www.github.com/rust-lang/rust-analyzer/pull/20526) support `let`-chains for `.let` completions.
- [`#20788`](https://www.github.com/rust-lang/rust-analyzer/pull/20788) allow more string literal conversions from raw strings.
- [`#20838`](https://www.github.com/rust-lang/rust-analyzer/pull/20838) don't make `convert_to_guarded_return` applicable on `let-else`.
- [`#20758`](https://www.github.com/rust-lang/rust-analyzer/pull/20758) support `else` blocks with `!` return type in `convert_to_guarded_return`.
- [`#20772`](https://www.github.com/rust-lang/rust-analyzer/pull/20772) support `match` inside `if` in `pull_assignment_up`.
- [`#20673`](https://www.github.com/rust-lang/rust-analyzer/pull/20673) support `break` with value in completions.
- [`#20858`](https://www.github.com/rust-lang/rust-analyzer/pull/20858) include trailing underscores when hiding inlay hints.
- [`#20872`](https://www.github.com/rust-lang/rust-analyzer/pull/20872) add missing rest pattern in `convert_named_struct_to_tuple_struct`.
- [`#20880`](https://www.github.com/rust-lang/rust-analyzer/pull/20880) fix invalid rest pattern in `convert_tuple_struct_to_named_struct`.
- [`#20455`](https://www.github.com/rust-lang/rust-analyzer/pull/20455) fix indent in `convert_match_to_let_else`.
- [`#20509`](https://www.github.com/rust-lang/rust-analyzer/pull/20509) fix indent in `move_guard_to_arm_body`.
- [`#20613`](https://www.github.com/rust-lang/rust-analyzer/pull/20613) fix indent in `unresolved_field` diagnostic fixes.
- [`#20845`](https://www.github.com/rust-lang/rust-analyzer/pull/20845) fix indent in `add_braces`.
- [`#20850`](https://www.github.com/rust-lang/rust-analyzer/pull/20850) fix indent in `add_missing_match_arms`.
- [`#20670`](https://www.github.com/rust-lang/rust-analyzer/pull/20670) improve incomplete statement heuristic.
- [`#20831`](https://www.github.com/rust-lang/rust-analyzer/pull/20831) add shorthand record field completions.
- [`#20571`](https://www.github.com/rust-lang/rust-analyzer/pull/20571) add type keyword completions.
- [`#20886`](https://www.github.com/rust-lang/rust-analyzer/pull/20886) improve handling of missing names in `MethodCallExpr`.
- [`#20905`](https://www.github.com/rust-lang/rust-analyzer/pull/20905) fix array inhabitedness check.
- [`#20889`](https://www.github.com/rust-lang/rust-analyzer/pull/20889) improve field completion parentheses heuristic.
- [`#20658`](https://www.github.com/rust-lang/rust-analyzer/pull/20658) complete `else` in more expressions.
- [`#20611`](https://www.github.com/rust-lang/rust-analyzer/pull/20611) add parantheses for precedence in `replace_arith_op`.
- [`#20912`](https://www.github.com/rust-lang/rust-analyzer/pull/20912) complete `let` before expression in `if`.
- [`#20764`](https://www.github.com/rust-lang/rust-analyzer/pull/20764) handle `if`-`let` in `convert_to_guarded_return`.
- [`#20712`](https://www.github.com/rust-lang/rust-analyzer/pull/20712) handle shorthand field patterns in `destructure_tuple_binding`.
- [`#20589`](https://www.github.com/rust-lang/rust-analyzer/pull/20589) place new module outside `impl` block in `extract_module`.
- [`#20913`](https://www.github.com/rust-lang/rust-analyzer/pull/20913) support `let`-chains in `replace_is_method_with_if_let_method`.
- [`#20626`](https://www.github.com/rust-lang/rust-analyzer/pull/20626) improve whitespace in `make::struct_field_list`.
- [`#20534`](https://www.github.com/rust-lang/rust-analyzer/pull/20534) improve semicolon handling in `toggle_macro_delimiter`.
- [`#20442`](https://www.github.com/rust-lang/rust-analyzer/pull/20442) only import the item in "Unqualify method call" when needed.
- [`#20686`](https://www.github.com/rust-lang/rust-analyzer/pull/20686) only offer `generate_default_from_enum_variant` when the variant name is completely selected.
- [`#20771`](https://www.github.com/rust-lang/rust-analyzer/pull/20771) offer `invert_if` on `else`.
- [`#20844`](https://www.github.com/rust-lang/rust-analyzer/pull/20844) offer `add_braces` on assignments.
- [`#20599`](https://www.github.com/rust-lang/rust-analyzer/pull/20599) offer `apply_demorgan` on `!`.
- [`#20456`](https://www.github.com/rust-lang/rust-analyzer/pull/20456) support guards in `replace_match_with_if_let`.
- [`#20714`](https://www.github.com/rust-lang/rust-analyzer/pull/20714) allow trailing comma in `remove_dbg!`.
- [`#20511`](https://www.github.com/rust-lang/rust-analyzer/pull/20511) don't offer `convert_integer_literal` on selections.
- [`#20512`](https://www.github.com/rust-lang/rust-analyzer/pull/20512) don't offer `replace_arith_op` on selections.
- [`#20736`](https://www.github.com/rust-lang/rust-analyzer/pull/20736) don't offer `invert_if` on `if-let` chains.
- [`#20682`](https://www.github.com/rust-lang/rust-analyzer/pull/20682) don't offer `change_visibility` for variant fields.
- [`#20688`](https://www.github.com/rust-lang/rust-analyzer/pull/20688) reduce `replace_is_method_with_if_let_method` applicability range.
- [`#20759`](https://www.github.com/rust-lang/rust-analyzer/pull/20759) fix casts and use typed syntax tree API in `convert_to_guarded_return`.
- [`#20876`](https://www.github.com/rust-lang/rust-analyzer/pull/20876) fix `signature_help` LSP conversion creating invalid UTF-16 offsets.

## Internal Improvements

- [`#20379`](https://www.github.com/rust-lang/rust-analyzer/pull/20379) (first contribution) consistently use `---` for horizontal rules.
- [`#20483`](https://www.github.com/rust-lang/rust-analyzer/pull/20483) (first contribution) optimize VS Code extension icon.
- [`#20794`](https://www.github.com/rust-lang/rust-analyzer/pull/20794) (first contribution) deduplicate `sort` and `dedup` calls.
- [`#20667`](https://www.github.com/rust-lang/rust-analyzer/pull/20667) add regression test for The One and Only Issue.
- [`#20376`](https://www.github.com/rust-lang/rust-analyzer/pull/20376) merge `Trait` and `TraitAlias` handling.
- [`#20399`](https://www.github.com/rust-lang/rust-analyzer/pull/20399) enable warning logs by default.
- [`#20706`](https://www.github.com/rust-lang/rust-analyzer/pull/20706) avoid allocating in `stdx::replace`.
- [`#20730`](https://www.github.com/rust-lang/rust-analyzer/pull/20730), [`#20748`](https://www.github.com/rust-lang/rust-analyzer/pull/20748), [`#20860`](https://www.github.com/rust-lang/rust-analyzer/pull/20860) migrate `expand_record_rest_pattern`, `replace_arith_op` and `generate_single_field_struct_from` assists to `SyntaxEditor`.
- [`#20796`](https://www.github.com/rust-lang/rust-analyzer/pull/20796) bump `salsa`.
- [`#20852`](https://www.github.com/rust-lang/rust-analyzer/pull/20852) do not enable `force-always-assert` by default.
- [`#20631`](https://www.github.com/rust-lang/rust-analyzer/pull/20631) remove support for `#[register_attr]`.
- [`#20804`](https://www.github.com/rust-lang/rust-analyzer/pull/20804) pass `--target` to `xtask install`.
- [`#20683`](https://www.github.com/rust-lang/rust-analyzer/pull/20683) expose iterators over the types in `InferenceResult`.
- [`#20669`](https://www.github.com/rust-lang/rust-analyzer/pull/20669) add a testing guide.
- [`#20633`](https://www.github.com/rust-lang/rust-analyzer/pull/20633) clarify introduction in the README and manual.
- [`#20638`](https://www.github.com/rust-lang/rust-analyzer/pull/20638) add FAQ entry about Cargo build lock and cache conflicts.
- [`#20560`](https://www.github.com/rust-lang/rust-analyzer/pull/20560) add progress bars to more places in `analysis-stats`.
- [`#20652`](https://www.github.com/rust-lang/rust-analyzer/pull/20652) improve `rust-analyzer diagnostics`.
- [`#20774`](https://www.github.com/rust-lang/rust-analyzer/pull/20774) build `x86_64-apple-darwin` binaries on `macos-14`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/10/27/changelog-299.html).



Commit: [`9db0550`](https://www.github.com/rust-lang/rust-analyzer/commit/9db05508ed08a4c952017769b45b57c4ad505872) \
Release: [`2025-08-11`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-08-11) (`v0.3.2577`)

## An Update on the Next Trait Solver

We are very close to switching from `chalk` to the next trait solver, which will be shared with `rustc`.
`chalk` is _de-facto_ unmaintained, and sharing the code with the compiler will greatly improve trait solving accuracy and fix long-standing issues in `rust-analyzer`.
This will also let us enable more on-the-fly diagnostics (currently marked as experimental), and even significantly improve performance.

However, in order to avoid regressions, we will suspend the weekly releases until the new solver is stabilized.
In the meanwhile, please test the pre-release versions (nightlies) and report any issues or improvements you notice, either on [GitHub Issues](https://www.github.com/rust-lang/rust-analyzer/issues), [GitHub Discussions](https://www.github.com/rust-lang/rust-analyzer/discussions/20426), or [Zulip](https://rust-lang.zulipchat.com/#narrow/channel/185405-t-compiler.2Frust-analyzer/topic/New.20Trait.20Solver.20feedback).

## New Features

- [`#20420`](https://www.github.com/rust-lang/rust-analyzer/pull/20420) (first contribution) add config option to exclude locals from document symbol search.

## Fixes

- [`#20381`](https://www.github.com/rust-lang/rust-analyzer/pull/20381) check expected type for assignments in completions.
- [`#20382`](https://www.github.com/rust-lang/rust-analyzer/pull/20382) correctly go to `impl From` from `into()` even inside macros.
- [`#20387`](https://www.github.com/rust-lang/rust-analyzer/pull/20387) do not remove the original token when descending into derives.
- [`#20412`](https://www.github.com/rust-lang/rust-analyzer/pull/20412) properly handle names matching identifiers in `generate_function`.
- [`#20418`](https://www.github.com/rust-lang/rust-analyzer/pull/20418) fix `extract_expressions_from_format_string` on `write!` calls.
- [`#20354`](https://www.github.com/rust-lang/rust-analyzer/pull/20354) remove no-op calls in `remove_dbg`.
- [`#20384`](https://www.github.com/rust-lang/rust-analyzer/pull/20384) fix external docs URL for exported macros.

## Internal Improvements

- [`#20417`](https://www.github.com/rust-lang/rust-analyzer/pull/20417) (first contribution) fix parsing of trait bound polarity and `for`-binders.
- [`#20419`](https://www.github.com/rust-lang/rust-analyzer/pull/20419), [`#20429`](https://www.github.com/rust-lang/rust-analyzer/pull/20429), [`#20434`](https://www.github.com/rust-lang/rust-analyzer/pull/20434) make flycheck generational.
- [`#20385`](https://www.github.com/rust-lang/rust-analyzer/pull/20385) migrate `expand_glob_import` assist to `SyntaxEditor`.
- [`#20373`](https://www.github.com/rust-lang/rust-analyzer/pull/20373) generate an `ast::Module`, not `String`, in `extract_module`.
- [`#20383`](https://www.github.com/rust-lang/rust-analyzer/pull/20383) remove `ted` from `replace_named_generic_with_impl`.
- [`#20380`](https://www.github.com/rust-lang/rust-analyzer/pull/20380) remove `add_attr` from `edit_in_place` because it use `ted`.
- [`#20409`](https://www.github.com/rust-lang/rust-analyzer/pull/20409) add `write!` and `writeln!` to `minicore`.
- [`#20400`](https://www.github.com/rust-lang/rust-analyzer/pull/20400) disable error reporting when clamping a position.
- [`#20393`](https://www.github.com/rust-lang/rust-analyzer/pull/20393) fix non-LSP compliant `Response` definition.
- [`#20392`](https://www.github.com/rust-lang/rust-analyzer/pull/20392) report the incorrect payload when failing to deserialize LSP messages.
- [`#20389`](https://www.github.com/rust-lang/rust-analyzer/pull/20389) slim down compile-time artifact progress reports.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/08/11/changelog-298.html).

Commit: [`8d75311`](https://www.github.com/rust-lang/rust-analyzer/commit/8d75311400a108d7ffe17dc9c38182c566952e6e) \
Release: [`2025-08-04`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-08-04) (`v0.3.2563`)

## New Features

- [`#20351`](https://www.github.com/rust-lang/rust-analyzer/pull/20351) change callers to use method call syntax when renaming a parameter to `self`.

## Fixes

- [`#20313`](https://www.github.com/rust-lang/rust-analyzer/pull/20313) fix variable substitution in `runnables.extraEnv`.
- [`#20333`](https://www.github.com/rust-lang/rust-analyzer/pull/20333) do not require all rename definitions to be renameable.
- [`#20336`](https://www.github.com/rust-lang/rust-analyzer/pull/20336) check for snippet cap in `generate_mut_trait_impl`.
- [`#20337`](https://www.github.com/rust-lang/rust-analyzer/pull/20337) fix bounds display with `impl Trait`.
- [`#20300`](https://www.github.com/rust-lang/rust-analyzer/pull/20300) don't add `Panics` section for `debug_assert!`.
- [`#20327`](https://www.github.com/rust-lang/rust-analyzer/pull/20327) don't show `$saved_file` literally in IDE status updates.

## Internal Improvements

- [`#20342`](https://www.github.com/rust-lang/rust-analyzer/pull/20342) reorganize `proc-macro-srv`, add `--format` and `--version` args.
- [`#20311`](https://www.github.com/rust-lang/rust-analyzer/pull/20311), [`#20314`](https://www.github.com/rust-lang/rust-analyzer/pull/20314), [`#20364`](https://www.github.com/rust-lang/rust-analyzer/pull/20364), [`#20368`](https://www.github.com/rust-lang/rust-analyzer/pull/20368), [`#20371`](https://www.github.com/rust-lang/rust-analyzer/pull/20371) migrate `convert_tuple_struct_to_named_struct`, `inline_type_alias`, `convert_from_to_tryfrom`, `generate_delegate_methods` and `generate_trait_from_impl` assists to `SyntaxEditor`.
- [`#20303`](https://www.github.com/rust-lang/rust-analyzer/pull/20303), [`#20372`](https://www.github.com/rust-lang/rust-analyzer/pull/20372) migrate `path_transform` to `SyntaxEditor`.
- [`#20345`](https://www.github.com/rust-lang/rust-analyzer/pull/20345) add `SyntaxEditor::delete_all`.
- [`#20349`](https://www.github.com/rust-lang/rust-analyzer/pull/20349) fix new Clippy lints.
- [`#20154`](https://www.github.com/rust-lang/rust-analyzer/pull/20154) improve settings tree descriptions.
- [`#20335`](https://www.github.com/rust-lang/rust-analyzer/pull/20335) use GitHub app for authenticating sync PRs.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/08/04/changelog-297.html).

Commit: [`db02cdc`](https://www.github.com/rust-lang/rust-analyzer/commit/db02cdc7fc8b0e0b9aa1be4110a74620bbac1f98) \
Release: [`2025-07-28`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-07-28) (`v0.3.2555`)

## New Features

- [`#19938`](https://www.github.com/rust-lang/rust-analyzer/pull/19938) add "Generate impl for type" assist.

## Fixes

- [`#20271`](https://www.github.com/rust-lang/rust-analyzer/pull/20271) disable tests in flycheck if `cfg.setTest` is set to `false`.
- [`#20262`](https://www.github.com/rust-lang/rust-analyzer/pull/20262) fix search of raw labels and lifetimes.
- [`#20273`](https://www.github.com/rust-lang/rust-analyzer/pull/20273) apply adjustments to patterns and expressions when doing pattern analysis.
- [`#20281`](https://www.github.com/rust-lang/rust-analyzer/pull/20281) parse `for<'a> [const]`.
- [`#20318`](https://www.github.com/rust-lang/rust-analyzer/pull/20318) ignore `Destruct` bounds again.
- [`#20290`](https://www.github.com/rust-lang/rust-analyzer/pull/20290), [`#20315`](https://www.github.com/rust-lang/rust-analyzer/pull/20315) use temporary directory for copied lockfiles.
- [`#20319`](https://www.github.com/rust-lang/rust-analyzer/pull/20319) consider all produced artifacts for proc macro dylib search.
- [`#20302`](https://www.github.com/rust-lang/rust-analyzer/pull/20302) fix doc-comment folding with multi-line parameter lists.
- [`#20285`](https://www.github.com/rust-lang/rust-analyzer/pull/20285) use `Self` when renaming `self` parameter.
- [`#20256`](https://www.github.com/rust-lang/rust-analyzer/pull/20256) support `Deref` in `generate_mut_trait_impl`.
- [`#20297`](https://www.github.com/rust-lang/rust-analyzer/pull/20297) fix whitespace in `generate_trait_from_impl`.

## Internal Improvements

- [`#20272`](https://www.github.com/rust-lang/rust-analyzer/pull/20272) (first contribution) fix size asserts on `x86_64-unknown-linux-gnux32`.
- [`#20293`](https://www.github.com/rust-lang/rust-analyzer/pull/20293), [`#20306`](https://www.github.com/rust-lang/rust-analyzer/pull/20306), [`#20307`](https://www.github.com/rust-lang/rust-analyzer/pull/20307), [`#20270`](https://www.github.com/rust-lang/rust-analyzer/pull/20270) migrate `replace_derive_with_manual_impl`, `add_missing_impl_members`, `convert_to_guarded_return`, `extract_expressions_from_format_string` and `generate_new` to `SyntaxEditor`.
- [`#20269`](https://www.github.com/rust-lang/rust-analyzer/pull/20269) migrate `AstNodeEdit::Indent` to `SyntaxEditor`.
- [`#20289`](https://www.github.com/rust-lang/rust-analyzer/pull/20289) remove `ExpressionStoreDiagnostics::MacroError`.
- [`#20278`](https://www.github.com/rust-lang/rust-analyzer/pull/20278) fupport filtering in `analysis-stats` MIR lowering.
- [`#20280`](https://www.github.com/rust-lang/rust-analyzer/pull/20280), [`#20282`](https://www.github.com/rust-lang/rust-analyzer/pull/20282), [`#20279`](https://www.github.com/rust-lang/rust-analyzer/pull/20279) set up `rustc-josh-sync`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/07/28/changelog-296.html).

Commit: [`58e507d`](https://www.github.com/rust-lang/rust-analyzer/commit/58e507d80728f6f32c93117668dc4510ba80bac9) \
Release: [`2025-07-21`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-07-21) (`v0.3.2547`)

## New Features

- [`#19783`](https://www.github.com/rust-lang/rust-analyzer/pull/19783) add "Generate `From` impl from single field" assist.
- [`#20265`](https://www.github.com/rust-lang/rust-analyzer/pull/20265) support `cfg_select!` for the standard library.

## Fixes

- [`#20238`](https://www.github.com/rust-lang/rust-analyzer/pull/20238) infer lifetimes for GATs in expression/pattern positions.
- [`#19917`](https://www.github.com/rust-lang/rust-analyzer/pull/19917) handle `AsRef` and `Borrow` in "Generate `IndexMut` impl from ``Index``".
- [`#20247`](https://www.github.com/rust-lang/rust-analyzer/pull/20247) transform tail expression `&` to `&mut` in "Generate `TraitMut` impl from ``Trait``".
- [`#20255`](https://www.github.com/rust-lang/rust-analyzer/pull/20255) fix bounds in "Generate `Deref` impl".

## Internal Improvements

- [`#20233`](https://www.github.com/rust-lang/rust-analyzer/pull/20233) (first contribution) expand `lsp-server` example.
- [`#20178`](https://www.github.com/rust-lang/rust-analyzer/pull/20178) clean up cargo config querying.
- [`#20234`](https://www.github.com/rust-lang/rust-analyzer/pull/20234) remove `{ConstParam,TypeParam}::remove_default`.
- [`#20246`](https://www.github.com/rust-lang/rust-analyzer/pull/20246) add `AsMut` to `minicore` prelude.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/07/21/changelog-295.html).

Commit: [`591e3b7`](https://www.github.com/rust-lang/rust-analyzer/commit/591e3b7624be97e4443ea7b5542c191311aa141d) \
Release: [`2025-07-14`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-07-14) (`v0.3.2539`)

## New Features

- [`#20054`](https://www.github.com/rust-lang/rust-analyzer/pull/20054) support folding multi-line parameter list with the function body:

  ![Screen recording demonstrating folding the parameter list of a function together with its body](https://www.github.com/user-attachments/assets/0f1918e8-3545-4cd0-839e-fd5c7386f3fc)
- [`#20185`](https://www.github.com/rust-lang/rust-analyzer/pull/20185) include enum variants in world symbols.
- [`#20109`](https://www.github.com/rust-lang/rust-analyzer/pull/20109) make `generate_new` work for tuple structs.

## Fixes

- [`#20192`](https://www.github.com/rust-lang/rust-analyzer/pull/20192) fix a panic in documentation rendering.
- [`#20180`](https://www.github.com/rust-lang/rust-analyzer/pull/20180) always bump in the parser in `err_and_bump`.
- [`#20200`](https://www.github.com/rust-lang/rust-analyzer/pull/20200) revert "re-enable fixpoint iteration for variance computation".
- [`#20212`](https://www.github.com/rust-lang/rust-analyzer/pull/20212) fix `dyn` inlay hints with parantheses and don't display them on HRTBs.
- [`#20210`](https://www.github.com/rust-lang/rust-analyzer/pull/20210) make `naked_asm!` safe to call and fix `global_asm!`.
- [`#20232`](https://www.github.com/rust-lang/rust-analyzer/pull/20232) normalize projection types before const eval.
- [`#20235`](https://www.github.com/rust-lang/rust-analyzer/pull/20235) fix `where` clause position in trait associated item completion.

## Internal Improvements

- [`#20219`](https://www.github.com/rust-lang/rust-analyzer/pull/20219) outline parts of `ExpressionStore` into a different allocation.
- [`#20198`](https://www.github.com/rust-lang/rust-analyzer/pull/20198), [`#20211`](https://www.github.com/rust-lang/rust-analyzer/pull/20211), [`#20218`](https://www.github.com/rust-lang/rust-analyzer/pull/20218) migrate `pull_assignment_up`, `convert_named_struct_to_tuple_struct`, `convert_match_to_let_else`, `generate_impl` and `remove_dbg` assists to `SyntaxEditor`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/07/14/changelog-294.html).

Commit: [`e429bac`](https://www.github.com/rust-lang/rust-analyzer/commit/e429bac8793c24a99b643c4813ece813901c8c79) \
Release: [`2025-07-09`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-07-09) (`v0.3.2533`)

## New Features

- [`#20185`](https://www.github.com/rust-lang/rust-analyzer/pull/20185) include enum variants in world symbols.

## Fixes

- [`#20192`](https://www.github.com/rust-lang/rust-analyzer/pull/20192) fix a panic in documentation rendering.
- [`#20180`](https://www.github.com/rust-lang/rust-analyzer/pull/20180) always bump in the parser in `err_and_bump`.
- [`#20200`](https://www.github.com/rust-lang/rust-analyzer/pull/20200) revert "re-enable fixpoint iteration for variance computation".

## Internal Improvements

- [`#20198`](https://www.github.com/rust-lang/rust-analyzer/pull/20198) migrate `pull_assignment_up` assist to `SyntaxEditor`.

Commit: [`0ac6559`](https://www.github.com/rust-lang/rust-analyzer/commit/0ac65592a833bf40238831dd10e15283d63c46d5) \
Release: [`2025-07-07`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-07-07) (`v0.3.2527`)

## New Features

## Fixes

- [`#20151`](https://www.github.com/rust-lang/rust-analyzer/pull/20151) only remove keyword prefixes (`macro@` or ``macro ``) from links in the docs if the target is inferred.
- [`#20158`](https://www.github.com/rust-lang/rust-analyzer/pull/20158) don't warn about the proc macro server when the sysroot is missing.
- [`#20160`](https://www.github.com/rust-lang/rust-analyzer/pull/20160) reduce diagnostic range for `macro_calls!`.
- [`#20120`](https://www.github.com/rust-lang/rust-analyzer/pull/20120) fix value resolution in `match` patterns.
- [`#20161`](https://www.github.com/rust-lang/rust-analyzer/pull/20161) fix closure capture analysis for `let` expressions.
- [`#20167`](https://www.github.com/rust-lang/rust-analyzer/pull/20167) improve `#[derive(Default)]` expansion.
- [`#20031`](https://www.github.com/rust-lang/rust-analyzer/pull/20031) respect length limit and improve adjustment hint tooltips.
- [`#20179`](https://www.github.com/rust-lang/rust-analyzer/pull/20179) handle divergence in destructuring assignments.
- [`#20159`](https://www.github.com/rust-lang/rust-analyzer/pull/20159) always couple `--compile-time-deps` with `--all-targets`.
- [`#20170`](https://www.github.com/rust-lang/rust-analyzer/pull/20170) improve flycheck and build script progress reporting.
- [`#20112`](https://www.github.com/rust-lang/rust-analyzer/pull/20112) add workaround for missing `Delimiter::None` support to built-in macros.
- [`#20126`](https://www.github.com/rust-lang/rust-analyzer/pull/20126) improve panic message on discover command spawning errors.
- [`#20148`](https://www.github.com/rust-lang/rust-analyzer/pull/20148) honor `rust-analyzer.cargo.noDeps` option when fetching sysroot metadata.

## Internal Improvements

- [`#20175`](https://www.github.com/rust-lang/rust-analyzer/pull/20175) (first contribution) remove special handling for box patterns in `match_check`.
- [`#20124`](https://www.github.com/rust-lang/rust-analyzer/pull/20124) remove last use of `rustc_pattern_analysis::Captures`.
- [`#20156`](https://www.github.com/rust-lang/rust-analyzer/pull/20156) restructure proc macro loading erros.
- [`#20157`](https://www.github.com/rust-lang/rust-analyzer/pull/20157) re-enable fixpoint iteration for variance computation.
- [`#20184`](https://www.github.com/rust-lang/rust-analyzer/pull/20184) remove dead field from `InferenceContext`.
- [`#20169`](https://www.github.com/rust-lang/rust-analyzer/pull/20169) skip unnecessary ``BodySourceMap``'s `eq`.
- [`#20134`](https://www.github.com/rust-lang/rust-analyzer/pull/20134), [`#20135`](https://www.github.com/rust-lang/rust-analyzer/pull/20135), [`#20136`](https://www.github.com/rust-lang/rust-analyzer/pull/20136), [`#20137`](https://www.github.com/rust-lang/rust-analyzer/pull/20137), [`#20165`](https://www.github.com/rust-lang/rust-analyzer/pull/20165) migrate `replace_is_method_with_if_let_method`, `promote_local_to_const`, `toggle_macro_delimiter`, `wrap_unwrap_cfg_attr` and `unmerge_match_arm` assists to `SyntaxEditor`.
- [`#20132`](https://www.github.com/rust-lang/rust-analyzer/pull/20132) add `AsMut`, `Borrow` and `BorrowMut` to `minicore`.
- [`#20144`](https://www.github.com/rust-lang/rust-analyzer/pull/20144) add `load_workspace_into_db` version of `load_workspace`.
- [`#19923`](https://www.github.com/rust-lang/rust-analyzer/pull/19923) bump `salsa`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/07/07/changelog-293.html).

Commit: [`6df1213`](https://www.github.com/rust-lang/rust-analyzer/commit/6df12139bccaaeecf6a34789e0ca799d1fe99c53) \
Release: [`2025-06-30`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-06-30) (`v0.3.2519`)

## New Features

- [`#20077`](https://www.github.com/rust-lang/rust-analyzer/pull/20077) (first contribution) take an optional `"args": "cursor"` in the VS Code "Run" command.
- [`#19546`](https://www.github.com/rust-lang/rust-analyzer/pull/19546) highlight return values as related to `match` / `if` / `=>`.
- [`#20100`](https://www.github.com/rust-lang/rust-analyzer/pull/20100) lower `PointeeSized` to `?Sized` to support the new `Sized` trait hierarchy.
- [`#20105`](https://www.github.com/rust-lang/rust-analyzer/pull/20105) parse new `[const] Trait` syntax.

## Fixes

- [`#20110`](https://www.github.com/rust-lang/rust-analyzer/pull/20110) don't show float completions on integer literals.
- [`#20096`](https://www.github.com/rust-lang/rust-analyzer/pull/20096) don't show notifications on failed `rustfmt` calls.
- [`#20121`](https://www.github.com/rust-lang/rust-analyzer/pull/20121) don't append `--compile-time-deps` to build script commands.
- [`#20073`](https://www.github.com/rust-lang/rust-analyzer/pull/20073) use `ROOT` hygiene for `args` in the new `format_args!` expansion.
- [`#20069`](https://www.github.com/rust-lang/rust-analyzer/pull/20069) fix cargo project manifest not pointing to the workspace root.
- [`#20072`](https://www.github.com/rust-lang/rust-analyzer/pull/20072) respect configured `build.target-dir`.
- [`#20061`](https://www.github.com/rust-lang/rust-analyzer/pull/20061) don't wrap exit points with the right type in "Wrap return type".
- [`#20103`](https://www.github.com/rust-lang/rust-analyzer/pull/20103) prettify AST in `PathTransform` if it's coming from a macro.
- [`#20080`](https://www.github.com/rust-lang/rust-analyzer/pull/20080) clean up and expand `folding_ranges`.
- [`#20092`](https://www.github.com/rust-lang/rust-analyzer/pull/20092) don't complain about `rustc` workspace loading if it's not required.
- [`#20036`](https://www.github.com/rust-lang/rust-analyzer/pull/20036) don't default to `'static` for trait object lifetimes.

## Internal Improvements

- [`#20012`](https://www.github.com/rust-lang/rust-analyzer/pull/20012) (first contribution) bump `literal-escaper`.
- [`#20088`](https://www.github.com/rust-lang/rust-analyzer/pull/20088) de-`Arc` trait items query.
- [`#20087`](https://www.github.com/rust-lang/rust-analyzer/pull/20087) short-circuit a couple of queries.
- [`#20106`](https://www.github.com/rust-lang/rust-analyzer/pull/20106) make the `VariantFields` query more idiomatic.
- [`#20098`](https://www.github.com/rust-lang/rust-analyzer/pull/20098) unify formatting of progress messages.
- [`#20104`](https://www.github.com/rust-lang/rust-analyzer/pull/20104) clean up `provideCodeActions` VS Code hook.
- [`#20116`](https://www.github.com/rust-lang/rust-analyzer/pull/20116) cancel CI workflow only after the main matrix has finished.
- [`#20084`](https://www.github.com/rust-lang/rust-analyzer/pull/20084) fix CI job cancellation on Windows.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/06/30/changelog-292.html).

Commit: [`0100bc7`](https://www.github.com/rust-lang/rust-analyzer/commit/0100bc737358e56f5dc2fc7d3c15b8a69cefb56b) \
Release: [`2025-06-23`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-06-23) (`v0.3.2509`)

## New Features

- [`#19939`](https://www.github.com/rust-lang/rust-analyzer/pull/19939) add `rust-analyzer.assist.preferSelf` to prefer `Self` instead of the enum name in assists.
- [`#20047`](https://www.github.com/rust-lang/rust-analyzer/pull/20047) use `cargo check --compile-time-deps` when available.
- [`#20020`](https://www.github.com/rust-lang/rust-analyzer/pull/20020) reload workspaces when `cargo` config changes.
- [`#20018`](https://www.github.com/rust-lang/rust-analyzer/pull/20018) copy lockfile into target directory before invoking `cargo metadata`.
- [`#20056`](https://www.github.com/rust-lang/rust-analyzer/pull/20056) support the new `format_args!` expansion in 1.89.
- [`#20014`](https://www.github.com/rust-lang/rust-analyzer/pull/20014) show what `cargo metadata` is doing.

## Fixes

- [`#19945`](https://www.github.com/rust-lang/rust-analyzer/pull/19945) add quickfix to the `private-field` diagnostic.
- [`#20025`](https://www.github.com/rust-lang/rust-analyzer/pull/20025) (first contribution) hide imported private methods if "private editable" is disabled.
- [`#20041`](https://www.github.com/rust-lang/rust-analyzer/pull/20041) revert "turn `BlockId` into a ``#[salsa::tracked]``".
- [`#20022`](https://www.github.com/rust-lang/rust-analyzer/pull/20022) never make type mismatch diagnostic stable, even when there is a fix.
- [`#20023`](https://www.github.com/rust-lang/rust-analyzer/pull/20023) improve completions in `if` / `while` expression conditions.
- [`#20039`](https://www.github.com/rust-lang/rust-analyzer/pull/20039) fix closure capturing in `let` expressions.
- [`#20035`](https://www.github.com/rust-lang/rust-analyzer/pull/20035) pass `--color=always` from Test Explorer.

## Internal Improvements

- [`#19495`](https://www.github.com/rust-lang/rust-analyzer/pull/19495) start infesting `ide` crates with a `'db` lifetime.
- [`#20046`](https://www.github.com/rust-lang/rust-analyzer/pull/20046) add `hir::TypeParam::parent` method.
- [`#20050`](https://www.github.com/rust-lang/rust-analyzer/pull/20050) improve documentation for excluding imports from symbol search.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/06/23/changelog-291.html).

Commit: [`a207299`](https://www.github.com/rust-lang/rust-analyzer/commit/a207299344bf7797e4253c3f6130313e33c2ba6f) \
Release: [`2025-06-16`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-06-16) (`v0.3.2500`)

## New Features

- [`#19996`](https://www.github.com/rust-lang/rust-analyzer/pull/19996) add support for excluding imports from symbol search.
- [`#19837`](https://www.github.com/rust-lang/rust-analyzer/pull/19837), [`#19985`](https://www.github.com/rust-lang/rust-analyzer/pull/19985) provide better incrementality when items are changed.

## Fixes

- [`#19963`](https://www.github.com/rust-lang/rust-analyzer/pull/19963) do not report errors for unsized types without `where Self: Sized` items.
- [`#19970`](https://www.github.com/rust-lang/rust-analyzer/pull/19970) fix proc macro server handling of strings with minuses.
- [`#19973`](https://www.github.com/rust-lang/rust-analyzer/pull/19973) hide `dyn` inlay hints for incomplete ``impl``s.
- [`#19942`](https://www.github.com/rust-lang/rust-analyzer/pull/19942) fix completions with some attribute macros.
- [`#19981`](https://www.github.com/rust-lang/rust-analyzer/pull/19981) do not force-descend into derives for goto IDE features.
- [`#19983`](https://www.github.com/rust-lang/rust-analyzer/pull/19983) fix comparison of proc macros.
- [`#20000`](https://www.github.com/rust-lang/rust-analyzer/pull/20000) allow lifetime repeats in macros (`$($x)'a*`).
- [`#19990`](https://www.github.com/rust-lang/rust-analyzer/pull/19990) generate annotations for macro-defined items if their name is in the input.

## Internal Improvements

- [`#19982`](https://www.github.com/rust-lang/rust-analyzer/pull/19982), [`#19991`](https://www.github.com/rust-lang/rust-analyzer/pull/19991) simplify and optimize `ItemTree`.
- [`#20009`](https://www.github.com/rust-lang/rust-analyzer/pull/20009) optimize `pub(crate)` and `pub(self)` visibility resolution.
- [`#20007`](https://www.github.com/rust-lang/rust-analyzer/pull/20007), [`#20008`](https://www.github.com/rust-lang/rust-analyzer/pull/20008) make `salsa` usage more idiomatic.
- [`#19995`](https://www.github.com/rust-lang/rust-analyzer/pull/19995) turn `BlockId` into a `#[salsa::tracked]`.
- [`#20006`](https://www.github.com/rust-lang/rust-analyzer/pull/20006) clean up incremental tests and verify query execution.
- [`#19997`](https://www.github.com/rust-lang/rust-analyzer/pull/19997) remove `InternedCallableDefId`.
- [`#19980`](https://www.github.com/rust-lang/rust-analyzer/pull/19980) de-duplicate`ItemTree` `ItemVisibilities`.
- [`#19992`](https://www.github.com/rust-lang/rust-analyzer/pull/19992) use `ThinVec` in `ItemScope` in a couple places.
- [`#19984`](https://www.github.com/rust-lang/rust-analyzer/pull/19984) remove `pref_align_of` intrinsic handling, rename `{min_=>}align_of{,_val}`.
- [`#19930`](https://www.github.com/rust-lang/rust-analyzer/pull/19930) add support for type-erased `Semantics<'db, dyn HirDatabase>`.
- [`#19975`](https://www.github.com/rust-lang/rust-analyzer/pull/19975) test incremental trait solving.
- [`#19989`](https://www.github.com/rust-lang/rust-analyzer/pull/19989) bump some deps.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/06/16/changelog-290.html).

Commit: [`9fc1b90`](https://www.github.com/rust-lang/rust-analyzer/commit/9fc1b9076cf49c7f54497df9cfa4485a63f14d3e) \
Release: [`2025-06-09`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-06-09) (`v0.3.2490`)

## New Features

- [`#19893`](https://www.github.com/rust-lang/rust-analyzer/pull/19893) enhance renaming to include identifier variations that are generated by macros.
- [`#19908`](https://www.github.com/rust-lang/rust-analyzer/pull/19908) implement completions for `#[diagnostics]`.
- [`#19922`](https://www.github.com/rust-lang/rust-analyzer/pull/19922) ddd `dyn` keyword inlay hints.

## Fixes

- [`#19901`](https://www.github.com/rust-lang/rust-analyzer/pull/19901) (first contribution) increase the range of the tuple to named struct assists.
- [`#19869`](https://www.github.com/rust-lang/rust-analyzer/pull/19869) (first contribution) add diagnostic and quickfix to make private struct fields public.
- [`#19894`](https://www.github.com/rust-lang/rust-analyzer/pull/19894) handle cycles in `infer` and `const_param_ty_with_diagnostics`.
- [`#19935`](https://www.github.com/rust-lang/rust-analyzer/pull/19935) always emit quickfixes, even when diagnostics are disabled.
- [`#19936`](https://www.github.com/rust-lang/rust-analyzer/pull/19936), [`#19949`](https://www.github.com/rust-lang/rust-analyzer/pull/19949) stabilize the unlinked file and "JSON is not Rust" diagnostics.
- [`#19932`](https://www.github.com/rust-lang/rust-analyzer/pull/19932), [`#19937`](https://www.github.com/rust-lang/rust-analyzer/pull/19937) record macro calls in signatures and fields in `ChildBySource` impls.

## Internal Improvements

- [`#19933`](https://www.github.com/rust-lang/rust-analyzer/pull/19933) improve parser recovery for macro calls in type bound position.
- [`#19897`](https://www.github.com/rust-lang/rust-analyzer/pull/19897) produce `CLOSURE_BINDER` nodes.
- [`#19905`](https://www.github.com/rust-lang/rust-analyzer/pull/19905) clean up macro descension.
- [`#19928`](https://www.github.com/rust-lang/rust-analyzer/pull/19928) deduplicate some code in proc macro server.
- [`#19914`](https://www.github.com/rust-lang/rust-analyzer/pull/19914) add incremental tests checking for `infer` invalidation.
- [`#19915`](https://www.github.com/rust-lang/rust-analyzer/pull/19915), [`#19919`](https://www.github.com/rust-lang/rust-analyzer/pull/19919), [`#19920`](https://www.github.com/rust-lang/rust-analyzer/pull/19920), [`#19921`](https://www.github.com/rust-lang/rust-analyzer/pull/19921) try to fix autopublishing workflow.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/06/09/changelog-289.html).

Commit: [`2a388d1`](https://www.github.com/rust-lang/rust-analyzer/commit/2a388d1103450d814a84eda98efe89c01b158343) \
Release: [`2025-06-02`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-06-02) (`v0.3.2482`)

## New Features

- [`#19876`](https://www.github.com/rust-lang/rust-analyzer/pull/19876) render padding information when hovering on structs.
- [`#19881`](https://www.github.com/rust-lang/rust-analyzer/pull/19881) add assist to desugar `let pat = expr?;` into `let else`.
- [`#19819`](https://www.github.com/rust-lang/rust-analyzer/pull/19819) change import prefix default to `crate`.
- [`#19890`](https://www.github.com/rust-lang/rust-analyzer/pull/19890) make import insertion `#[cfg]`-aware.

## Fixes

- [`#19879`](https://www.github.com/rust-lang/rust-analyzer/pull/19879) fix IDE layer not resolving some macro calls.
- [`#19880`](https://www.github.com/rust-lang/rust-analyzer/pull/19880) handle included files better at the IDE layer.
- [`#19872`](https://www.github.com/rust-lang/rust-analyzer/pull/19872) fix inference of `AsyncFn` return types.
- [`#19864`](https://www.github.com/rust-lang/rust-analyzer/pull/19864) properly implement `might_be_inside_macro_call` using semantic information instead of syntactical hacks.
- [`#19851`](https://www.github.com/rust-lang/rust-analyzer/pull/19851) normalize when checking for uninhabited types for pattern exhaustiveness checks.
- [`#19875`](https://www.github.com/rust-lang/rust-analyzer/pull/19875) skip pattern analysis on type mismatches.
- [`#19899`](https://www.github.com/rust-lang/rust-analyzer/pull/19899) account for "Generate" actions when filtering the allowed ones.
- [`#19785`](https://www.github.com/rust-lang/rust-analyzer/pull/19785), [`#19792`](https://www.github.com/rust-lang/rust-analyzer/pull/19792) keep indent in `generate_new` and `generate_mut_trait`.
- [`#19900`](https://www.github.com/rust-lang/rust-analyzer/pull/19900) generate diagnostics docs for the manual.

## Internal Improvements

- [`#19877`](https://www.github.com/rust-lang/rust-analyzer/pull/19877) (first contribution) remove support for `concat_idents!`.
- [`#19861`](https://www.github.com/rust-lang/rust-analyzer/pull/19861) (first contribution) add documentation for `find_all_refs` constructor search.
- [`#19896`](https://www.github.com/rust-lang/rust-analyzer/pull/19896) restructure some semantics APIs for virtual macro files.
- [`#19898`](https://www.github.com/rust-lang/rust-analyzer/pull/19898) remove unncessary duplication in `highlight_related`.
- [`#19888`](https://www.github.com/rust-lang/rust-analyzer/pull/19888) recognize salsa cycles in `thread_result_to_response`.
- [`#19850`](https://www.github.com/rust-lang/rust-analyzer/pull/19850) add support for type-erased `Semantics<'db, dyn HirDatabase>`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/06/02/changelog-288.html).

Commit: [`d2f1787`](https://www.github.com/rust-lang/rust-analyzer/commit/d2f17873ff19786a121fb3302f91779c1a1b957f) \
Release: [`2025-05-26`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-05-26) (`v0.3.2474`)

## Fixes

- [`#19839`](https://www.github.com/rust-lang/rust-analyzer/pull/19839) correctly set the span of the proc_macro crate's `Group` delimiters.
- [`#19824`](https://www.github.com/rust-lang/rust-analyzer/pull/19824) fix caching problems with lint levels.

## Internal Improvements

- [`#19757`](https://www.github.com/rust-lang/rust-analyzer/pull/19757) request cancellation while processing changed files.
- [`#19814`](https://www.github.com/rust-lang/rust-analyzer/pull/19814) debounce workspace fetching for workspace structure changes.
- [`#19809`](https://www.github.com/rust-lang/rust-analyzer/pull/19809) catch inference panics in `analysis-stats`.
- [`#19840`](https://www.github.com/rust-lang/rust-analyzer/pull/19840) fix `integrated_benchmarks`.
- [`#19853`](https://www.github.com/rust-lang/rust-analyzer/pull/19853) bump `salsa`.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/05/26/changelog-287.html).

Commit: [`e464ff8`](https://www.github.com/rust-lang/rust-analyzer/commit/e464ff8c755c6e12540a45b83274ec4de4829191) \
Release: [`2025-05-19`](https://www.github.com/rust-lang/rust-analyzer/releases/2025-05-19) (`v0.3.2466`)

## Fixes

- [`#19793`](https://www.github.com/rust-lang/rust-analyzer/pull/19793) keep derive macros when removing unused imports.
- [`#19687`](https://www.github.com/rust-lang/rust-analyzer/pull/19687) highlight unsafe operations as related when the caret is on `unsafe`.
- [`#19801`](https://www.github.com/rust-lang/rust-analyzer/pull/19801) improve `asm!` support.
- [`#19794`](https://www.github.com/rust-lang/rust-analyzer/pull/19794) don't allow duplicate crates in the `all_crates` list.
- [`#19807`](https://www.github.com/rust-lang/rust-analyzer/pull/19807) don't override `RUSTUP_TOOLCHAIN` if it is already set.

## Internal Improvements

- [`#19796`](https://www.github.com/rust-lang/rust-analyzer/pull/19796) (first contribution) bump some dependencies for Cygwin support.
- [`#19808`](https://www.github.com/rust-lang/rust-analyzer/pull/19808) run metrics on the beta channel.

See also the [changelog post](https://rust-analyzer.github.io/thisweek/2025/05/19/changelog-286.html).
</blockquote>
</details>

Updates `github.vscode-pull-request-github` from 0.124.1 to 0.126.0
<details>
<summary>Release notes</summary>
<blockquote>

## 0.126.0

### Changes

- A multi-diff editor can be opened for a pull request by URI. For example, `vscode-insiders://github.vscode-pull-request-github/open-pull-request-changes?uri=https://www.github.com/microsoft/vscode-css-languageservice/pull/460`.
- There's an option to "Checkout on Codespace" from the pull request description webview.
- ctrl/cmd + R when the pull request description webview is focused will refresh the webview.
- You can "Reveal in Explorer" from files in the "Changes in Pull Request" view and the "Pull Requests" views.
- Commit SHAs in PR file comments will be linkified.
- Set `"githubPullRequests.pullRequestDescription": "branchName"` to have the pull request title pre-filled with the branch name when creating a new pull request.
- The command "GitHub Issues: Open Issue on GitHub" can be used when your cursor is in an issue reference (e.g., `#1234`) in a text file to open the issue on GitHub.
- Set `"githubPullRequests.commentExpandState": "collapsePreexisting"` to have pre-existing comments collapsed by default when opening a pull request description webview, while new comments remain expanded.
- Choose which PR template to use when creating a new pull request (requires that `"githubPullRequests.pullRequestDescription": "template"` is set).

![Button to change pull request template](./documentation/changelog/0.126.0/change-pr-template.png)

- Metadata from issue templates (e.g., `assignees`, `labels`) is now applied when creating a new issue from a template.
- Issues created from `TODO` comments are assigned to the current user by default.
- `"githubPullRequests.createOnPublishBranch"` can be set to `"always"` to always create a pull request when publishing a branch.
- Open pull requests can be converted to drafts from the pull request description webview.

![Convert to draft](./documentation/changelog/0.126.0/convert-to-draft.png)

- We attempt to unwrap shortened commit lines in the pull request description webview to improve readability.
- Copilot can generate descriptions for existing pull requests. "Edit" the description then use the sparkle icon to have Copilot generate a description.

![Generate description for an existing pull request](./documentation/changelog/0.126.0/generate-existing-description.png)

- Instead of checking out the default branch when you're done with a PR, you can configure that the PR base branch is checked out with `"githubPullRequests.postDone": "checkoutPullRequestBaseBranch"`.
- You can change the base branch of a PR from the pull request description webview.

![Change base branch](./documentation/changelog/0.126.0/change-base-branch.png)

- PR branches can be configured to be automatically deleted when the PR is merged from this extension with the setting `"githubPullRequests.deleteBranchAfterMerge": true`.
- When opening a folder for the first time, existing PR branches will be discovered and added to the "Local Pull Request Branches" view.

### Fixes

- Switch branch quick pick is not showing all branches. https://www.github.com/microsoft/vscode-pull-request-github/issues/8351
- Auto-merge options aren't properly updated when base repo changes. https://www.github.com/microsoft/vscode-pull-request-github/issues/8195
- Required check item renders strangely. https://www.github.com/microsoft/vscode-pull-request-github/issues/8176
- Request review from Copilot. https://www.github.com/microsoft/vscode-pull-request-github/issues/6830
- Make clear in which repo a pull request is stored. https://www.github.com/microsoft/vscode-pull-request-github/issues/6674
- Show Changes Since Last Review should not consider pending reviews as "Last Review". https://www.github.com/microsoft/vscode-pull-request-github/issues/6226
- Extension mistakenly thinks I'm using GH Enterprise with global "url aliasing". https://www.github.com/microsoft/vscode-pull-request-github/issues/4551

## 0.124.0

### Changes

- The active pull request or issue webview title is now included as implicit context when using Copilot Chat. You can click on the implicit context item to include all the PR information in your prompt.

![Pull request title as implicit context in Chat](./documentation/changelog/0.124.0/pull-request-implicit-context.png)

- Pull request and issue context can also be manually added to Chat from the "Add Context" menu.

![Explicit Chat context](./documentation/changelog/0.124.0/explicit-chat-context.png)

- Single button for marking Copilot pull requests as ready for review, approved, and automerge (if enabled).

![Single button to mark Copilot pull requests](./documentation/changelog/0.124.0/single-button-copilot-pr.png)

- The "Copy link" action for individual comments shows in the pull request description webview.
- Comments that are part of an un-submitted review (only visible to you) now show with at "comment draft" icon in the editor gutter and in the Comments view.
- For commits where checks have run, the commit status icon now shows next to each commit in the pull request description webview.

### Fixes

- Comments don't show when PR is on non-default repo. https://www.github.com/microsoft/vscode-pull-request-github/issues/8050
- ignoreSubmodules is honored differently for Pull Requests and Issues view. https://www.github.com/microsoft/vscode-pull-request-github/issues/7741

**_Thank You_**

* [@vicky1999 (Vignesh)](https://www.github.com/vicky1999)
  * fix: message wrapping in narrow editor panes [PR #8121](https://www.github.com/microsoft/vscode-pull-request-github/pull/8121)
  * feat: Display commit status icon for each commit [PR #8142](https://www.github.com/microsoft/vscode-pull-request-github/pull/8142)
  * feat: Add copy comment link button in PR overview [PR #8150](https://www.github.com/microsoft/vscode-pull-request-github/pull/8150)

## 0.122.1

### Fixes

- Only one reviewer can be seen on the PR page. https://www.github.com/microsoft/vscode-pull-request-github/issues/8131
- Drop down not doing anything. https://www.github.com/microsoft/vscode-pull-request-github/issues/8149
- Pull in icon fixes. https://www.github.com/microsoft/vscode-pull-request-github/issues/8159

## 0.122.0

### Changes

- Auto-generated PR descriptions (via `githubPullRequests.pullRequestDescription`) will respect the repository PR template if there is one.
- Icons in the Pull Requests view now render with codicons instead of Unicode characters.
- Drafts in the Pull Requests view now render in italics instead of having a `[DRAFT]` prefix.

![Pull Requests view showing codicon labels and italic draft PR titles](./documentation/changelog/0.122.0/pr-labels.png)

- Emoji completions for `:smile:` style emojis are now available in review comments.

![Emoji completions in review comments](./documentation/changelog/0.122.0/emoji-completions.gif)

- [Markdown alert syntax](https://www.github.com/orgs/community/discussions/16925) is now rendered in review comments.

![Markdown alerts in review comments](./documentation/changelog/0.122.0/markdown-alerts.png)

- Opening an empty commit from a pull request webview shows an editor with a message instead of showing a notification.
- Pull requests can be opened from from a url, for example: `vscode-insiders://github.vscode-pull-request-github/checkout-pull-request?uri=https://www.github.com/microsoft/vscode-css-languageservice/pull/460`
- Icons are up-to-date with VS Code's latest icons.
- If you start a review and want to cancel it, there's now a "Cancel Review" button in the pull request webview.

![Cancel review button](./documentation/changelog/0.122.0/cancel-review.png)

### Fixes

- Reactions to code comments are not showing up (Web). https://www.github.com/microsoft/vscode-pull-request-github/issues/2195
- Editing a comment freezes VS Code. https://www.github.com/microsoft/vscode/issues/274455
- Github Pull Request tab won't open if branch names are reused. https://www.github.com/microsoft/vscode-pull-request-github/issues/8007
- Icons are misaligned. https://www.github.com/microsoft/vscode-pull-request-github/issues/7998
- "Git is not installed or otherwise not available" even though it is. https://www.github.com/microsoft/vscode-pull-request-github/issues/5454

**_Thank You_**

* [@bendrucker (Ben Drucker)](https://www.github.com/bendrucker): Enable all LLM tools in prompts (agent mode) [PR #6956](https://www.github.com/microsoft/vscode-pull-request-github/pull/6956)
* [@gerardbalaoro (Gerard Balaoro)](https://www.github.com/gerardbalaoro): Make branch list timeout configurable (#2840) [PR #7927](https://www.github.com/microsoft/vscode-pull-request-github/pull/7927)
* [@wankun-tcj](https://www.github.com/wankun-tcj): Fix avatar display issue in Pull Request tree view [PR #7851](https://www.github.com/microsoft/vscode-pull-request-github/pull/7851)

## 0.120.2

### Fixes

- Unable to open PR webview within VSCode. https://www.github.com/microsoft/vscode-pull-request-github/issues/8028

## 0.120.1

### Fixes

- Extension cannot find git repo when VS Code didn't open the git root directory. https://www.github.com/microsoft/vscode-pull-request-github/issues/7964

## 0.120.0

### Changes

- The `#openPullRequest` tool recognizes open PR diffs and PR files as being the "open pull request".
- All Copilot PR notifications can be marked as ready using the right-click context menu on the Copilot section header in the Pull Requests view.
- The setting `githubIssues.issueAvatarDisplay` can be used to control whether the first assignee's avatar or the author's avatar is shown in the Issues view.
- Instead of always running the pull request queries that back the Pull Requests view when refreshing, we now check to see if there are new PRs in the repo before running the queries. This should reduce API usage when there are no new PRs.
- The "Copy link" action is back near the PR title in the pull request description webview.
- You can configure that the default branch is pulled when you're "done" with a PR using `"githubPullRequests.postDone": "checkoutDefaultBranchAndPull"`.

### Fixes

- Unable to get list of users to assign them to a pull request. https://www.github.com/microsoft/vscode-pull-request-github/issues/7908
- Error notifications when using GitHub Enterprise Server. https://www.github.com/microsoft/vscode-pull-request-github/issues/7901
- Ignore worktrees that aren't in one of the workspace folders. https://www.github.com/microsoft/vscode-pull-request-github/issues/7896
- Typing "#" and then Enter or Tab opens the GitHub issue queries settings. https://www.github.com/microsoft/vscode-pull-request-github/issues/7838
- Unexpected branch switching when githubIssues.useBranchForIssues = off. https://www.github.com/microsoft/vscode-pull-request-github/issues/7827
- Extension enters rapid refresh loop, causing high API usage and rate limiting. https://www.github.com/microsoft/vscode-pull-request-github/issues/7816
- GitHub PR view highlights all repos with Copilot notification. https://www.github.com/microsoft/vscode-pull-request-github/issues/7852
- Wrong commit is checked out when local branch exists with the same name. https://www.github.com/microsoft/vscode-pull-request-github/issues/7702
- Visual Label not provided for "Title" and "Description" field. https://www.github.com/microsoft/vscode-pull-request-github/issues/7595
- VSCode unresponsive during GitHub Pull Requests PR checkout (large number of files changed). https://www.github.com/microsoft/vscode-pull-request-github/issues/6952
- extension explodes and kicks back out to GITHUB: LOGIN when non github repos are in working directory (specifically codeberg). https://www.github.com/microsoft/vscode-pull-request-github/issues/6945

## 0.118.2

### Fixes

- Long coding agent problem statement results in unrecoverable error (Truncate coding agent problem_statement). https://www.github.com/microsoft/vscode-pull-request-github/issues/7861

## 0.118.1

### Fixes

- _No logs available for this session_ race condition. https://www.github.com/microsoft/vscode-pull-request-github/issues/7783

## 0.118.0

### Changes

- There's a new code action "Delegate to coding agent" which shows on `TODO` comments. The "to do" keywords are configurable using the existing setting ``.

![Todo comment with "delegate to coding agent" action](./documentation/changelog/0.118.0/delegate-to-coding-agent-action.png)

- More of the new Copilot coding agent user entry points prompt for sign in if you aren't already signed in to GitHub (GitHub Copilot Coding Agent view in Chat Sessions, `#copilotCodingAgent` tool,  "Delegate to coding agent" button).
- Some of the individual extension views used the same icon, making it difficult to distinguish between them if you drag them into their own view container. To solve this, several views use a new icon: "Pull Requests" uses `github-inverted`, "Active Pull Request" tree view uses `diff-multiple`, "Active Pull Request" webview view uses `code-review`.
- The "sidebar" content (reviewers, assignees, labels, etc.) in the pull request description webview have always moved above the pull request body when the webview width is narrow. Now, it also collapses into a compact, readonly view, which can be expanded to make modifications.

![Collapsed sidbar content on a narrow view](./documentation/changelog/0.118.0/collapsed-sidbar-content.png)

- Pull request and issue webviews restore after reload.
- The new `#openPullRequest` tool in Copilot Chat lets you reference the pull request currently open in a webview. The `#activePullRequest` tool continues to reference the pull request currently checked out.
- The "Edit Query" command in the "Pull Requests" view has an option to edit the query with Copilot.
- Setting `"githubPullRequests.ignoreSubmodules": true` will cause the extension to ignore submodules when looking for pull requests.
- In the "Issues" view, you can right click on an issue and "Assign to Coding Agent".

### Fixes

- Only update coding agent PRs when view is open. https://www.github.com/microsoft/vscode-pull-request-github/issues/7643
- Chat participant not honoring selected tools and thinks they are all selected. https://www.github.com/microsoft/vscode-pull-request-github/issues/7637
- Red "closed" on closed issues is confusing. https://www.github.com/microsoft/vscode-pull-request-github/issues/7628
- github-pull-request_activePullRequest returns empty comments array. https://www.github.com/microsoft/vscode-pull-request-github/issues/7601
- Allows me to believe I assigned an issue on a repo where I lack that permission. https://www.github.com/microsoft/vscode-pull-request-github/issues/7534
- clicked comment with no contents gave weird state. https://www.github.com/microsoft/vscode-pull-request-github/issues/7476
- In GH PR review page, headers have redundant url content. https://www.github.com/microsoft/vscode-pull-request-github/issues/7509
- Spurious error when checking out a PR with untracked files. https://www.github.com/microsoft/vscode-pull-request-github/issues/7294

**_Thank You_**

* [@krassowski (Michał Krassowski)](https://www.github.com/krassowski): Fix typo "will be replace" → "will be replaced" [PR #7540](https://www.github.com/microsoft/vscode-pull-request-github/pull/7540)

## 0.116.1

### Fixes

- Closing a PR causes a flurry of search API calls. https://www.github.com/microsoft/vscode-pull-request-github/issues/7537
- Opening a PR description can cause a flurry of GitHub search API calls. https://www.github.com/microsoft/vscode-pull-request-github/issues/7542

## 0.116.0

### Changes

- `#copilotCodingAgent` renders the pull requests it creates as a PR card.

![pull request card in chat](./documentation/changelog/0.116.0/pr-card-in-chat.png)

- When checking out a Copilot-authored PR, the Chat view no longer opens.
- You can dismiss the activity bar badge that indicates that Copilot has udpates to a PR by opening the PR description.
- We've simplified the button bar on the pull request description.

![simplified button bar in pull request header](./documentation/changelog/0.116.0/simplified-pr-header-buttons.png)

![pull request copy actions moved to link context menu](./documentation/changelog/0.116.0/pr-header-copy-actions.png)

- You can see a summary of the Copilot coding agent's status in the "Copilot on My Behalf" tree item

![coding agent summary](./documentation/changelog/0.116.0/coding-agent-status.png)

- The commit links in the pull request description will open in VS Code in the multidiff editor instead of going to GitHub.com.
- The `[WIP]` prefix that Copilot adds to PR titles is no longer shown in the Pull Requests view.
- Using `@githubpr` is now sticky and will be pre-populated into the chat input for subsequent messages.
- Changes in a PR are pre-fetched when the PR description is opened.
- Pull requested created by Copilot will have `@copilot` as placeholder text in comment inputs.
- If your issue queries (setting `githubIssues.queries`) return no issues, a suggestion to configure your queries is offered.

![suggestion in scm input to configure queries](./documentation/changelog/0.116.0/suggest-configure-queries.png)

- The "Checkout Pull Request by Number" command will also accept a pull URL.

### Fixes

- Improve PR list view performance. https://www.github.com/microsoft/vscode-pull-request-github/issues/7141
- "Cancel coding agent" could use status. https://www.github.com/microsoft/vscode-pull-request-github/issues/7451
- Icon missing from the tools picker for coding agent. https://www.github.com/microsoft/vscode-pull-request-github/issues/7446
- Copy GitHub Permalink doesn't work for GitHub Managed User (ghe.com). https://www.github.com/microsoft/vscode-pull-request-github/issues/7389
- Closing a pull request doesn't remove it from the copilot on my behalf section. https://www.github.com/microsoft/vscode-pull-request-github/issues/7364
- `@githubpr` doesn't know PR assignees. https://www.github.com/microsoft/vscode-pull-request-github/issues/7349
- "Copilot on My Behalf" tooltip. https://www.github.com/microsoft/vscode-pull-request-github/issues/7276
- Unassigning myself from a PR removes all comments from the PR editor. https://www.github.com/microsoft/vscode-pull-request-github/issues/7218
- GitHub warning icons aren't well aligned in PR view. https://www.github.com/microsoft/vscode-pull-request-github/issues/7219
- pr.openDescription command error. https://www.github.com/microsoft/vscode/issues/253900
- Can't assign Copilot when creating new issue from GHPRI directly. https://www.github.com/microsoft/vscode-pull-request-github/issues/7033
- Create PR shows error if there has been a previous PR on that branch. https://www.github.com/microsoft/vscode-pull-request-github/issues/7018
- Changing around assignees for PRs causes timeline to hide until refresh. https://www.github.com/microsoft/vscode-pull-request-github/issues/7012
- Can times in the timeline update periodically? https://www.github.com/microsoft/vscode-pull-request-github/issues/7006
- Pull requests view should refresh if a new PR suddenly appears linked in an issue. https://www.github.com/microsoft/vscode-pull-request-github/issues/6898
- Opening Issue editor should be instantaneous. https://www.github.com/microsoft/vscode-pull-request-github/issues/6863

## 0.114.3

### Fixes

- Overusing GitHub search API. https://www.github.com/microsoft/vscode-pull-request-github/issues/7358

## 0.114.2

### Fixes

- Copilot never shows as assignee. https://www.github.com/microsoft/vscode-pull-request-github/issues/7324

## 0.114.1

- Element with id Local Pull Request Branches is already registered. https://www.github.com/microsoft/vscode-pull-request-github/issues/7264

## 0.114.0

### Changes

- We have expanded the integration with GitHub's [Copilot coding agent](https://docs.github.com/en/copilot/how-tos/agents/copilot-coding-agent) (enablement [instructions](https://docs.github.com/en/copilot/how-tos/agents/copilot-coding-agent/enabling-copilot-coding-agent)). You can see the status of all your Coding Agent pull requests in the "Pull Requests" view, and you'll get a badge indicating when a pull request from the Coding Agent has changes.

![Pull Requests view with Copilot status](./documentation/changelog/0.114.0/copilot-pr-status.png)

- Links for viewing the Coding Agent session log now open within VS Code instead of opening in the browser.

![Coding Agent Session Log](./documentation/changelog/0.114.0/session-log.png)

- The `#activePullRequest` tool in Copilot chat now knows more about the active pull request: changes and Coding Agent session information. This tool is automatically attached to chat when opening a pull request created through the coding agent experience, so you can maintain the context and keep working on the pull request if needed to.

- When checking out a pull request which doesn't have any diff from the parent branch, the pull request description will be opened, instead of the changes when `"githubPullRequests.focusedMode"` is set to `"multiDiff"` or `"firstDiff"`.

- You can start a new Coding Agent session by invoking the `#copilotCodingAgent` tool in chat. This tool automatically pushes pending changes to a remote branch and initiates a coding agent session from that branch along with the user's instruction. **Experimental:** Deeper UI integration can be enabled with the `setting(githubPullRequests.codingAgent.uiIntegration)` setting.  Once enabled, a new **Delegate to coding agent** button appears in the Chat view for repositories that have the coding agent enabled.

### Fixes

- Leaving a comment shows a pending comment box with an empty input. https://www.github.com/microsoft/vscode-pull-request-github/issues/7200
- Lack of 👀 reaction in PR view is important for coding agent. https://www.github.com/microsoft/vscode-pull-request-github/issues/7213
- Don't use comment icon to mean quote. https://www.github.com/microsoft/vscode-pull-request-github/issues/7185
- PR view always expands and fetches "All Open". https://www.github.com/microsoft/vscode-pull-request-github/issues/7150
- Expect option to Open issue in editor after creating new issue. https://www.github.com/microsoft/vscode-pull-request-github/issues/7034
- Consider setting a default githubIssues.issueCompletionFormatScm. https://www.github.com/microsoft/vscode-pull-request-github/issues/7017
- Times are inconsistent with .com. https://www.github.com/microsoft/vscode-pull-request-github/issues/7007
- Padawan Start/Stop Events/Icons. https://www.github.com/microsoft/vscode-pull-request-github/issues/7004
- Can't check out a local pull request branch. https://www.github.com/microsoft/vscode-pull-request-github/issues/6994
- Unable to get the currently logged-in user. https://www.github.com/microsoft/vscode-pull-request-github/issues/6971
- Stuck at creating fork. https://www.github.com/microsoft/vscode-pull-request-github/issues/6968

**_Thank You_**

* [@dyhagho (Dyhagho Briceño)](https://www.github.com/dyhagho): fix: Allow Github.com auth when `github-enterprise.uri` is set [PR #7002](https://www.github.com/microsoft/vscode-pull-request-github/pull/7002)

## 0.112.0

### Changes
- Images in comments from private repositories are now shown in pull request file comments.
- The "Notifications" view is now shown by default, collapsed.
- Issue and pull request links in the timeline an in the issue/pull request body are now opened in VS Code, rather than going to the browser.
- The "Assigned to Me" query in the "Pull Requests" view has been removed, and the "Local Pull Request Branches" and "All Open" queries can be removed using the setting `githubPullRequests.queries`. For repositories with Copilot, a "Copilot on My Behalf" query is added when the setting is unconfigured.
- Unassigned events are now shown in the timeline.
- Copilot "start working", "stop working", and "View Session" are now shown in the timeline.

![Copilot start and stop working](./documentation/changelog/0.112.0/copilot-start-stop.png)

### Fixes

- Interference with interactive rebase. https://www.github.com/microsoft/vscode-pull-request-github/issues/4904
- Closed PRs get associated with new branches of the same name. https://www.github.com/microsoft/vscode-pull-request-github/issues/6711
- Fails to open PR's description in some repos on GitHub Enterprise. https://www.github.com/microsoft/vscode-pull-request-github/issues/6736
- Support closing an issue. https://www.github.com/microsoft/vscode-pull-request-github/issues/6864
- Pull request diff shows outdated diff. https://www.github.com/microsoft/vscode-pull-request-github/issues/6889

**_Thank You_**

* [@kabel (Kevin Abel)](https://www.github.com/kabel): Allow verified GitHub emails when none are private [PR #6921](https://www.github.com/microsoft/vscode-pull-request-github/pull/6921)

## 0.110.0

### Changes

- In preparation for the release of [Project Padawan](https://github.blog/news-insights/product-news/github-copilot-the-agent-awakens/), we added support for assigning to Copilot in the issue webview and [at]-mentioning Copilot in comments within files.
- There's a new tool and context available in Copilot chat: `#activePullRequest`. This tool gives Copilot chat information about the pull request you have currently open in a webview (or checked out if no webview is open).

![Ask Copilot to address the comments in the active pull request](./documentation/changelog/0.110.0/copilot-address-comments.png)

- The issue webview will show when an issue is opened from the "Issues" view or from the notifications view.

![Issue webview](./documentation/changelog/0.110.0/issue-webview.png)

- We revisited the top level actions in the Notifications view to make it cleaner, and aligned the display of the Pull Requests view and the Issues view so that they're more consistent.

- There's a new warning before you try to create a pull request when there's already a pull request open for the same branch.

![Warning shown when there's already a pull request for a branch](./documentation/changelog/0.110.0/already-pr-branch.png)

- Pull Request webviews and issue webviews are refreshed every 60 seconds when they are the active tab.
- The default action when adding a comment in a file is now to start a review rather than submit a single comment.
- There's a new action on the Notifications view to mark all pull request notifications with "trivial" updates as done. Enable the action with `githubPullRequests.experimental.notificationsMarkPullRequests`.
- Comment reactions are shown as readonly in the pull request webview (previously not shown at all).

### Fixes

- Extension fails to detect PR branch when using gh co <PR>. https://www.github.com/microsoft/vscode-pull-request-github/issues/6378
- Extension fails to detect PR branch when using gh co <PR> - v0.109.2025040408. https://www.github.com/microsoft/vscode-pull-request-github/issues/6761
- Element with id All Openhttps://www.github.com/microsoft/vscode/pull/238345 is already registered. https://www.github.com/microsoft/vscode-pull-request-github/issues/6615
- Creating a new issue with keyboard only is disrupted by system dialog. https://www.github.com/microsoft/vscode-pull-request-github/issues/6666
- GraphQL error invalid email address when merging PRs. https://www.github.com/microsoft/vscode-pull-request-github/issues/6696
- Usability of PR Summarization in Chat. https://www.github.com/microsoft/vscode-pull-request-github/issues/6698
- deleting branch after squashing PR not working anymore since vscode 1.98.0. https://www.github.com/microsoft/vscode-pull-request-github/issues/6699
- Comments sometimes not resolvable. https://www.github.com/microsoft/vscode-pull-request-github/issues/6702
- Can't search for full name when assigning issues. https://www.github.com/microsoft/vscode-pull-request-github/issues/6748
- removed request for code owners. https://www.github.com/microsoft/vscode-pull-request-github/issues/6788

**_Thank You_**

* [@kabel (Kevin Abel)](https://www.github.com/kabel): Fix merge email confirmation when git config fails [PR #6797](https://www.github.com/microsoft/vscode-pull-request-github/pull/6797)
* [@timrogers (Tim Rogers)](https://www.github.com/timrogers): When `copilot-swe-agent` is the author of a comment, render with the Copilot identity [PR #6794](https://www.github.com/microsoft/vscode-pull-request-github/pull/6794)

## 0.108.0

### Changes

- Notifications in the experimental Notifications view can be marked as done.

### Fixes

- NewIssue.md template doesn't autocomplete Assignees anymore. https://www.github.com/microsoft/vscode-pull-request-github/issues/6709

**_Thank You_**

* [@aedm (Gábor Gyebnár)](https://www.github.com/aedm): Adds `sanitizedLowercaseIssueTitle` to settings docs [PR #6690](https://www.github.com/microsoft/vscode-pull-request-github/pull/6690)

## 0.106.0

### Changes

- You can provide custom instructions for GitHub Copilot when generating pull request titles and descriptions using the setting `github.copilot.chat.pullRequestDescriptionGeneration.instructions`. You can point the setting to a file in your workspace, or you can provide instructions inline in your settings:

```json
{
  "github.copilot.chat.pullRequestDescriptionGeneration.instructions": [
    {
      "text": "Prefix every PR title with an emoji."
    },
  ],
}
```

- We've added validation so that it's harder to accidentally set a `github.com` URL as the GitHub Enterprise URL.

### Fixes

- Unable to authenticate using Github Enterprise. https://www.github.com/microsoft/vscode-pull-request-github/issues/6426
- Cannot add Reviewer to PR once github-actions is added as a reviewer. Cannot add Reviewer to PR once github-actions is added as a reviewer
- On PR to submodule parent package was forked instead of submodule. https://www.github.com/microsoft/vscode-pull-request-github/issues/6492
- Email address for merge commit is not remembered (and cannot be set). https://www.github.com/microsoft/vscode-pull-request-github/issues/6593
- Copy GitHub Permalink doesn't work with custom SSH. https://www.github.com/microsoft/vscode-pull-request-github/issues/6668

**_Thank You_**

* [@christianvuerings (Christian Vuerings)](https://www.github.com/christianvuerings): Fix Copy GitHub Permalink with custom SSH [PR #6669](https://www.github.com/microsoft/vscode-pull-request-github/pull/6669)

## 0.104.1

### Fixes

- Suggest a fix with Copilot results in an error Tool copilot_codebase was not contributed. https://www.github.com/microsoft/vscode-pull-request-github/issues/6632

## 0.104.0

### Changes

- The Pull Requests view supports global queries. All old queries will be migrated when you open your workspace to include the current repo as part of the query. Global query support enables you to use the `org` and `repo` properties.
- As part of the support for global queries, we also now have a `today` variable. This variable can be used to refer to the current day, or it can be used with a minus modifier. Together with the global query support, you can now make queries such as "my PRs in my work org that were created in the last 7 days":

```json
    {
      "label": "My work last 7 days",
      "query": "org:microsoft author:${user} is:closed created:>=${today-7d}"
    }
```
- The context menu in the Pull Requests view has been cleaned up.
- The "pull request" icon shows in the the editor tab for the pull request descriptions.

![Pull request icon in editor tab](./documentation/changelog/0.104.0/pr-icon-tab.png)

- `:<emoji-name>:` style emojis are now supported in comments.
- You can now search with `ctrl+f` in the pull request description webview.
- You can multi-select files in the "Changes in Pull Request" tree view and toggle the selected checkboxes with one click.
- All non-outdated comments for a pull request will show in the "Comments" view when you open the pull-request's description, even if you don't have the PR checked out. They will hide again when all files related to the pull request are closed.
- The "Changes in Pull Request" view has a shortcut for toggling editor commenting.

![The eye icon as a shortcut to toggle off editor commenting](./documentation/changelog/0.104.0/toggle-editor-commenting.png)

- Python is no longer excluded from `@` and `#` completions by default.
- There's a new command to copy a pull request link: "Copy Pull Request Link".
- `git.showInlineOpenFileAction` is now respected in the "Changes in Pull Request" view.
- The "Resolve Conversation" and "Unresolve Conversation" command can now be used from keybindings.

### Fixes

- Files changed doesn't properly reflect changes against non base branch. https://www.github.com/microsoft/vscode-pull-request-github/issues/5545
- Projects quickpick should not have checkboxes when there are no projects. https://www.github.com/microsoft/vscode-pull-request-github/issues/5757
- Added projects need separation. https://www.github.com/microsoft/vscode-pull-request-github/issues/5792
- Make "Make a Suggestion" more clear. https://www.github.com/microsoft/vscode-pull-request-github/issues/6040
- fetching pull requests failed in infinite loop when proxy is unavailable. https://www.github.com/microsoft/vscode-pull-request-github/issues/6063
- Using "Create Pull Request" command clears entered data. https://www.github.com/microsoft/vscode-pull-request-github/issues/6114
- Non GitHub remotes for submodules causes authentication to fail. https://www.github.com/microsoft/vscode-pull-request-github/issues/6140
- "Go to Next Diff in Pull Request" command fails with error. https://www.github.com/microsoft/vscode-pull-request-github/issues/6237
- Keyboard Focus is not clearly visible on cancel button. https://www.github.com/microsoft/vscode-pull-request-github/issues/6449
- Users are not able to access "Reviewers", "Assignees", "Labels", "Project", link present under project and "Milestone" controls via keyboard. https://www.github.com/microsoft/vscode-pull-request-github/issues/6450
- Keyboard focus order is not proper on "Description" and "Create github pull request" screen. https://www.github.com/microsoft/vscode-pull-request-github/issues/6451
- NVDA is not announcing any update when user presses ENTER on "Show" and "Hide" control. https://www.github.com/microsoft/vscode-pull-request-github/issues/6453
- Review/Comment Suggestions are offset by one line if you make local changes first. https://www.github.com/microsoft/vscode-pull-request-github/issues/6495
- When listing workflows running as checks against a PR, include workflow name, not just job name. https://www.github.com/microsoft/vscode-pull-request-github/issues/6497
- Diffing OUTDATED comments with HEAD doesn't work in github.dev. https://www.github.com/microsoft/vscode-pull-request-github/issues/6500
- error when adding file comment to renamed file w/o other changes. https://www.github.com/microsoft/vscode-pull-request-github/issues/6516
- Cannot leave comments on hunks in large diffs. https://www.github.com/microsoft/vscode-pull-request-github/issues/6524
- Share menu multiple selection support. https://www.github.com/microsoft/vscode-pull-request-github/issues/6542
- Comments don't show on non-checked out PR when closing and re-opening the file from the PRs veiw. https://www.github.com/microsoft/vscode-pull-request-github/issues/6571
- Create Pull Request Suggestions silently fails when the suggestion is on the first line. https://www.github.com/microsoft/vscode-pull-request-github/issues/6603

**_Thank You_**

* [@mikeseese (Mike Seese)](https://www.github.com/mikeseese): Add opt-in to always prompt for repo for issue creation and add comment to issue file specifying the repo [PR #6115](https://www.github.com/microsoft/vscode-pull-request-github/pull/6115)
* [@NellyWhads (Nelly Whads)](https://www.github.com/NellyWhads): Remove the python language user mention exception [PR #6525](https://www.github.com/microsoft/vscode-pull-request-github/pull/6525)
* [@Ronny-zzl (Zhang)](https://www.github.com/Ronny-zzl): Don't show hover cards for [at]-mentioned users in JSDocs in jsx and tsx files [PR #6531](https://www.github.com/microsoft/vscode-pull-request-github/pull/6531)

## 0.102.0

### Changes

- The command **GitHub Pull Requests: Close All Pull Request Editors** will close all PR related diff editors and PR original file editors.
- Summarizing a notification with Copilot will print a link to the issue in the Chat view.

![Issue link shown in Copilot summary](./documentation/changelog/0.102.0/issue-link-in-summary.png)

### Fixes

- Enterprise 3.9: GraphQL error Fragment on Bot can't be spread inside RequestedReviewer. https://www.github.com/microsoft/vscode-pull-request-github/issues/6441
- Suggestions end up in unsubmittable pending state. https://www.github.com/microsoft/vscode-pull-request-github/issues/6494
- Comments not possible to save within a submodule. https://www.github.com/microsoft/vscode-pull-request-github/issues/6096
- Globe action to open issue on github.com is missing. https://www.github.com/microsoft/vscode-pull-request-github/issues/6510
- PR creation flow is not smooth anymore. https://www.github.com/microsoft/vscode-pull-request-github/issues/6386
- PR view buttons overflow in narrow viewports. https://www.github.com/microsoft/vscode-pull-request-github/issues/6335

## 0.100.3

### Fixes

- Can't start a review from a comment due to GraphQL error. https://www.github.com/microsoft/vscode-pull-request-github/issues/6467
> Note: This breaks Enterprise 3.9 and earlier again.

## 0.100.1

### Fixes

- Enterprise 3.9: GraphQL error Fragment on Bot can't be spread inside RequestedReviewer. https://www.github.com/microsoft/vscode-pull-request-github/issues/6441

## 0.100.0

### Changes

This month, our focus was on integrating Copilot into GitHub Pull Requests, using the new VS Code extension API, to showcase how Copilot can be added to an extension. These features are behind several settings. To try everything out, you can set the following settings:
- `"githubPullRequests.experimental.chat": true`
- `"githubPullRequests.experimental.notificationsView": true`

#### Copilot integration

- The new `@githubpr` Chat Participant can search for issues on GitHub.

![Copilot issue search for most open bugs in November](./documentation/changelog/0.100.0/copilot-issue-search-most-bugs.png)

- When displaying issues, `@githubpr` will show a markdown table and try to pick the best columns to show based on the search.

![Copilot issue search for closed October bugs](./documentation/changelog/0.100.0/copilot-issue-search.png)

- Each issue listed in the "Issues" view has a new action, "Summarize With Copilot", that will reveal the Chat panel and summarize the selected issue. We also added another action, "Fix With Copilot", that will summarize the selected issue and will use the workspace context to suggest a fix for it.
- We have added an experimental "Notifications" view that lists the user's unread notifications across repositories. By default the notifications are sorted by most recently updated descending, but you can use the "Sort by Priority using Copilot" action from the view title's `...` menu to have Copilot prioritize the notifications. Clicking on each notification trigger an action to summarize the notification using Copilot. The view also contains easily accessible action to mark a notification as read, as well as open the notification on GitHub.com.

### Fixes

- Gift icon is confusing to me here. https://www.github.com/microsoft/vscode-pull-request-github/issues/6289
- Cannot get PR to show that is from a fork and main branch. https://www.github.com/microsoft/vscode-pull-request-github/issues/6267
- Summary review comment buttons do not disable while review is submitting. https://www.github.com/microsoft/vscode-pull-request-github/issues/6261
- Refreshing a PR doesn't refresh comments. https://www.github.com/microsoft/vscode-pull-request-github/issues/6252
- Adding a new Review doesn't update the Tree Control Node. https://www.github.com/microsoft/vscode-pull-request-github/issues/6251
- pr.markFileAsViewed doesn't update the parent nodes. https://www.github.com/microsoft/vscode-pull-request-github/issues/6248
- Infinite error dialogs with GH account mixup. https://www.github.com/microsoft/vscode-pull-request-github/issues/6245
- PRs do not refresh after changing account preferences in dropdown. https://www.github.com/microsoft/vscode-pull-request-github/issues/6244
- Extension should still work if only upstream requires SAML. https://www.github.com/microsoft/vscode-pull-request-github/issues/6159
- Checkbox likes to play Simon Says. https://www.github.com/microsoft/vscode-pull-request-github/issues/3972

## 0.98.0

### Fixes

- Can't approve/reject PRs when in draft mode. https://www.github.com/microsoft/vscode-pull-request-github/issues/6174
- Disallow Make a suggestion button press if already have a suggestion in the comment. https://www.github.com/microsoft/vscode-pull-request-github/issues/6195
- Untracked files in GHPRI view don't have green text decoration. 
- Don't show error "We couldn't find commit" on outdated comments. https://www.github.com/microsoft/vscode-pull-request-github/issues/1691
- Element with id xxx is already registered. https://www.github.com/microsoft/vscode-pull-request-github/issues/6218
- Diff Comment with HEAD button in Comments view sometimes disappears. https://www.github.com/microsoft/vscode-pull-request-github/issues/6157

**_Thank You_**

* [@ixzhao](https://www.github.com/ixzhao): fix quote reply [PR #6230](https://www.github.com/microsoft/vscode-pull-request-github/pull/6230)

## 0.96.0

### Changes

- Local changes to a checked-out PR can be quickly converted to suggestion comments from both the SCM view and from the diff editor context menu.

![Convert local changes to suggestions](./documentation/changelog/0.96.0/convert-to-suggestions.gif)

### Fixes

- Use the editor font code for the diffs. https://www.github.com/microsoft/vscode-pull-request-github/issues/6146
- Sort shorter paths to the top. https://www.github.com/microsoft/vscode-pull-request-github/issues/6143
- Error git config --local branch.main.github-pr-owner-number. https://www.github.com/microsoft/vscode-pull-request-github/issues/6134
- The "accessibility.underlineLinks": true setting is ignored. https://www.github.com/microsoft/vscode-pull-request-github/issues/6122

**_Thank You_**

* [@jmg-duarte (Jose Duarte)](https://www.github.com/jmg-duarte)
  * Use editor font for diff [PR #6148](https://www.github.com/microsoft/vscode-pull-request-github/pull/6148)
  * Make code blocks use the editor's font family by default [PR #6149](https://www.github.com/microsoft/vscode-pull-request-github/pull/6149)

## 0.94.0

### Changes

- You can create revert PRs from the PR description. The PR branch doesn't need to be checked out to create a revert PR.

![Create a revert PR](./documentation/changelog/0.94.0/create-revert-pr.gif)

- As a nice side effect of the enabling reverts, you can now see PRs whose branch has been deleted in the "Pull Requests" view.
- The "Open Pull Request on GitHub.com" action shows even when there are PRs from multiple repos checked out.
- `img` tags in code comments will now properly show the image for public repos.

### Fixes

- Failed to execute git when deleting branches and remotes. https://www.github.com/microsoft/vscode-pull-request-github/issues/6051
- Use notification progress when deleting branches and remotes. https://www.github.com/microsoft/vscode-pull-request-github/issues/6050
- Sign in failed: Error: No auth flow succeeded. https://www.github.com/microsoft/vscode-pull-request-github/issues/6056
- Extension gets rate limited in a many-repo setup: http forbidden response when adding reviewer after creating pull request. https://www.github.com/microsoft/vscode-pull-request-github/issues/6042
- File can't be opened, redirects me to browser. https://www.github.com/microsoft/vscode-pull-request-github/issues/5827

**_Thank You_**

* [@Santhoshmani1 (Santhosh Mani )](https://www.github.com/Santhoshmani1): Feature : Add open pr on github from pr description node [PR #6020](https://www.github.com/microsoft/vscode-pull-request-github/pull/6020)

## 0.92.0

### Changes

- Dates are listed in the "Commits" subtree for checked out PRs

  ![commits subtree with dates](./documentation/changelog/0.92.0/date-of-commits.png)

### Fixes

- Extension asks for commenting ranges on a file that got deleted in PR. https://www.github.com/microsoft/vscode-pull-request-github/issues/6046
- An error occurred while loading the image (renamed picture). https://www.github.com/microsoft/vscode-pull-request-github/issues/6008
- GitHub Issue trigger - [ ] does not work. https://www.github.com/microsoft/vscode-pull-request-github/issues/6007
- PR Title generation surrounded by "quotes". https://www.github.com/microsoft/vscode-pull-request-github/issues/6002
- Unresolve comment does not move focus to it. https://www.github.com/microsoft/vscode-pull-request-github/issues/5973
</blockquote>
</details>

Updates `github.vscode-github-actions` from 0.29.1 to 0.31.0
<details>
<summary>Release notes</summary>
<blockquote>





## What's Changed
* Fix npm security vulnerabilities by [at]rentziass in https://www.github.com/github/vscode-github-actions/pull/553
* Release version 0.30.0 by [at]github-actions[bot] in https://www.github.com/github/vscode-github-actions/pull/557

## New Contributors
* [at]rentziass made their first contribution in https://www.github.com/github/vscode-github-actions/pull/553

**Full Changelog**: https://www.github.com/github/vscode-github-actions/compare/release-v0.29.1...release-v0.30.0
</blockquote>
</details>
