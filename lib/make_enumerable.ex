defmodule MakeEnumerable do
  @moduledoc """

    Makes your structures enumerable!

    The `MakeEnumerable` module injects `defimpl Enumerable` for your structs,
    as structs are basically `maps` with special tag (member) `__struct__`.
    The module hides the tag `__struct__` and delegates all other members
    to map to be `Enumerable`.


    ```
    defmodule Bar do
      use MakeEnumerable
      defstruct foo: "a", baz: 10
    end

    iex> import Bar
    iex> Enum.map(%Bar{}, fn({k, v}) -> {k, v} end)
    [baz: 10, foo: "a"]
    ```

  """

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defimpl Enumerable, for: __MODULE__ do
        def count(struct) do
          map =
            struct
            |> Map.from_struct()

          {:ok, map_size(map)}
        end

        def member?(struct, {key, value}) do
          map =
            struct
            |> Map.from_struct()

          {:ok, match?(%{^key => ^value}, map)}
        end

        def member?(_map, _other) do
          {:ok, false}
        end

        def slice(struct) do
          map =
            struct
            |> Map.from_struct()
          
          Enumerable.Map.slice(map)
        end

        def reduce(struct, acc, fun) do
          map =
            struct
            |> Map.from_struct()

          Enumerable.List.reduce(:maps.to_list(map), acc, fun)
        end
      end
    end
  end
end
