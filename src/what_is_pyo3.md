# What is PyO3?

[PyO3](https://pyo3.rs) is a Rust library for the Python language, targeting a few different areas.

Primary it is useful for two main areas:  
  - Writing Python modules in Rust.
  - Interacting with Python as a shared library.

Similar to C++ libraries such as [pybind11](https://pybind11.readthedocs.io) and [Boost.Python](https://www.boost.org/doc/libs/1_58_0/libs/python/doc/)

## Where does it fit in?

- Speeding up slow parts of common Python operations.
- Exposing good Rust libraries to Python.
- Progressively re-writing your Python application in Rust.
- Progressively re-writing your Rust application in Python. (?)
