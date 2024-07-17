# Cool Things

Nice things in the PyO3 ecosystem that I think are worth mentioning.

## [maturin](https://www.maturin.rs/)

You will probably end up using this tool to build and package your PyO3 projects.

Provides a CLI interface for development as well as a [PEP-517](https://peps.python.org/pep-0517/) compatible build-backend.

## [dict-derive](https://github.com/gperinazzo/dict-derive)

Derive Python dictionary compatibility for your structs to get automatic type conversions!

## [pyo3-asyncio](https://github.com/awestlake87/pyo3-asyncio)

Have `asyncio` and `tokio` become too simple to understand? Why not use them both together?!

You can create futures on either runtime and await their completion, potentially useful
for progressively rewriting asynchronous applications into Rust (with some overhead).
