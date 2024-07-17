# Major Projects

## [Polars](https://pola.rs/)

Polars is a data frame library similar to [pandas](https://pandas.pydata.org/), but with a few
extra features that Rust enables, notably using [rayon](https://crates.io/crates/rayon) for parallelism and the 
Rust implementation of [Apache Arrow](https://arrow.apache.org/) for a fast columnar store.


```python
import polars as pl

q = (
    pl.scan_csv("docs/data/iris.csv")
    .filter(pl.col("sepal_length") > 5)
    .group_by("species")
    .agg(pl.all().sum())
)

df = q.collect()
```

I haven't used it personally but it has a lot of github starsi and a fancy website!

## [orjson](https://github.com/ijl/orjson)

orjson is a serialisation library for JSON that is a slightly more ergonomic
drop in replacement for the standard library JSON module. It is both quite a bit faster than the
standard library version and handles objects from the `uuid` and `datetime` libraries in a sensible way.

I think it uses [serde](https://serde.rs/) for serialization but I'm not entirely certain.

```python
import orjson
from uuid import uuid4

orjson.dumps({"some id": uuid4()}) # Wouldn't be possible with `json`.
```

I use this library *A LOT* as it's both more convenient and quite fast.

## [pydantic-core](https://github.com/pydantic/pydantic-core)

[pydantic](https://docs.pydantic.dev/latest/) is a very popular python library for data validation
and general python class utilities. It will generate various methods for you as well as generate
[jsonschema](https://json-schema.org/) for your models. Importantly however it will also validate your data on
construction/deserialisation and this _used_ to be quite slow. Since re-writing the core validation
logic in Rust with PyO3 this seems to have been much improved however.

```python
from datetime import datetime

from pydantic import BaseModel

class MyStuff(BaseModel):
    greeting: str
    end_of_the_world: datetime


stuff = MyStuff(greeting="hello", end_of_the_world=datetime.utcnow())
```

I also use this library *A LOT* as it works very nicely with [FastAPI](https://fastapi.tiangolo.com/) for
data model validation and also lets you generate [OpenAPI](https://www.openapis.org/what-is-openapi)
specifications automatically from your python web applications.

## [safetensors](https://github.com/huggingface/safetensors)

Reasonably popular in the ML community, a safe format to distribute model weights efficiently
without arbitrary code execution!

## [rustworkx](https://github.com/Qiskit/rustworkx)

Uses PyO3 to provide an interface similar to [networkx](https://networkx.org/) but backed by [petgraph](https://crates.io/crates/petgraph).

Interestingly also developed by another Quantum Computing company!

## [wasmer-python](https://github.com/wasmerio/wasmer-python)

Uses PyO3 to expose the [wasmer](https://wasmer.io/) runtime to Python for executing WASM code.
