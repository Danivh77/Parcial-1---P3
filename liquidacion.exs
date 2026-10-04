# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuéllar Vélez, Nikoll Alzate

@moduledoc """
  Módulo que contiene las funciones para calcular la liquidación de los confeccionistas.
  -versión 1.0
  -autoras: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate
  -fecha: 2026-03-10
  """

defmodule Liquidacion do
  @moduledoc """
  Liquidación de la producción semanal de los confeccionistas.

  Todas las funciones son puras: reciben los lotes ya validados y devuelven
  valores, sin imprimir nada. El valor de un lote, la bonificación diaria y
  el alquiler se calculan en funciones separadas.

  Para acumular las prendas producidas por confeccionista y día se utiliza
  un mapa cuyas claves son tuplas de la forma {codigo_confeccionista, dia}.

  Los días de producción (1 al 6) se consultan en `Validacion.dias/0`.

  version 2.0
  Autoras: Laura Daniela Vega Herrera, Elizabeth Cuéllar Vélez, Nikoll Alzate
  fecha: 2026-10-04
  """

  # Parámetros de liquidación (atributos de módulo, según el enunciado).
  @tarifa_base 3200
  @prendas_bonificacion 120
  @bonificacion_diaria 18_000
  @alquiler_diario 15_000

  # ---------------------------------------------------------------
  # Valor de un lote
  # ---------------------------------------------------------------

  @doc """
  Calcula el valor de un lote según sus prendas y su porcentaje de defectos.

  `valor_base = prendas * 3200`, con este ajuste:

    * hasta 2 %             -> bonificación del 7 %
    * más de 2 % hasta 5 %  -> sin ajuste
    * más de 5 % hasta 10 % -> descuento del 12 %
    * más de 10 %           -> descuento del 25 %

  El resultado se redondea a dos decimales para evitar residuos de punto
  flotante.

  ## Ejemplos

      iex> Liquidacion.valor_lote(%{prendas: 70, defectos: 1.5})
      239680.0
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

    valor_base = lote.prendas * @tarifa_base

    valor =
      cond do
        lote.defectos <= 2 -> valor_base * 1.07
        lote.defectos <= 5 -> valor_base
        lote.defectos <= 10 -> valor_base * 0.88
        true -> valor_base * 0.75
      end

    Util.redondear_dinero(valor)
  end

  # ---------------------------------------------------------------
  # Productividad diaria y bonificación
  # ---------------------------------------------------------------

  @doc """
  Acumula las prendas válidas por confeccionista y día.

  Devuelve un mapa cuyas claves son tuplas de la forma
  `{codigo_confeccionista, dia}` y cuyos valores corresponden
  al total de prendas acumuladas en esa jornada.
  """
  def acumular_prendas_por_dia(lotes_validos) do
    Enum.reduce(lotes_validos, %{}, fn lote, acumulados ->
      clave = {lote.confeccionista, lote.dia}

      Map.update(
        acumulados,
        clave,
        lote.prendas,
        fn prendas_acumuladas ->
          prendas_acumuladas + lote.prendas
        end
      )
    end)
  end

  @doc """
  Devuelve la cantidad de prendas acumuladas por un confeccionista
  en un día determinado.

  La búsqueda se realiza en el mapa de resultados intermedios usando
  la clave `{codigo_confeccionista, dia}`.
  """
  def prendas_confeccionista_dia(prendas_por_dia, codigo, dia) do
    Map.get(prendas_por_dia, {codigo, dia}, 0)
  end

  @doc """
  Bonificación de un confeccionista en un día: $18.000 si acumuló 120
  prendas o más en lotes válidos ese día, y 0 en caso contrario.
  """
  def bonificacion_dia(prendas_por_dia, codigo, dia) do
    if prendas_confeccionista_dia(prendas_por_dia, codigo, dia) >= @prendas_bonificacion do
      @bonificacion_diaria
    else
      0
    end
  end

  # ---------------------------------------------------------------
  # Alquiler de máquinas
  # ---------------------------------------------------------------

  @doc """
  Cantidad de días distintos en los que el confeccionista tiene al menos un
  lote válido.
  """
  def dias_trabajados(lotes_validos, codigo) do
    lotes_validos
    |> Enum.filter(fn lote -> lote.confeccionista == codigo end)
    |> Enum.map(fn lote -> lote.dia end)
    |> Enum.uniq()
    |> length()
  end

  @doc """
  Descuento por alquiler: $15.000 por cada día trabajado, solo para quienes
  usan las máquinas del taller. Quienes usan las suyas pagan 0.
  """
  def calcular_alquiler(confeccionista, lotes_validos) do
    if confeccionista.alquiler == true do
      @alquiler_diario * dias_trabajados(lotes_validos, confeccionista.codigo)
    else
      0
    end
  end

  # ---------------------------------------------------------------
  # Liquidación
  # ---------------------------------------------------------------

  @doc """
  Liquida a todos los confeccionistas, incluso a quienes no tienen lotes
  válidos (todos sus valores quedan en cero). Devuelve una lista de mapas,
  uno por confeccionista, en el mismo orden de entrada.

  El mapa de prendas acumuladas por confeccionista y día se construye
  una sola vez y se reutiliza durante toda la liquidación.
  """
  def liquidar_todos(confeccionistas, lotes_validos) do
    prendas_por_dia = acumular_prendas_por_dia(lotes_validos)

    Enum.map(confeccionistas, fn confeccionista ->
      liquidar_confeccionista(confeccionista, lotes_validos, prendas_por_dia)
    end)
  end

  @doc """
  Liquida a un confeccionista y devuelve un mapa con:

    * `:codigo` y `:nombre`
    * `:prendas` - total de prendas en lotes válidos
    * `:bruto` - suma de los valores de los lotes, antes de bonificaciones
      y descuentos
    * `:bonificaciones` - suma de las bonificaciones diarias
    * `:descuento_alquiler` - descuento por alquiler de máquina
    * `:neto` - `bruto + bonificaciones - descuento_alquiler`
  """
  def liquidar_confeccionista(confeccionista, lotes_validos, prendas_por_dia) do
    lotes_propios =
      Enum.filter(lotes_validos, fn lote ->
        lote.confeccionista == confeccionista.codigo
      end)

    prendas =
      Enum.reduce(lotes_propios, 0, fn lote, acc ->
        acc + lote.prendas
      end)

    suma_lotes =
      Enum.reduce(lotes_propios, 0, fn lote, acc ->
        acc + valor_lote(lote)
      end)

    suma_bonificaciones =
      Enum.reduce(Validacion.dias(), 0, fn dia, acc ->
        acc + bonificacion_dia(prendas_por_dia, confeccionista.codigo, dia)
      end)

    descuento_alquiler =
      calcular_alquiler(confeccionista, lotes_validos)

    %{
      codigo: confeccionista.codigo,
      nombre: confeccionista.nombre,
      prendas: prendas,
      bruto: Util.redondear_dinero(suma_lotes),
      bonificaciones: suma_bonificaciones,
      descuento_alquiler: descuento_alquiler,
      neto:
        Util.redondear_dinero(
          suma_lotes + suma_bonificaciones - descuento_alquiler
        )
    }
  end
end

