# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate



defmodule Reportes do
  @moduledoc """
  Módulo encargado de generar los reportes de producción, calidad y rendimiento,
  así como las funciones de investigación (C.1, C.2) y el comprobante individual.

  Sigue una arquitectura donde los cálculos son funciones puras (calcular_rN)
  y la salida a consola se maneja en funciones separadas (reporte_rN).

  -versión 1.0
  -autoras: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate
  -fecha: 2026-10-04
  """


  @meta_diaria 600
  @taller_aliado %{1 => 550, 2 => 620, 3 => 480, 5 => 710, 7 => 200}

  # ===============================================================
  # R1: LOTES RECHAZADOS
  # ===============================================================

  @doc "Calcula las frecuencias de rechazo por motivo (Función pura)."
  def calcular_r1(rechazados) do
    rechazados
    |> Enum.map(fn {_lote, motivo} -> motivo end)
    |> Enum.frequencies()
  end

  @doc "Muestra en consola el reporte R1."
  def reporte_r1(rechazados) do
    Util.mostrar_mensaje("\n=== R1: LOTES RECHAZADOS Y MOTIVOS ===")

    if rechazados == [] do
      Util.mostrar_mensaje("No hay lotes rechazados.")
    else
      Enum.each(rechazados, fn {lote, motivo} ->
        Util.mostrar_mensaje("Lote rechazado: #{inspect(lote)} | Motivo: #{motivo}")
      end)

      Util.mostrar_mensaje("\nResumen de rechazos por motivo:")

      rechazados
      |> calcular_r1()
      |> Enum.each(fn {motivo, cantidad} ->
        Util.mostrar_mensaje("- #{motivo}: #{cantidad}")
      end)
    end
  end

  # ===============================================================
  # R2: PRODUCTIVIDAD POR LÍNEA DE PRODUCCIÓN
  # ===============================================================

  @doc "Calcula las prendas y productividad por puesto para cada línea (Función pura)."
  def calcular_r2(lotes_validos, lineas) do
    prendas_por_linea =
      Enum.reduce(lotes_validos, %{}, fn lote, acc ->
        Map.update(acc, lote.linea, lote.prendas, &(&1 + lote.prendas))
      end)

    lineas
    |> Enum.map(fn linea ->
      total_prendas = Map.get(prendas_por_linea, linea.id, 0)
      productividad = total_prendas / linea.puestos

      %{
        id: linea.id,
        nombre: linea.nombre,
        prendas: total_prendas,
        puestos: linea.puestos,
        productividad: productividad
      }
    end)
    |> Enum.sort_by(& &1.productividad, :desc)
  end

  @doc "Muestra en consola el reporte R2."
  def reporte_r2(lotes_validos, lineas) do
    Util.mostrar_mensaje("\n=== R2: PRODUCTIVIDAD POR LÍNEA DE PRODUCCIÓN ===")

    calcular_r2(lotes_validos, lineas)
    |> Enum.each(fn item ->
      fmt_prod = :erlang.float_to_binary(item.productividad * 1.0, decimals: 2)
      # Corrección: item.nombre ya incluye "Línea", se elimina la duplicación
      Util.mostrar_mensaje("#{item.nombre} (#{item.id}): #{item.prendas} prendas | Productividad: #{fmt_prod} prendas/puesto")
    end)
  end

  # ===============================================================
  # R3: PRODUCCIÓN DIARIA Y METAS
  # ===============================================================

  @doc "Obtiene la producción acumulada por día (Función pura)."
  def produccion_por_dia(lotes_validos) do
    base = Map.new(Validacion.dias(), fn dia -> {dia, 0} end)

    Enum.reduce(lotes_validos, base, fn lote, acc ->
      Map.update(acc, lote.dia, lote.prendas, fn total -> total + lote.prendas end)
    end)
  end

  @doc "Calcula el estado del cumplimiento de la meta por día (Función pura)."
  def calcular_r3(lotes_validos) do
    por_dia = produccion_por_dia(lotes_validos)

    filas =
      for {dia, prendas} <- Enum.sort(por_dia) do
        %{dia: dia, prendas: prendas, meta: prendas >= @meta_diaria}
      end

    %{
      por_dia: por_dia,
      filas: filas,
      todos: Enum.all?(filas, fn fila -> fila.meta end),
      alguno: Enum.any?(filas, fn fila -> fila.meta end)
    }
  end

  @doc "Muestra en consola el reporte R3."
  def reporte_r3(lotes_validos) do
    Util.mostrar_mensaje("\n=== R3: PRODUCCIÓN DIARIA Y METAS ===")
    resultado = calcular_r3(lotes_validos)

    Enum.each(resultado.filas, fn fila ->
      Util.mostrar_mensaje("Día #{fila.dia}: #{fila.prendas} prendas | Meta (#{@meta_diaria}): #{si_no(fila.meta)}")
    end)

    Util.mostrar_mensaje("¿Meta alcanzada TODOS los días?: #{si_no(resultado.todos)}")
    Util.mostrar_mensaje("¿Meta alcanzada AL MENOS UN día?: #{si_no(resultado.alguno)}")
  end

  # ===============================================================
  # R4: LIQUIDACIÓN ORDENADA
  # ===============================================================

  @doc "Ordena las liquidaciones de mayor a menor según el pago neto (Función pura)."
  def calcular_r4(liquidaciones) do
    Enum.sort_by(liquidaciones, & &1.neto, :desc)
  end

  @doc "Muestra en consola la liquidación general (R4)."
  def reporte_r4(liquidaciones) do
    Util.mostrar_mensaje("\n=== R4: LIQUIDACIÓN DE CONFECCIONISTAS ===")

    liquidaciones
    |> calcular_r4()
    |> Enum.with_index(1)
    |> Enum.each(fn {liq, i} ->
      Util.mostrar_mensaje(
        "#{i}. #{liq.nombre} (#{liq.codigo}): #{liq.prendas} prendas | Lotes: $#{fmt(liq.bruto)} | " <>
        "Bonificación: $#{fmt(liq.bonificaciones)} | Alquiler: $#{fmt(liq.alquiler)} | Neto: $#{fmt(liq.neto)}"
      )
    end)
  end

  # ===============================================================
  # R5: MÁXIMO PRODUCTOR POR DÍA Y LÍDER SEMANAL
  # ===============================================================

  @doc "Calcula los confeccionistas con mayor producción cada día y el/los líder(es) de la semana (Función pura)."
  def calcular_r5(lotes_validos, confeccionistas) do
    nombres = Map.new(confeccionistas, fn c -> {c.codigo, c.nombre} end)

    diarios =
      for dia <- Validacion.dias() do
        lotes_dia = Enum.filter(lotes_validos, &(&1.dia == dia))

        if lotes_dia == [] do
          {dia, :sin_lotes}
        else
          por_conf =
            Enum.reduce(lotes_dia, %{}, fn l, acc ->
              Map.update(acc, l.confeccionista, l.prendas, &(&1 + l.prendas))
            end)

          max_prendas = por_conf |> Map.values() |> Enum.max()

          ganadores =
            por_conf
            |> Enum.filter(fn {_cod, prendas} -> prendas == max_prendas end)
            |> Enum.map(fn {cod, _prendas} -> %{codigo: cod, nombre: Map.get(nombres, cod, cod), prendas: max_prendas} end)

          {dia, ganadores}
        end
      end

    conteo_lideres =
      diarios
      |> Enum.flat_map(fn
        {_dia, :sin_lotes} -> []
        {_dia, ganadores} -> Enum.map(ganadores, & &1.codigo)
      end)
      |> Enum.frequencies()

    {diarios, conteo_lideres, nombres}
  end

  @doc "Muestra en consola el reporte R5."
  def reporte_r5(lotes_validos, confeccionistas) do
    Util.mostrar_mensaje("\n=== R5: MAYOR PRODUCTOR POR DÍA ===")
    {diarios, conteo_lideres, nombres} = calcular_r5(lotes_validos, confeccionistas)

    Enum.each(diarios, fn
      {dia, :sin_lotes} ->
        Util.mostrar_mensaje("Día #{dia}: Sin lotes válidos")

      {dia, ganadores} ->
        lista_fmt = Enum.map_join(ganadores, ", ", fn g -> "#{g.nombre} (#{g.codigo}) [#{g.prendas} prendas]" end)
        Util.mostrar_mensaje("Día #{dia}: #{lista_fmt}")
    end)

    if conteo_lideres != %{} do
      max_dias = conteo_lideres |> Map.values() |> Enum.max()

      empatados =
        conteo_lideres
        |> Enum.filter(fn {_cod, dias} -> dias == max_dias end)
        |> Enum.map(fn {cod, _dias} -> "#{Map.get(nombres, cod, cod)} (#{cod})" end)

      Util.mostrar_mensaje("Primer lugar más días (#{max_dias} día(s)): #{Enum.join(empatados, ", ")}")
    else
      # Corrección: Mensaje formal cuando ningún día tiene lotes válidos
      Util.mostrar_mensaje("No hay líder semanal: ningún día tiene lotes válidos.")
    end
  end

  # ===============================================================
  # R6: MEJOR CALIDAD (MENOR % DEFECTOS PONDERADO)
  # ===============================================================

  @doc "Calcula el confeccionista con mejor calidad entre los que tienen >= 3 lotes válidos (Función pura)."
  def calcular_r6(lotes_validos, confeccionistas) do
    nombres = Map.new(confeccionistas, fn c -> {c.codigo, c.nombre} end)

    lotes_por_conf = Enum.group_by(lotes_validos, & &1.confeccionista)

    candidatos =
      lotes_por_conf
      |> Enum.filter(fn {_cod, lotes} -> length(lotes) >= 3 end)
      |> Enum.map(fn {cod, lotes} ->
        suma_prendas = Enum.sum(Enum.map(lotes, & &1.prendas))
        suma_ponderada = Enum.sum(Enum.map(lotes, &(&1.defectos * &1.prendas)))
        pond = if suma_prendas > 0, do: suma_ponderada / suma_prendas, else: 0.0

        %{cod: cod, nom: Map.get(nombres, cod, cod), pond: pond}
      end)

    if candidatos == [] do
      :ninguno
    else
      menor = candidatos |> Enum.map(& &1.pond) |> Enum.min()
      Enum.filter(candidatos, fn c -> c.pond == menor end)
    end
  end

  @doc "Muestra en consola el reporte R6."
  def reporte_r6(lotes_validos, confeccionistas) do
    Util.mostrar_mensaje("\n=== R6: MEJOR CALIDAD ===")

    case calcular_r6(lotes_validos, confeccionistas) do
      :ninguno ->
        Util.mostrar_mensaje("Ningún confeccionista cumple el mínimo de 3 lotes válidos para el reporte de calidad.")

      ganadores ->
        # Corrección: Muestra a todos los empatados en mejor calidad
        Enum.each(ganadores, fn m ->
          fmt_val = :erlang.float_to_binary(m.pond * 1.0, decimals: 2)
          Util.mostrar_mensaje("Mejor calidad: #{m.nom} (#{m.cod}) con #{fmt_val}% de defectos ponderado")
        end)
    end
  end

  # ===============================================================
  # R7: COSTO TOTAL Y COSTO PROMEDIO POR PRENDA
  # ===============================================================

  @doc "Calcula el total a pagar y el costo promedio por prenda válida (Función pura)."
  def calcular_r7(liquidaciones, lotes_validos) do
    total_pagar = Enum.sum(Enum.map(liquidaciones, & &1.neto))
    total_prendas = Enum.sum(Enum.map(lotes_validos, & &1.prendas))

    promedio = if total_prendas > 0, do: total_pagar / total_prendas, else: :no_calculable

    %{total_pagar: total_pagar, total_prendas: total_prendas, promedio: promedio}
  end

  @doc "Muestra en consola el reporte R7."
  def reporte_r7(liquidaciones, lotes_validos) do
    Util.mostrar_mensaje("\n=== R7: TOTAL Y COSTO PROMEDIO POR PRENDA ===")
    res = calcular_r7(liquidaciones, lotes_validos)

    Util.mostrar_mensaje("Total a pagar por el taller: $#{fmt(res.total_pagar)}")

    case res.promedio do
      :no_calculable ->
        Util.mostrar_mensaje("Costo promedio por prenda: No se puede calcular (0 prendas válidas).")

      valor ->
        Util.mostrar_mensaje("Costo promedio por prenda válida: $#{fmt(valor)}")
    end
  end

  # ===============================================================
  # R8: COBERTURA TOTAL DE LÍNEAS
  # ===============================================================

  @doc "Identifica confeccionistas con al menos un lote válido en todas las líneas (Función pura)."
  def calcular_r8(lotes_validos, confeccionistas, lineas) do
    ids_lineas = MapSet.new(Enum.map(lineas, & &1.id))
    nombres = Map.new(confeccionistas, fn c -> {c.codigo, c.nombre} end)

    candidatos =
      lotes_validos
      |> Enum.group_by(& &1.confeccionista)
      |> Enum.filter(fn {_cod, lotes} ->
        lineas_trabajadas = MapSet.new(Enum.map(lotes, & &1.linea))
        MapSet.subset?(ids_lineas, lineas_trabajadas)
      end)
      |> Enum.map(fn {cod, _} -> "#{Map.get(nombres, cod, cod)} (#{cod})" end)

    candidatos
  end

  @doc "Muestra en consola el reporte R8."
  def reporte_r8(lotes_validos, confeccionistas, lineas) do
    Util.mostrar_mensaje("\n=== R8: COBERTURA TOTAL DE LÍNEAS ===")
    cumplen = calcular_r8(lotes_validos, confeccionistas, lineas)

    if cumplen == [] do
      Util.mostrar_mensaje("Ningún confeccionista registró lotes válidos en todas las líneas de producción.")
    else
      Util.mostrar_mensaje("Confeccionistas con lotes en todas las líneas: #{Enum.join(cumplen, ", ")}")
    end
  end

  # ===============================================================
  # B.5: COMPROBANTE INDIVIDUAL
  # ===============================================================

  @doc "Calcula los datos detallados del comprobante de pago individual (Función pura)."
  def calcular_comprobante(codigo, lotes_validos, liquidaciones) do
    case Enum.find(liquidaciones, fn liquidacion -> liquidacion.codigo == codigo end) do
      nil ->
        {:error, :confeccionista_desconocido}

      liquidacion ->
        prendas_por_dia = Liquidacion.acumular_prendas_por_dia(lotes_validos)

        detalle =
          Validacion.dias()
          |> Enum.map(fn dia ->
            %{
              dia: dia,
              prendas: Liquidacion.prendas_confeccionista_dia(prendas_por_dia, codigo, dia),
              valor: Liquidacion.valor_lotes_dia(lotes_validos, codigo, dia),
              bonificacion: Liquidacion.bonificacion_dia(prendas_por_dia, codigo, dia)
            }
          end)
          |> Enum.filter(fn fila -> fila.prendas > 0 end)

        {:ok, %{liquidacion: liquidacion, detalle: detalle}}
    end
  end

  @doc "Muestra en consola el comprobante individual de un confeccionista."
  def mostrar_comprobante(codigo, lotes_validos, liquidaciones) do
    case calcular_comprobante(codigo, lotes_validos, liquidaciones) do
      {:error, :confeccionista_desconocido} ->
        Util.mostrar_mensaje("Error: El confeccionista con código '#{codigo}' no existe.")

      {:ok, %{liquidacion: liq, detalle: detalle}} ->
        Util.mostrar_mensaje("\n=======================================================")
        Util.mostrar_mensaje("         COMPROBANTE INDIVIDUAL DE PAGO                ")
        Util.mostrar_mensaje("=======================================================")
        Util.mostrar_mensaje("Confeccionista: #{liq.nombre} (#{liq.codigo})")
        Util.mostrar_mensaje("-------------------------------------------------------")
        Util.mostrar_mensaje("Día | Prendas | Valor Lotes   | Bonificación")
        Util.mostrar_mensaje("-------------------------------------------------------")

        Enum.each(detalle, fn d ->
          Util.mostrar_mensaje(
            " #{d.dia}  |   #{String.pad_leading(to_string(d.prendas), 5)} | $" <>
            "#{String.pad_leading(fmt(d.valor), 12)} | $#{fmt(d.bonificacion)}"
          )
        end)

        Util.mostrar_mensaje("-------------------------------------------------------")
        Util.mostrar_mensaje("Suma de Lotes:          $#{fmt(liq.bruto)}")
        Util.mostrar_mensaje("Suma de Bonificaciones:  $#{fmt(liq.bonificaciones)}")
        Util.mostrar_mensaje("Descuento Alquiler:     -$#{fmt(liq.alquiler)}")
        Util.mostrar_mensaje("PAGO NETO TOTAL:        $#{fmt(liq.neto)}")
        Util.mostrar_mensaje("=======================================================\n")
    end
  end

  # ===============================================================
  # C.1: INVESTIGACIÓN - KEYWORD LISTS (RANKING)
  # ===============================================================

  @doc """
  Genera un ranking de confeccionistas basado en una keyword list con opciones.
  Opciones: :campo (:neto, :prendas, :bruto), :orden (:desc, :asc), :limite (entero positivo).
  """
  def ranking(liquidaciones, opciones \\ []) do
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(liquidaciones))

    liquidaciones
    |> Enum.sort_by(fn item -> Map.get(item, campo, 0) end, orden)
    |> Enum.take(limite)
  end

  # ===============================================================
  # C.2: INVESTIGACIÓN - MAP.MERGE/3
  # ===============================================================

  @doc "Combina la producción de dos talleres sumando las prendas de los días comunes."
  def combinar_produccion(taller_local, taller_aliado) do
    Map.merge(taller_local, taller_aliado, fn _dia, prendas_local, prendas_aliado ->
      prendas_local + prendas_aliado
    end)
  end

  @doc "Muestra la demostración de la combinación con el taller aliado (C.2)."
  def mostrar_demostracion_c2(lotes_validos) do
    taller_local = produccion_por_dia(lotes_validos)
    combinado = combinar_produccion(taller_local, @taller_aliado)

    Util.mostrar_mensaje("\n=== C.2: COMBINACIÓN DE PRODUCCIÓN CON TALLER ALIADO ===")
    Util.mostrar_mensaje("Producción Taller Local:  #{inspect(taller_local)}")
    Util.mostrar_mensaje("Producción Taller Aliado: #{inspect(@taller_aliado)}")
    Util.mostrar_mensaje("Producción Combinada:     #{inspect(combinado)}")
  end

  # ===============================================================
  # FUNCIONES AUXILIARES PRIVADAS
  # ===============================================================

  defp si_no(true), do: "SÍ"
  defp si_no(false), do: "NO"

  defp fmt(numero) when is_number(numero) do
    :erlang.float_to_binary(numero * 1.0, decimals: 2)
  end
end
