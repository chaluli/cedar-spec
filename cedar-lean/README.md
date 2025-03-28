# Cedar Lean

This folder contains the Lean formalization of, and proofs about, Cedar.

Auto-generated documentation is available at <https://cedar-policy.github.io/cedar-spec/docs/>.

## Setup

Follow [these instructions](https://leanprover.github.io/lean4/doc/setup.html) to set up Lean and install the VS Code plugin.

## Usage

To use VS Code, open the `cedar-lean` folder as the root directory.

> [!WARNING]
> The VS Code Lean plugin _will not_ work properly if this project is opened with `cedar-spec` as the root.

To build code and proofs from the command line:

```shell
cd cedar-lean
lake update
lake build Cedar
```

To run the unit tests:

```shell
lake exe CedarUnitTests
```

To run the CLI, use `lake exe Cli`. We provide some example inputs in `Cli/json-inputs`. The authorization examples should all return "allow" and the validation examples should return "ok".

```shell
lake exe Cli authorize Cli/json-inputs/authorize/example2a.json
lake exe Cli validate Cli/json-inputs/validate/example2a.json
```

## Updating the Lean toolchain

To change the version of Lean used, you will need to update two files:

* `lean-toolchain` controls the Lean version. You can find all available versions [here](https://github.com/leanprover/lean4/releases).
* `lakefile.lean` lists the project dependencies. Make sure that `batteries` and `doc-gen4` are pinned to commits that match the Lean version.

## Contributing

To [contribute](../CONTRIBUTING.md) Lean code or proofs, follow these [style guidelines](GUIDE.md).

## Key definitions

Definitional engine ([`Cedar/Spec/`](Cedar/Spec/))

* `evaluate` returns the result of evaluating an expression.
* `satisfied` checks if a policy is satisfied for a given request and entities.
* `isAuthorized` checks if a request is allowed or denied for a given policy store and entities.

Definitional validator ([`Cedar/Validation/`](Cedar/Validation/))

* `typeOf` returns the result of type checking an expression against a schema.

## Verified properties

Basic authorization theorems ([`Cedar/Thm/Authorization.lean`](Cedar/Thm/Authorization.lean))

* If some forbid policy is satisfied, then the request is denied.
* A request is allowed only if it is explicitly permitted (i.e., there is at least one permit policy that is satisfied).
* If not explicitly permitted, a request is denied.
* Authorization produces the same result regardless of policy evaluation order or duplicates.

Sound policy slicing ([`Cedar/Thm/Slicing.lean`](Cedar/Thm/Slicing.lean))

* Given a _sound policy slice_, the result of authorization is the same with the slice as it is with the full policy store.

Sound type checking ([`Cedar/Thm/Typechecking.lean`](Cedar/Thm/Typechecking.lean))

* If an expression is well-typed according to the typechecker, then either evaluation returns a value of that type, or it returns an error of type
`entityDoesNotExist`, `extensionError`, or `arithBoundsError`. All other errors are impossible.
