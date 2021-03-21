# Demo

A simple demo showcasing how to use these bindings with multiple threads and with tracked heap allocations. Don't forget to define TRACY_ENABLE to true for the tracing to come into effect.

```sh
odin run . -define:TRACY_ENABLE=true
```

The demo should look something like this when collecting to Tracy server application:

![image](https://user-images.githubusercontent.com/6025293/111910580-3d9c1780-8a62-11eb-9110-91a61f454d95.png)
