# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate

defmodule Util do
  @moduledoc """
  Funciones de apoyo del programa: conversión de texto a números, formato de
  dinero, cálculo de máximos con empates y lectura de la consola.
  -versión 1.0
  -autoras: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate
  -fecha: 2026-10-04
  """

  # Entrada y salida (funciones impuras del módulo)

  @doc """
  Imprime un mensaje en la consola.
  """
  def mostrar_mensaje(mensaje) do
    IO.puts(mensaje)
  end

  @doc """
  Muestra `mensaje`, lee una línea de la consola y devuelve el texto sin
  espacios en los extremos.
  """
  def leer_linea(mensaje) do
    case IO.gets(mensaje) do
      texto when is_binary(texto) -> String.trim(texto)
      _ -> ""
    end
  end

  # Conversión de texto a número (el error se devuelve como tupla)

  @doc """
  Convierte un texto en entero.
  Devuelve `{:ok, entero}` o `{:error, :formato_invalido}`.
  """
  def a_entero(texto) when is_binary(texto) do
    try do
      {:ok, texto |> String.trim() |> String.to_integer()}
    rescue
      ArgumentError -> {:error, :formato_invalido}
    end
  end

  def a_entero(_otro), do: {:error, :formato_invalido}

  @doc """
  Convierte un texto en número decimal (con punto, por ejemplo "3.5").

  Devuelve `{:ok, flotante}` o `{:error, :formato_invalido}`.
  """
  def a_flotante(texto) when is_binary(texto) do
    try do
      {:ok, texto |> String.trim() |> String.to_float()}
    rescue
      ArgumentError -> {:error, :formato_invalido}
    end
  end

  def a_flotante(_otro), do: {:error, :formato_invalido}

  @doc """
  Convierte un texto en número, entero o decimal.
  """
  def a_numero(texto) do
    case a_entero(texto) do
      {:ok, entero} -> {:ok, entero}
      {:error, _motivo} -> a_flotante(texto)
    end
  end

  @doc """
  Separa una línea por `separador` (por defecto ";") y recorta cada campo.
  """
  def separar_campos(linea, separador \\ ";") when is_binary(linea) do
    linea
    |> String.split(separador)
    |> Enum.map(&String.trim/1)
  end

  @doc """
  Indica si un texto está vacío o solo tiene espacios.
  """
  def vacio?(texto) when is_binary(texto), do: String.trim(texto) == ""

  # Dinero

  @doc """
  Redondea un valor monetario a dos decimales.
  """
  def redondear_dinero(valor) when is_number(valor) do
    Float.round(valor * 1.0, 2)
  end

  @doc """
  Da formato a un valor monetario con dos decimales y sin notación científica.
  """
  def formatear_dinero(valor) when is_number(valor) do
    "$" <> :erlang.float_to_binary(redondear_dinero(valor), decimals: 2)
  end

  # Máximos con empates

  @doc """
  Devuelve todos los elementos de `coleccion` cuya clave, calculada con
  `clave_fn`, es la máxima. Si hay empate, devuelve todos los empatados.
  Si la colección está vacía, devuelve `[]`.
  """
  def maximos_por(coleccion, clave_fn) when is_function(clave_fn, 1) do
    if Enum.empty?(coleccion) do
      []
    else
      maximo = coleccion |> Enum.map(clave_fn) |> Enum.max()
      Enum.filter(coleccion, fn elemento -> clave_fn.(elemento) == maximo end)
    end
  end

end
