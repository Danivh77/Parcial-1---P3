# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuéllar Vélez, Nikoll Alzate

defmodule Validacion do

  @moduledoc """
  Validación de los lotes de producción.
  -versión 1.0
  -autoras: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate
  -fecha: 2026-10-04
  """

  # Parámetros de validación (atributos de módulo).

  @dia_minimo 1
  @dia_maximo 6
  @prendas_minimas 1
  @prendas_maximas 180
  @defectos_minimo 0
  @defectos_maximo 100

  # Parámetros expuestos para otros módulos

  @doc """
  Devuelve el rango de días válidos (1..6).
  """
  def dias, do: @dia_minimo..@dia_maximo

  @doc """
  Devuelve el máximo de prendas permitido por lote.
  """
  def max_prendas, do: @prendas_maximas

  # Validación de lotes

  @doc """
  Valida un lote aplicando las cinco reglas en orden.
  """
  def validar_lote(lote, confeccionistas, lineas) do
    with :ok <- validar_confeccionista(Map.get(lote, :confeccionista), confeccionistas),
         :ok <- validar_linea(Map.get(lote, :linea), lineas),
         :ok <- validar_dia(Map.get(lote, :dia)),
         :ok <- validar_prendas(Map.get(lote, :prendas)),
         :ok <- validar_porcentaje(Map.get(lote, :defectos)) do
      {:ok, lote}
    end
  end

  @doc """
  Valida una lista de lotes y los separa en válidos y rechazados.
  """
  def validar_lotes(lotes, confeccionistas, lineas) do
    resultados =
      Enum.map(lotes, fn lote ->
        {lote, validar_lote(lote, confeccionistas, lineas)}
      end)

    validos = for {_lote, {:ok, lote_valido}} <- resultados, do: lote_valido
    rechazados = for {lote, {:error, motivo}} <- resultados, do: {lote, motivo}

    {validos, rechazados}
  end

  # Lote adicional ingresado por consola

  @doc """
  Convierte el texto `confeccionista;linea;dia;prendas;defectos` en un lote.
  """

  def parsear_lote_adicional(texto) when is_binary(texto) do
    with [codigo, linea, dia, prendas, defectos] <- Util.separar_campos(texto),
         {:ok, dia} <- Util.a_entero(dia),
         {:ok, prendas} <- Util.a_entero(prendas),
         {:ok, defectos} <- Util.a_numero(defectos) do
      {:ok,
       %{
         confeccionista: codigo,
         linea: linea,
         dia: dia,
         prendas: prendas,
         defectos: defectos
       }}
    else
      _ -> {:error, :formato_invalido}
    end
  end

  def parsear_lote_adicional(_otro), do: {:error, :formato_invalido}

  # Reglas individuales (privadas): devuelven :ok o {:error, motivo}

  defp validar_confeccionista(codigo, confeccionistas) do
    if Map.has_key?(confeccionistas, codigo) do
      :ok
    else
      {:error, :confeccionista_desconocido}
    end
  end

  defp validar_linea(id_linea, lineas) do
    if Map.has_key?(lineas, id_linea) do
      :ok
    else
      {:error, :linea_desconocida}
    end
  end

  defp validar_dia(dia)
       when is_integer(dia) and dia >= @dia_minimo and dia <= @dia_maximo,
       do: :ok

  defp validar_dia(_dia), do: {:error, :dia_invalido}

  defp validar_prendas(prendas)
       when is_integer(prendas) and prendas >= @prendas_minimas and prendas <= @prendas_maximas,
       do: :ok

  defp validar_prendas(_prendas), do: {:error, :prendas_fuera_de_rango}

  defp validar_porcentaje(defectos)
       when is_number(defectos) and defectos >= @defectos_minimo and defectos <= @defectos_maximo,
       do: :ok

  defp validar_porcentaje(_defectos), do: {:error, :porcentaje_invalido}

end
