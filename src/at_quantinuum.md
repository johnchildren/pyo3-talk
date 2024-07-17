# At Quantinuum

## [tket2](https://github.com/CQCL/tket2)

Version 2 of the TKET quantum compiler. TKET 1 was implemented in C++ and exposed to python as `pytket`
via pybind11. Segfaults were historically a bit of an issue, as was parallelism and onboarding new
developers. Initially at least Rust does seem to make this better.

`tket2` has a dedicated `tket2-py` crate that contains bindings and some additional python code,
which might be the place we have used `pyo3` the most internally.

Interestingly there's a function on the Circuit object that will convert it into a TKET 1 version of the
circuit (C++).

## [tierkreis](https://github.com/CQCL/tierkreis) (typechecker)

tierkreis is a higher-order dataflow graph program representation and runtime. While a python implementation
does exist of both the runtime and worker functions, rather than re-implement our Rust type checker
in Python, we exposed it as a python module via PyO3. Unfortunately this is still closed source for now,
but an open source reference implementation exists.

## [portgraph](https://github.com/CQCL/portgraph)

Has python bindings because they were easy to add, though updating PyO3 is a little annoying as it
is a breaking change every time!
