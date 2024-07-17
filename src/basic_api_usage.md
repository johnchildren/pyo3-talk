# Basic API usage

A slighly digested version of the PyO3 documentation.

## Using Rust from Python

### Exposing a Rust function to Python

```rust
use pyo3::prelude::*;

#[pyfunction]
fn add_two_numbers(a: i64, b: i64) -> i64 {
  a + b
}

#[pymodule]
fn basic(m: &Bound<'_, PyModule>) -> PyResult<()> {
  m.add_function(wrap_pyfunction!(add_two_numbers, m)?)?;
}
```

After building the module becomes:

```python
from basic import add_two_numbers

add_two_numbers(1, 2)
```

### Creating a Python class in Rust

```rust
use pyo3::prelude::*;

#[pyclass]
struct ObviousClass {
  user_value: int
  secret_value: String
}

#[pymethods]
impl ObviousClass {
  #[new]
  fn new(user_value: int) -> Self {
    Self { user_value, secret_value: "shangri-la".to_string() }
  } 
}

#[pymodule]
fn classy(m: &Bound<'_, PyModule>) -> PyResult<()> {
  m.add_class::<ObviousClass>()?;
}
```

After building the module becomes:

```python
from classy_module import ObviousClass

instance = ObviousClass(42)
```

Similar attributes to `new` exist for:

* `getter`
* `setter`
* `staticmethod`
* `classmethod`
* `classattr`

[See the PyO3 docs](https://pyo3.rs/v0.22.1/class#instance-methods)

### Type Conversions

Note that in the function and class examples I use basic Rust interger types for all function
signatures, these get implicitly copied(?) across the Rust/Python boundary, but more complex
behaviour is also possible. Automatic conversion is supported for many common built-in python types
and is also supported for python types like `datetime`, Path` and more.

[See the PyO3 docs for a full list.](https://pyo3.rs/v0.22.1/conversions/tables)

For more advanced conversions there were types like `PyAny` that let you do the conversion
yourself, though this seems to be deprecated now. 

### Limitations

For classes:
* No lifetime parameters
* No generic parameters

### Error handling

Rust structs that support a `From` instance for `PyErr` will be automatically converted to python exceptions or lets you return
simple error messages using a few different provided error types such as `PyValueError`.

PyO3 also provides a macro for defining [python exceptions](https://pyo3.rs/v0.22.1/exception#python-exceptions) which can be somewhat handy
as they can be imported and checked in python code, but the usefulness depends a lot on how much detail you put into them.

Using PyO3 versus pure python can be a bit tricky in this respect as you won't get stack trace information for exceptions
thrown from Rust code (understandably), so the usefulness of the exceptions depends a lot more on how much detail you include in them.

## Calling Python from Rust 

It's also possible to call Python from Rust, but this gets a little hairy quite quickly!

When trying to do this you will quickly encounter the [GIL lifetime](https://pyo3.rs/v0.22.1/python-from-rust#the-py-lifetime) as
well as some of the implementation details of the Python language, but if you try to do type conversions, throw exceptions or call
other python functions, you will need to figure this out a little bit.

### Calling functions

```rust
use pyo3::prelude::*;

fn main() -> PyResult<()> {
  Python::with_gil(|py| {
    // Import the `builtins` python module.
    let builtins = PyModule::import_bound(py, "builtins")?;

    // Get the `print` function.
    let python_print = builtins.get_attr("print")

    // Call the `print` function with a &str.
    python_print.call1(("hello from python",))?;

    Ok(())
  })
}
```
