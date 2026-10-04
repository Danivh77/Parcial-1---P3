# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate

@moduledoc """
  Módulo que contiene las funciones para calcular la liquidación de los confeccionistas.
  -versión 1.0
  -autoras: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate
  -fecha: 2026-03-10
  """

defmodule Liquidacion do

  #valores constantes

  @tarifa_base 3200
  @prendas_bonificacion 120
  @dias_productivos 6
  @bonificacion_diaria 18_000
  @alquiler_diario 15_000

  @doc """
  función que calcula el valor de un lote según la cantidad de prendas y defectos.
  """

  def valor_lote(lote) do
    valor_base=lote.prendas * @tarifa_base

    # regla según porcentaje de defectos

    cond do
      lote.defectos <= 2 -> valor_base*1.07
      lote.defectos <= 5 -> valor_base
      lote.defectos <= 10 -> valor_base * 0.88
      true -> valor_base * 0.75
    end
    
  end

  def prendas_confeccionista_dia(lotes, codigo, dia) do
    # sumar prendas de lotes válidos
  end

  def bonificacion_dia(lotes_validos, codigo, dia) do
    if prendas_confeccionista_dia(lotes_validos, codigo, dia) >= @prendas_bonificacion do
      @bonificacion_diaria
    else
      0
    end
  end

  def dias_trabajados(lotes_validos, codigo) do
    # cantidad de días distintos con lotes válidos
  end

  def calcular_alquiler(confeccionista, lotes_validos) do
    case confeccionista.alquiler do
      true -> @alquiler_diario * dias_trabajados(lotes_validos, confeccionista.codigo)
      false -> 0
    end


  end

  def liquidar_todos(confeccionistas, lotes_validos) do
    # generar liquidación de todos
    Enum.map(confeccionistas, fn confeccionista ->
      liquidar_confeccionista(confeccionista, lotes_validos)
    end)
  end

  def liquidar_confeccionista(confeccionista, lotes_validos) do
    # generar liquidación de un confeccionista
    suma_lotes=Enum.reduce(lotes_validos, 0, fn lote, acc ->
        if lote.confeccionista == confeccionista.codigo do
          acc + valor_lote(lote)
        else
          acc
        end
      end)

    suma_bonificaciones = Enum.reduce(1..@dias_produccion, 0, fn dia, acc ->
    acc + bonificacion_dia(lotes_validos, confeccionista.codigo, dia)
    end)

    descuento_alquiler = calcular_alquiler(confeccionista, lotes_validos)

    neto=suma_lotes + suma_bonificaciones - descuento_alquiler
  end


end
