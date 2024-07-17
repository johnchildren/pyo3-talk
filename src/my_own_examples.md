# My Own Examples

## Ordantic

I was quite interested in the possibility of defining structs in Rust and then getting
pydantic compatible models through proc_macro usage. This ended up looking something like
this:

```rust
use ordantic_derive::model;

#[model]
struct ExampleModel {
    name: String,
    number: i64,
}

#[model]
struct ExampleModel2 {
    model: ExampleModel,
}
```

However to get this fully compatible with pydantic I needed to make the package
compatible with pydantic-core, to do this I was planning to re-use the SchemaValidator
types in pydantic-core but consume it as a Rust crate rather than as a python module.

I ran out of steam on this idea however as the proc_macro I was writing was becoming
pretty unwieldly and pydantic-core wasn't really stable enough when I was trying this.

Could be worth revisting. Here is a bit of the very nasty code gen:

```rust
let output = quote! {
    #[pyo3::pyclass]
    #[derive(Debug, PartialEq, Clone, serde::Serialize, serde::Deserialize, schemars::JsonSchema)]
    #struct_

    #[pyo3::pymethods]
    impl #ident {
        #[new]
        fn new(#(#new_args),*) -> Self {
            return Self { #(#new_values),* };
        }

        fn __richcmp__(&self, other: &Self, op: pyo3::basic::CompareOp) -> pyo3::PyResult<bool> {
            match op {
                pyo3::basic::CompareOp::Eq => Ok(self == other),
                pyo3::basic::CompareOp::Ne => Ok(self != other),
                _ => Err(ordantic::OrdanticError::new_err("not implemented"))
            }
        }

        fn dict(&self, py: pyo3::Python<'_>) -> pyo3::PyResult<pyo3::PyObject> {
            self.to_model_dict(py)
        }

        fn json(&self) -> pyo3::PyResult<String> {
            let json_str = serde_json::to_string(&self)
                .map_err(|_| ordantic::OrdanticError::new_err("failed to serialize"))?;
            Ok(json_str)
        }

        #[classmethod]
        fn parse_raw(_cls: &pyo3::types::PyType, string: &str) -> pyo3::PyResult<Self> {
            let self_ = serde_json::from_str(string)
                .map_err(|_| ordantic::OrdanticError::new_err("failed to deserialize"))?;
            Ok(self_)
        }

        #[classmethod]
        fn schema<'py>(_cls: &'py pyo3::types::PyType, py: pyo3::Python<'py>) -> pyo3::PyResult<&'py pyo3::types::PyDict> {
            let schema = schemars::schema_for!(#ident);
            let dict = pyo3::types::PyDict::new(py);

            if let Some(meta_schema) = schema.meta_schema {
                dict.set_item("$schema", meta_schema)?;
            }

            dict.set_item("title", "ExampleModel")?;
            dict.set_item("type", "object")?;

            for (field, definition) in schema.definitions {
                //dict.set_item(field, definition)?;
            }

            Ok(dict)
        }

        #[classmethod]
        fn schema_json(_cls: &pyo3::types::PyType) -> pyo3::PyResult<String> {
            let schema = schemars::schema_for!(#ident);
            let json_str = serde_json::to_string(&schema)
                .map_err(|_| ordantic::OrdanticError::new_err("failed to serialize"))?;
            Ok(json_str)
        }

        #[classmethod]
        fn __get_validators__(_cls: &pyo3::types::PyType) -> pyo3::PyResult<ordantic::ValidatorIterator> {
            let schema_validators = Vec::new();
            Ok(ordantic::ValidatorIterator::new(schema_validators))
        }
    }

    impl ordantic::ToModelDict for #ident {
        fn to_model_dict<'py>(&self, py: pyo3::Python<'py>) -> pyo3::PyResult<pyo3::PyObject> {
            let dict = pyo3::types::PyDict::new(py);
            #(#dict_items)*
            Ok(dict.into())
        }
    }
};
```

## Python Actor

In an early version of tierkreis I tried to write an actix worker that would run python code
from a specific virtual environment in a process pool. This would potentially allow the avoidance
of networking when python code needed to be evaluated by the runtime.

This actually worked, though was a bit of a nightmare to implement. It meant you could embed python
functions directly into the computation graphs as long as there was an obvious type conversion.

```rust
#[actix::test]
async fn simple_snippet() -> Result<(), pyo3::PyErr> {
    let python_actor = PythonActor::try_new()?.start();

    let mut kwargs = HashMap::new();
    kwargs.insert("a".to_string(), Value::Int(2));
    kwargs.insert("b".to_string(), Value::Int(3));

    let mut returns = HashSet::new();
    returns.insert("c".to_string());

    let outputs = python_actor
        .send(RunPythonCode2 {
            module: "tierkreis_nodes".to_string(),
            function: "add".to_string(),
            kwargs,
            returns,
        })
        .await
        .unwrap()?
        .0;

    assert_eq!(outputs.get("c"), Some(&Value::Int(5)));

    Ok(())
}
```

where `add` was defined in a file as:
```python
def add(a: int, b: int) -> Dict[str, Any]:
    return {"c": a + b}
```

Unfortunately this didn't really fit into the longer term architecture of the project and
so was dropped.

Looking back at the code it does seem pretty difficult to follow so perhaps it was a bit
too magical...
