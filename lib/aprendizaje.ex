defmodule Usuario do
  defstruct [:id, :nombre, :edad]
end

defmodule Aprendizaje do
  @moduledoc """
  Documentation for `Aprendizaje`.
  """

  @spec main() :: :world
  @doc """
  Prueba de Mnesia.

  ## Examples

  iex> Aprendizaje.main()
  :world

  """
  def main do
    # Iniciar Mnesia
    :mnesia.start()

    # Crear tabla si no existe
    case :mnesia.create_table(:usuarios, [attributes: [:id, :nombre, :edad]]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, :usuarios}} -> :ok
      _ -> :error
    end

    # Esperar a que la tabla esté disponible - IMPORTANTE!
    :mnesia.wait_for_tables([:usuarios], 5000)

    # Escribir en la tabla
    :mnesia.dirty_write({:usuarios, 1, "Alice", 30})

    # Leer de la tabla
    case :mnesia.dirty_read({:usuarios, 1}) do
      [] -> IO.inspect("No data found")
      [record] -> IO.inspect(record)
    end

    # Ejemplo con struct
    usuario = %Usuario{id: 2, nombre: "Pepe", edad: 39}
    IO.inspect(usuario)
    :mnesia.dirty_write({:usuarios, usuario.id, usuario.nombre, usuario.edad})
    case :mnesia.dirty_read({:usuarios, 2}) do
      [] -> IO.inspect("No data found")
      [record] -> IO.inspect(record)
    end

## Transacciones
    :mnesia.transaction(fn ->
      :mnesia.write({:usuarios, 3, "Juan", 25})
    end)

    :mnesia.transaction(fn ->
      case :mnesia.read({:usuarios, 3}) do
        [] -> IO.inspect("Nada encontrado")
        [record] -> IO.inspect(record, label: "Desde transaction")
      end
    end)

    :world
  end
end
