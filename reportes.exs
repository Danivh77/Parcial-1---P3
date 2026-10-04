# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate



  defmodule Reportes do
  @moduledoc """
  Generación de los reportes de producción, productividad y liquidación del taller.

  Este módulo toma los datos validados y los resultados de la liquidación para
  imprimir en la consola los reportes R1 a R8 formateados adecuadamente.

  -versión 1.0
  -autoras: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate
  -fecha: 2026-10-04
  """



  # ---------------------------------------------------------------
  # Orquestación de reportes
  # ---------------------------------------------------------------


   @doc """
  Ejecuta de manera secuencial la generación de los reportes R1 a R8.
  """
  def generar_todos(confeccionistas, lineas, rechazados, lotes_validos, liquidaciones) do
    reporte_r1(rechazados)
    reporte_r2(lineas, lotes_validos)
    reporte_r3(lotes_validos)
    reporte_r4(liquidaciones)
    reporte_r5(confeccionistas, lotes_validos)
    reporte_r6(confeccionistas, lotes_validos)
    reporte_r7(liquidaciones, lotes_validos)
    reporte_r8(confeccionistas, lineas, lotes_validos)
  end

  # ---------------------------------------------------------------
  # R1: Lotes rechazados y motivos
  # ---------------------------------------------------------------

  @doc """
  Imprime la lista de lotes rechazados especificando el motivo de rechazo
  y el resumen con el conteo de frecuencias por cada tipo de error.
  """
  def reporte_r1(rechazados) do
    Util.mostrar_mensaje("\n=== R1: LOTES RECHAZADOS Y MOTIVOS ===")

    if rechazados == [] do
      Util.mostrar_mensaje("No hay lotes rechazados.")
    else
      Enum.each(rechazados, fn {lote, motivo} ->
        Util.mostrar_mensaje("Motivo: #{motivo} | Lote: #{inspect(lote)}")
      end)

      rechazados
      |> Enum.map(fn {_lote, motivo} -> motivo end)
      |> Enum.frequencies()
      |> Enum.each(fn {motivo, cantidad} ->
        Util.mostrar_mensaje("#{motivo}: #{cantidad} lote(s)")
      end)
    end
  end

  # ---------------------------------------------------------------
  # R2: Productividad por línea de producción
  # ---------------------------------------------------------------

  @doc """
  Calcula el total de prendas producidas por cada línea y su nivel de
  productividad (prendas/puesto). Muestra el listado ordenado de mayor a menor.
  """
  def reporte_r2(lineas, lotes_validos) do
    Util.mostrar_mensaje("\n=== R2: PRODUCTIVIDAD POR LÍNEA ===")

    lineas
    |> Enum.map(fn l ->
      prendas = Enum.reduce(lotes_validos, 0, fn lot, acc -> if lot.linea == l.id, do: acc + lot.prendas, else: acc end)
      prod = if l.puestos > 0, do: prendas / l.puestos, else: 0.0
      %{id: l.id, nom: l.nombre, prendas: prendas, puestos: l.puestos, prod: prod}
    end)
    |> Enum.sort_by(& &1.prod, :desc)
    |> Enum.each(fn item ->
      prod_fmt = :erlang.float_to_binary(item.prod * 1.0, decimals: 2)
      Util.mostrar_mensaje("Línea #{item.nom} (#{item.id}): #{item.prendas} prendas | Puestos: #{item.puestos} | Prod: #{prod_fmt} prendas/puesto")
    end)
  end

  # ---------------------------------------------------------------
  # R3: Producción diaria y cumplimiento de metas
  # ---------------------------------------------------------------

  @doc """
  Evalúa la producción global del taller para los días 1 al 6 frente a la meta
  mínima de 600 prendas diarias. Indica si se alcanzó la meta todos los días o al menos uno.
  """
  def reporte_r3(lotes_validos) do
    Util.mostrar_mensaje("\n=== R3: PRODUCCIÓN DIARIA Y METAS ===")

    dias = Enum.map(1..6, fn d ->
      p = Enum.reduce(lotes_validos, 0, fn l, acc -> if l.dia == d, do: acc + l.prendas, else: acc end)
      %{dia: d, prendas: p, meta: p >= 600}
    end)

    Enum.each(dias, fn i ->
      Util.mostrar_mensaje("Día #{i.dia}: #{i.prendas} prendas | Meta (600): #{if i.meta, do: "SÍ", else: "NO"}")
    end)

    Util.mostrar_mensaje("¿Meta alcanzada TODOS los días?: #{if Enum.all?(dias, & &1.meta), do: "SÍ", else: "NO"}")
    Util.mostrar_mensaje("¿Meta alcanzada AL MENOS UN día?: #{if Enum.any?(dias, & &1.meta), do: "SÍ", else: "NO"}")
  end

  # ---------------------------------------------------------------
  # R4: Liquidación ordenada de confeccionistas
  # ---------------------------------------------------------------

  @doc """
  Muestra la liquidación individual de cada confeccionista detallando prendas,
  monto bruto, bonificaciones, descuento de alquiler y valor neto a pagar,
  ordenados de mayor a menor según el neto.
  """
  def reporte_r4(liquidaciones) do
    Util.mostrar_mensaje("\n=== R4: LIQUIDACIÓN DE CONFECCIONISTAS ===")

    liquidaciones
    |> Enum.sort_by(& &1.neto, :desc)
    |> Enum.with_index(1)
    |> Enum.each(fn {l, i} ->
      Util.mostrar_mensaje(
        "#{i}. #{l.nombre} (#{l.codigo}) | Prendas: #{l.prendas} | " <>
        "Bruto: #{Util.formatear_dinero(l.bruto)} | Bono: #{Util.formatear_dinero(l.bonificaciones)} | " <>
        "Alq: #{Util.formatear_dinero(l.descuento_alquiler)} | NETO: #{Util.formatear_dinero(l.neto)}"
      )
    end)
  end

  # ---------------------------------------------------------------
  # R5: Máximos productores diarios y líder semanal
  # ---------------------------------------------------------------

  @doc """
  Determina el confeccionista o confeccionistas con mayor número de prendas producidas
  en cada jornada diaria (admitiendo empates) e identifica al líder semanal.
  """
  def reporte_r5(confeccionistas, lotes_validos) do
    Util.mostrar_mensaje("\n=== R5: MÁXIMOS PRODUCTORES DIARIOS ===")

    ganadores = Enum.flat_map(1..6, fn d ->
      lotes = Enum.filter(lotes_validos, &(&1.dia == d))
      prods = Enum.map(confeccionistas, fn c ->
        p = Enum.reduce(lotes, 0, fn l, a -> if l.confeccionista == c.codigo, do: a + l.prendas, else: a end)
        %{codigo: c.codigo, nombre: c.nombre, prendas: p}
      end)

      max_prendas = Enum.map(prods, & &1.prendas) |> Enum.max(fn -> 0 end)

      if max_prendas > 0 do
        gans = Util.maximos_por(prods, & &1.prendas)
        nombres = Enum.map_join(gans, ", ", &"#{&1.nombre} (#{&1.prendas})")
        Util.mostrar_mensaje("Día #{d}: #{nombres}")
        Enum.map(gans, & &1.codigo)
      else
        Util.mostrar_mensaje("Día #{d}: Sin lotes válidos")
        []
      end
    end)

    frec = Enum.frequencies(ganadores)
    if frec != %{} do
      max_dias = Enum.map(frec, &elem(&1, 1)) |> Enum.max()
      lideres = Enum.filter(frec, &(elem(&1, 1) == max_dias)) |> Enum.map(&elem(&1, 0))

      nombres_lideres = Enum.map_join(lideres, ", ", fn cod ->
        c = Enum.find(confeccionistas, &(&1.codigo == cod))
        "#{c.nombre} (#{cod})"
      end)
      Util.mostrar_mensaje("Líder(es) semanal (#{max_dias} día/s): #{nombres_lideres}")
    end
  end

  # ---------------------------------------------------------------
  # R6: Mejor calidad (porcentaje ponderado de defectos)
  # ---------------------------------------------------------------

  @doc """
  Identifica al confeccionista con menor porcentaje ponderado de defectos.
  Aplica el filtro de exigir como mínimo 3 lotes válidos registrados.
  """
  def reporte_r6(confeccionistas, lotes_validos) do
    Util.mostrar_mensaje("\n=== R6: MEJOR CALIDAD ===")

    candidatos = Enum.flat_map(confeccionistas, fn c ->
      lotes = Enum.filter(lotes_validos, &(&1.confeccionista == c.codigo))
      if length(lotes) >= 3 do
        p = Enum.reduce(lotes, 0, &(&1.prendas + &2))
        d = Enum.reduce(lotes, 0.0, &(&1.defectos * &1.prendas + &2))
        [%{cod: c.codigo, nom: c.nombre, pond: if(p > 0, do: d / p, else: 0.0)}]
      else
        []
      end
    end)

    case candidatos do
      [] -> Util.mostrar_mensaje("Ningún confeccionista tiene mínimo 3 lotes válidos.")
      _ ->
        m = Enum.min_by(candidatos, & &1.pond)
        fmt = :erlang.float_to_binary(m.pond * 1.0, decimals: 2)
        Util.mostrar_mensaje("Mejor calidad: #{m.nom} (#{m.cod}) con #{fmt}% de defectos ponderado")
    end
  end

  # ---------------------------------------------------------------
  # R7: Totales financieros y costo promedio por prenda
  # ---------------------------------------------------------------

  @doc """
  Calcula el monto global desembolsado por el taller en la liquidación y el costo
  promedio por prenda válida confeccionada.
  """
  def reporte_r7(liquidaciones, lotes_validos) do
    Util.mostrar_mensaje("\n=== R7: TOTALES Y COSTO PROMEDIO ===")
    tot = Enum.reduce(liquidaciones, 0.0, &(&1.neto + &2))
    prendas = Enum.reduce(lotes_validos, 0, &(&1.prendas + &2))

    Util.mostrar_mensaje("Total pagado por el taller: #{Util.formatear_dinero(tot)}")
    if prendas > 0 do
      Util.mostrar_mensaje("Costo promedio por prenda válida: #{Util.formatear_dinero(tot / prendas)}")
    else
      Util.mostrar_mensaje("No se puede calcular el promedio porque no hay prendas válidas.")
    end
  end

  # ---------------------------------------------------------------
  # R8: Cobertura total de líneas de producción
  # ---------------------------------------------------------------

  @doc """
  Verifica e imprime la lista de confeccionistas que registraron al menos un lote
  válido en cada una de las líneas de producción del taller.
  """
  def reporte_r8(confeccionistas, lineas, lotes_validos) do
    Util.mostrar_mensaje("\n=== R8: COBERTURA TOTAL DE LÍNEAS ===")
    todas = Enum.map(lineas, & &1.id) |> Enum.sort()

    cumplen = Enum.filter(confeccionistas, fn c ->
      lotes_validos
      |> Enum.filter(&(&1.confeccionista == c.codigo))
      |> Enum.map(& &1.linea)
      |> Enum.uniq()
      |> Enum.sort() == todas
    end)

    if cumplen == [] do
      Util.mostrar_mensaje("Ningún confeccionista trabajó en todas las líneas.")
    else
      Enum.each(cumplen, &Util.mostrar_mensaje("- #{&1.nombre} (#{&1.codigo})"))
    end
  end



end
