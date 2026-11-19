// =====================================================================
// POUPON Antoine
// Inge de datos : Laboratorio Final
// Base de datos: liwi_flor_eterna (mongosh)
// =====================================================================


// =====================================================================
// PARTE 0
// =====================================================================

// ---------------------------------------------------------------------
// 0.1 Descripción del proyecto
// ---------------------------------------------------------------------
// Liwi Flor Eterna vende flores de Inírida y productos amazónicos; el proyecto registra
// sus ventas, gastos y cierres financieros para saber cuánto gana el negocio cada mes.
// Los datos los usan los socios y administradores para controlar ingresos, gastos e inventario.

// ---------------------------------------------------------------------
// 0.2
// ---------------------------------------------------------------------
// Codigo :
show collections
db.getCollectionNames().forEach(c => print(c + ": " + db.getCollection(c).countDocuments()))

// Respuesta :
// auditoria_gastos: 12
// ciudades: 3
// auditoria_ventas: 12
// proveedores: 1
// productos: 27
// cierres_financieros: 2
// categorias_gasto: 3
// ventas: 96
// usuarios: 6
// gastos: 110
// metodos_pago: 4
// categorias: 8
// clientes: 7

// ---------------------------------------------------------------------
// 0.3 Patrones de acceso más importantes
// ---------------------------------------------------------------------
// 1. Registrar una venta con sus líneas de producto | Escritura | Alta
// 2. Ver las ventas de un rango de fechas, de la más reciente a la más antigua | Lectura | Alta
// 3. Calcular ingresos y gastos por mes para el cierre financiero | Lectura analítica | Baja


// =====================================================================
// PARTE A
// =====================================================================

// ---------------------------------------------------------------------
// A1)
// ---------------------------------------------------------------------
// Sirve porque una venta se guarda completa en un solo documento, con sus líneas de producto
// dentro (de 1 a 4 líneas), y se lee y se escribe junta. Además los datos cambian de forma
// (gastos con o sin etiquetas, ventas con valores pendientes), y un documento lo permite sin problema.
// Estaría mejor en un modelo relacional: los cierres financieros, porque suman ventas y gastos
// de un periodo y necesitan cuentas exactas y consistentes entre tablas (patrón 3: cálculo mensual).

// ---------------------------------------------------------------------
// A2)
// ---------------------------------------------------------------------
// Codigo :
db.getCollectionNames().forEach(c => { print("== " + c); printjson(db.getCollection(c).findOne()) })

// Respuesta :
// Relaciones y decisiones
// ventas -> lineas: de 1 a 4 líneas por venta. EMBEBIDO. Se leen y se escriben siempre con la venta
//   (patrones 1 y 2) y 4 líneas pesan unos cientos de bytes, muy lejos de los 16 MB.
// ventas -> clientes: de 1 cliente a muchas ventas (el cliente 1 ya tiene 87). REFERENCIADO (idCliente),
//   porque crece sin límite y no conviene meterlo dentro del cliente por el límite de 16 MB.
// ventas -> ciudades y metodos_pago: de 1 a muchas, catálogos de 3 y 4 documentos. REFERENCIADO (idCiudad, idMetodoPago).
// lineas -> productos: de 1 producto a muchas líneas. REFERENCIADO (idProducto) y COPIADO el sku,
//   para ver el producto en la venta sin otra consulta (patrón 2).
// productos -> categorias: de 1 categoría a pocos productos (8 categorías). REFERENCIADO (idCategoria).
// gastos -> etiquetas: de 0 a 2 etiquetas por gasto. EMBEBIDO como arreglo, siempre se leen con el gasto.
// gastos -> categorias_gasto y proveedores: de 1 a muchos. REFERENCIADO (idCategoriaGasto, idProveedor).
// auditorias -> ventas y gastos: valorAnterior y valorNuevo se COPIAN como texto, porque la venta
//   auditada puede haberse borrado.
// cierres_financieros -> usuarios: de 1 usuario a pocos cierres. REFERENCIADO (idUsuario);
//   los totales se COPIAN (ya calculados) porque el cierre es una foto fija del periodo (patrón 3).

// ---------------------------------------------------------------------
// A3)
// ---------------------------------------------------------------------
// Codigo :
printjson({
  fechaDate: db.ventas.countDocuments({ fecha: { $type: "date" } }),
  valorNumerico: db.ventas.countDocuments({ valorTotal: { $type: "number" } }),
  conOtroTipo: db.ventas.countDocuments({
    $or: [
      { fecha: { $not: { $type: "date" } } },
      { valorTotal: { $not: { $type: "number" } } }
    ]
  })
})

// Respuesta :
// { fechaDate: 96, valorNumerico: 96, conOtroTipo: 0 }

// ---------------------------------------------------------------------
// A4)
// ---------------------------------------------------------------------
// Codigo :
var reglaVentas = {
  bsonType: "object",
  required: ["fecha", "idCliente", "idCiudad", "idMetodoPago", "valorTotal", "lineas"],
  properties: {
    fecha: { bsonType: "date" },
    valorTotal: { bsonType: ["double", "int"], minimum: 0 },
    lineas: {
      bsonType: "array",
      minItems: 1,
      items: {
        bsonType: "object",
        required: ["idProducto", "cantidad", "origenValor"],
        properties: {
          cantidad: { bsonType: ["int", "double"], minimum: 1 },
          origenValor: { enum: ["Exacto", "Pendiente"] }
        }
      }
    }
  }
}

db.ventas.countDocuments({ $nor: [ { $jsonSchema: reglaVentas } ] })

db.runCommand({ collMod: "ventas", validator: { $jsonSchema: reglaVentas } })

// Respuesta :
// countDocuments($nor) -> 0
// collMod -> { ok: 1 }
// La búsqueda con $nor devolvió 0 documentos, así que no hubo que corregir nada antes de activar la regla.
// La regla pide 6 campos obligatorios, valorTotal entre 0 y más, origenValor solo "Exacto" o "Pendiente",
// y lineas como arreglo de objetos con cantidad mínima 1.

// ---------------------------------------------------------------------
// A5)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.insertOne({ _id: 9001, fecha: new Date(), idCliente: 1, idCiudad: 1, idMetodoPago: 1, valorTotal: -500, lineas: [ { idProducto: 1, cantidad: 1, origenValor: "Exacto" } ] })

db.ventas.insertOne({ _id: 9002, fecha: new Date(), idCliente: 1, idCiudad: 1, idMetodoPago: 1, valorTotal: 45000, nota: "Venta de prueba", lineas: [ { idProducto: 1, cantidad: 1, origenValor: "Exacto" } ] })

db.ventas.deleteOne({ _id: 9002 })   // sino voy a tener problemas despues

// Respuesta :
// 1er insert -> MongoServerError: Document failed validation
// 2do insert -> { acknowledged: true, insertedId: 9002 }
// El primer documento se rechazó porque valorTotal = -500 incumple la regla minimum: 0.
// El segundo se aceptó aunque tiene el campo "nota", porque la regla no prohíbe campos extra:
// solo exige los obligatorios y valida los que menciona. Esto muestra que el esquema es flexible:
// MongoDB controla solo lo que le pedimos y deja libre el resto.


// =====================================================================
// PARTE B
// =====================================================================

// ---------------------------------------------------------------------
// B1)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.insertMany([
  { _id: 9101, fecha: new Date(), idCliente: 1, idCiudad: 1, idMetodoPago: 1, puntoVenta: "Local Bogotá", facturada: false, valorTotal: 30000, nota: "borrar", datoDePrueba: true, lineas: [ { idDetalle: 1001, idProducto: 11, sku: "JAL-PEQ", cantidad: 1, valorLinea: 30000, origenValor: "Exacto" } ] },
  { _id: 9102, fecha: new Date(), idCliente: 1, idCiudad: 1, idMetodoPago: 1, puntoVenta: "Local Bogotá", facturada: false, valorTotal: 45000, datoDePrueba: true, lineas: [ { idDetalle: 1002, idProducto: 15, sku: "KAT-UNI", cantidad: 1, valorLinea: 45000, origenValor: "Exacto" } ] },
  { _id: 9103, fecha: new Date(), idCliente: 1, idCiudad: 1, idMetodoPago: 1, puntoVenta: "Local Bogotá", facturada: false, valorTotal: 60000, datoDePrueba: true, lineas: [ { idDetalle: 1003, idProducto: 16, sku: "MAN-UNI", cantidad: 2, valorLinea: 60000, origenValor: "Exacto" } ] }
])

// Respuesta :
// {
//   acknowledged: true,
//   insertedIds: { '0': 9101, '1': 9102, '2': 9103 }
// }
// Se insertaron 3 ventas en una sola operación (ids 9101 a 9103). acknowledged: true significa que
// MongoDB confirmó la escritura, y insertedIds muestra los 3 _id creados. Cumplen la regla de A4.

// ---------------------------------------------------------------------
// B2)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.find(
  { valorTotal: { $gte: 200000 }, idMetodoPago: { $in: [2, 4] } },
  { fecha: 1, valorTotal: 1, idMetodoPago: 1 }
).sort({ valorTotal: -1 })

// ---------------------------------------------------------------------
// B3)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.updateMany(
  { datoDePrueba: { $exists: false } },
  [ { $set: { ubicacion: { idCiudad: "$idCiudad", puntoVenta: "$puntoVenta" } } } ]
)

db.ventas.countDocuments({ "ubicacion.idCiudad": 2 })
db.ventas.countDocuments({ lineas: { $elemMatch: { idProducto: 2, cantidad: { $gte: 4 } } } })
db.ventas.countDocuments({ "lineas.idProducto": 2, "lineas.cantidad": { $gte: 4 } })

// Respuesta :
// updateMany -> {
//   acknowledged: true,
//   insertedId: null,
//   matchedCount: 96,
//   modifiedCount: 96,
//   upsertedCount: 0
// }
//
// db.ventas.countDocuments({ "ubicacion.idCiudad": 2 })
// 31
//
// ¿Cuántas ventas llevan flor de Inírida de verano (producto 2) en cantidad de 4 o más? (con $elemMatch)
// db.ventas.countDocuments({ lineas: { $elemMatch: { idProducto: 2, cantidad: { $gte: 4 } } } })
// 5
//
// La misma pregunta, sin $elemMatch
// db.ventas.countDocuments({ "lineas.idProducto": 2, "lineas.cantidad": { $gte: 4 } })
// 6
//
// Con $elemMatch las dos condiciones deben cumplirse en la MISMA línea (5 ventas).
// Sin $elemMatch, una línea puede cumplir una condición y otra línea distinta la otra (6 ventas).
// Por eso aparece una venta de más (la 66): tiene el producto 2 en una línea y cantidad 4 o más en otra.

// ---------------------------------------------------------------------
// B4)
// ---------------------------------------------------------------------
// Codigo :
var mes = { fecha: { $gte: new Date("2026-08-16T00:00:00-05:00"), $lt: new Date("2026-09-16T00:00:00-05:00") } }
db.ventas.countDocuments(mes)
db.ventas.find(mes, { fecha: 1, valorTotal: 1 }).sort({ fecha: -1, _id: -1 }).limit(5)

// ---------------------------------------------------------------------
// B5)
// ---------------------------------------------------------------------
// Codigo :
db.productos.find({}, { nombre: 1, presentacion: 1 }).sort({ nombre: 1, _id: 1 }).skip(10).limit(10)

// ---------------------------------------------------------------------
// B6)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.updateOne({ _id: 9101, facturada: false }, { $set: { facturada: true } })
db.ventas.updateOne({ _id: 9101 }, { $inc: { valorTotal: 5000 } })
db.ventas.updateOne({ _id: 9101 }, { $addToSet: { lineas: { idDetalle: 1004, idProducto: 12, sku: "JAL-GRA", cantidad: 2, valorLinea: 12000, origenValor: "Exacto" } } })
db.ventas.updateOne({ _id: 9101 }, { $unset: { nota: "" } })

// Respuesta :
// matchedCount = documentos que cumplen el filtro; modifiedCount = documentos que realmente cambiaron.
// $set con estado anterior: 1/1 la primera vez y 0/0 la segunda, porque la venta ya no estaba "facturada: false".
// $inc: 1/1, el total subió de 30000 a 35000.
// $addToSet: 1/1, se agregó la línea; si se repite, daría 1/0 porque ya existe (no se duplica).
// $unset: 1/1, se eliminó el campo nota; si se repite, daría 1/0 porque el documento se encontró
// pero ya no había nada que cambiar.

// ---------------------------------------------------------------------
// B7)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.updateOne(
  { _id: 9200 },
  { $setOnInsert: { fecha: new Date(), idCliente: 1, idCiudad: 1, idMetodoPago: 1, valorTotal: 20000, datoDePrueba: true, lineas: [ { idDetalle: 2001, idProducto: 15, sku: "KAT-UNI", cantidad: 1, valorLinea: 20000, origenValor: "Exacto" } ] } },
  { upsert: true }
)
db.ventas.countDocuments({ datoDePrueba: true })
db.ventas.deleteMany({ datoDePrueba: true })
db.ventas.countDocuments()

// Respuesta :
// La primera vez el upsert creó el documento (upsertedCount: 1). La segunda vez lo encontró
// (matchedCount: 1) pero no cambió nada (modifiedCount: 0), porque $setOnInsert solo actúa al crear.
// Conté 4 ventas de prueba antes de borrar y deleteMany eliminó exactamente 4: contar con el mismo filtro
// evita borrar de más.


// =====================================================================
// PARTE C
// =====================================================================

// ---------------------------------------------------------------------
// C1)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.aggregate([
  { $match: { valorTotal: { $gt: 0 } } },
  { $group: { _id: "$idMetodoPago", ventas: { $sum: 1 }, total: { $sum: "$valorTotal" }, promedio: { $avg: "$valorTotal" }, maximo: { $max: "$valorTotal" } } },
  { $project: { _id: 0, metodoPago: "$_id", ventas: 1, total: 1, promedio: { $round: ["$promedio", 0] }, maximo: 1 } },
  { $sort: { total: -1 } }
])

// Respuesta :
// (el resultado está en la captura de pantalla del documento)

// ---------------------------------------------------------------------
// C2)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.aggregate([
  { $group: { _id: { $dateToString: { format: "%Y-%m", date: "$fecha", timezone: "America/Bogota" } }, eventos: { $sum: 1 }, promedio: { $avg: "$valorTotal" } } },
  { $sort: { _id: 1 } }
])

// Respuesta :
// {
//   _id: '2026-08',
//   eventos: 55,
//   promedio: 93744
// }
// {
//   _id: '2026-08',
//   eventos: 55,
//   promedio: 93744
// }

// ---------------------------------------------------------------------
// C3)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.aggregate([
  { $unwind: "$lineas" },
  { $group: { _id: "$lineas.sku", lineas: { $sum: 1 }, unidades: { $sum: "$lineas.cantidad" } } },
  { $sort: { lineas: -1, _id: 1 } },
  { $limit: 5 },
  { $project: { _id: 0, sku: "$_id", lineas: 1, unidades: 1 } }
])

// ---------------------------------------------------------------------
// C4)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.aggregate([
  { $lookup: { from: "ciudades", localField: "idCiudad", foreignField: "_id", as: "ciudad" } },
  { $unwind: "$ciudad" },
  { $project: { fecha: 1, valorTotal: 1, ciudad: "$ciudad.nombre" } },
  { $sort: { _id: 1 } },
  { $limit: 3 }
])

// Respuesta :
// {
//   _id: 1,
//   fecha: ISODate('2026-08-15T00:00:00.000Z'),
//   valorTotal: 28500,
//   ciudad: 'Bogotá'
// }
// {
//   _id: 2,
//   fecha: ISODate('2026-08-16T00:00:00.000Z'),
//   valorTotal: 95000,
//   ciudad: 'Inírida'
// }
// {
//   _id: 2,
//   fecha: ISODate('2026-08-16T00:00:00.000Z'),
//   valorTotal: 95000,
//   ciudad: 'Inírida'
// }
//
// Sí es frecuente: la pantalla de ventas (patrón 2) necesita mostrar el nombre de la ciudad.
// Conviene copiar el nombre en la venta (referencia extendida): el catálogo tiene solo 3 ciudades
// y casi nunca cambia, así se evita el $lookup en cada lectura. El costo es tener que actualizar
// las ventas si un nombre cambia, algo muy raro.

// ---------------------------------------------------------------------
// C5)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.aggregate([
  { $match: { valorTotal: { $gt: 0 } } },
  { $group: { _id: "$idMetodoPago", ventas: { $sum: 1 }, total: { $sum: "$valorTotal" } } },
  { $match: { ventas: { $gte: 10 } } },
  { $project: { _id: 0, metodoPago: "$_id", ventas: 1, total: 1 } },
  { $sort: { total: -1 } }
])

// ---------------------------------------------------------------------
// C6)
// ---------------------------------------------------------------------
// Codigo :
db.ventas.aggregate([
  { $match: { "lineas.origenValor": "Pendiente" } },
  { $count: "ventasConValorPendiente" }
])

// Respuesta :
// {
//   ventasConValorPendiente: 18
// }
// Hay 18 ventas con al menos una línea de valor pendiente (condición crítica: sin ese valor no se conoce
// bien la rentabilidad de cada producto).
// Conclusión: Bancolombia y Nequi concentran más del 85 % de los ingresos y la flor de invierno (FLO-INV)
// aparece en 51 de las 122 líneas vendidas, por lo que conviene priorizar el inventario y el cobro por esos
// medios. Además, hay que completar el valor de las 18 ventas pendientes antes del cierre financiero para
// que los totales sean confiables.


// =====================================================================
// PARTE D
// =====================================================================

// ---------------------------------------------------------------------
// Prepa :
// ---------------------------------------------------------------------
var origen = "ventas", destino = "ventas_volumen", campoFecha = "fecha", objetivo = 50000
var base = db.getCollection(origen).find({}, { _id: 0 }).toArray()
if (base.length === 0) {
  print("La colección " + origen + " está vacía: revisa el nombre")
} else {
  db.getCollection(destino).drop()
  var lote = [], creados = 0
  while (creados < objetivo) {
    for (const doc of base) {
      if (creados >= objetivo) break
      const copia = EJSON.parse(EJSON.stringify(doc, { relaxed: false }))
      if (copia[campoFecha] instanceof Date) {
        copia[campoFecha] = new Date(copia[campoFecha].getTime() - Math.floor(Math.random() * 365) * 86400000)
      }
      lote.push(copia)
      creados++
      if (lote.length === 5000) { db.getCollection(destino).insertMany(lote); lote = [] }
    }
  }
  if (lote.length > 0) db.getCollection(destino).insertMany(lote)
  print("Documentos en " + destino + ": " + db.getCollection(destino).countDocuments())
}

var etapas = exp => [...new Set(JSON.stringify(exp.queryPlanner.winningPlan).match(/"stage":"[A-Z_]+"/g))].map(s => s.slice(9, -1))

// Ayudante "resumen" (usado en D1 y D2). No aparece en el documento; se define aquí
// para que el script corra solo. Si el profesor ya entregó el suyo, usa ese.
var resumen = exp => printjson({
  etapas: etapas(exp),
  devueltos: exp.executionStats.nReturned,
  claves: exp.executionStats.totalKeysExamined,
  documentos: exp.executionStats.totalDocsExamined,
  ms: exp.executionStats.executionTimeMillis
})

// ---------------------------------------------------------------------
// D1)
// ---------------------------------------------------------------------
// Codigo:
resumen(db.ventas_volumen.find({ idCiudad: 2, fecha: { $gte: new Date("2026-06-01T00:00:00-05:00") } }).sort({ fecha: -1 }).explain("executionStats"))

// Respuesta :
// {
//   etapas: [ 'SORT', 'COLLSCAN' ],
//   devueltos: 16144,
//   claves: 0,
//   documentos: 50000,
//   ms: 58
// }

// ---------------------------------------------------------------------
// D2)
// ---------------------------------------------------------------------
// Codigo :
db.ventas_volumen.createIndex({ idCiudad: 1, fecha: -1 })

resumen(db.ventas_volumen.find({ idCiudad: 2, fecha: { $gte: new Date("2026-06-01T00:00:00-05:00") } }).sort({ fecha: -1 }).explain("executionStats"))

// Respuesta :
// idCiudad_1_fecha_-1
//
// {
//   etapas: [ 'FETCH', 'IXSCAN' ],
//   devueltos: 16144,
//   claves: 16144,
//   documentos: 16144,
//   ms: 33
// }
//
// Orden de los campos: idCiudad primero (igualdad), porque deja solo las ventas de esa ciudad.
// Después fecha con -1: sirve a la vez como rango y como orden de la más reciente a la más antigua,
// así no hace falta ordenar en memoria (desaparece la etapa SORT). Como el orden y el rango son el
// mismo campo, fecha va una sola vez en el índice, después de la igualdad.
//
// Antes y después:
// Sin índice: etapas SORT + COLLSCAN | devueltos (N) | claves 0 | documentos 50000 | (X) ms
// Con índice: etapas FETCH + IXSCAN  | devueltos (N) | claves (N) | documentos (N) | (Y) ms
// Relación documentos / devueltos: antes 50000 / (N); después 1.

// ---------------------------------------------------------------------
// D3)
// ---------------------------------------------------------------------
// Codigo :
db.gastos.createIndex({ concepto: "text", conceptoOriginal: "text" }, { default_language: "spanish" })

db.gastos.find(
  { $text: { $search: "domicilio" } },
  { concepto: 1, valor: 1, score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } })

// ---------------------------------------------------------------------
// D4)
// ---------------------------------------------------------------------
// Codigo :
db.ventas_volumen.createIndex({ idCiudad: 1 })
db.ventas_volumen.stats().indexSizes
db.ventas_volumen.aggregate([{ $indexStats: {} }, { $project: { _id: 0, name: 1, usos: "$accesses.ops" } }])
db.ventas_volumen.dropIndex("idCiudad_1")   // porque hay un en mas veces

// Respuesta :
// D4 Eliminé idCiudad_1 porque es redundante: el índice compuesto idCiudad_1_fecha_-1 ya empieza por idCiudad
// y sirve para las mismas búsquedas, y idCiudad_1 tenía 0 usos.
// Tamaños: _id_ (X) bytes, idCiudad_1_fecha_-1 (Y) bytes, idCiudad_1 (Z) bytes.
// Costo: cada índice se actualiza en cada venta nueva, y ocupa disco y memoria. Mi proyecto escribe pocas
// ventas (unas 96 en un mes, cerca de 3 por día), así que el costo de escritura es bajo y vale la pena
// mantener el índice compuesto, que acelera la lectura más frecuente. Un índice sin uso solo
// costaría espacio y tiempo de escritura sin dar ningún beneficio.


// =====================================================================
// PARTE E
// =====================================================================

// ---------------------------------------------------------------------
// E1)
// ---------------------------------------------------------------------
// Operación "todo o nada": modificar el total de una venta. Cambia dos colecciones: actualiza valorTotal
// en ventas y registra el cambio en auditoria_ventas, después de revisar que la venta no esté en un periodo
// ya cerrado (cierres_financieros). Si una de las dos escrituras falla, no puede quedar la otra hecha:
// habría un cambio sin auditoría, o una auditoría de un cambio que nunca ocurrió.
//
// Sin transacción: agregar una línea de producto a una venta con un solo updateOne ($push en lineas y
// $inc en valorTotal). Parece tocar dos cosas, pero las líneas están embebidas en la venta, o sea en un
// solo documento, y MongoDB garantiza que la actualización de un documento es atómica.

// ---------------------------------------------------------------------
// E2)
// ---------------------------------------------------------------------
// Codigo :
function modificarTotalVenta(idAuditoria, idVenta, nuevoTotal) {
  const session = db.getMongo().startSession()
  const sdb = session.getDatabase("liwi_flor_eterna")
  session.startTransaction({ readConcern: { level: "snapshot" }, writeConcern: { w: "majority" } })
  try {
    const venta = sdb.ventas.findOne({ _id: idVenta })
    if (!venta) throw new Error("La venta no existe")
    const r = sdb.ventas.updateOne({ _id: idVenta }, { $set: { valorTotal: nuevoTotal } })
    if (r.modifiedCount !== 1) throw new Error("No se pudo modificar la venta")
    const cierre = sdb.cierres_financieros.findOne({ fechaInicio: { $lte: venta.fecha }, fechaFin: { $gte: venta.fecha } })
    if (cierre) throw new Error("La venta pertenece a un periodo ya cerrado")
    sdb.auditoria_ventas.insertOne({ _id: idAuditoria, idVenta: idVenta, fechaCambio: new Date(), usuarioBD: "laboratorio", accion: "MODIFICA", valorAnterior: "total=" + venta.valorTotal, valorNuevo: "total=" + nuevoTotal, datoDePrueba: true })
    session.commitTransaction()
    print("Confirmada " + idAuditoria)
  } catch (e) {
    session.abortTransaction()
    print("Abortada " + idAuditoria + ": " + e.message)
  } finally {
    session.endSession()
  }
}

db.auditoria_ventas.countDocuments({ _id: 9401 })

modificarTotalVenta(9401, 9301, 35000)

db.ventas.findOne({ _id: 9301 }, { valorTotal: 1 })

db.auditoria_ventas.countDocuments({ _id: 9401 })

// Respuesta :
// (resultados en la captura de pantalla del documento)

// Codigo :
db.ventas.findOne({ _id: 1 }, { valorTotal: 1 })

db.auditoria_ventas.countDocuments({ _id: 9402 })

modificarTotalVenta(9402, 1, 99999)

db.ventas.findOne({ _id: 1 }, { valorTotal: 1 })

db.auditoria_ventas.countDocuments({ _id: 9402 })

db.ventas.deleteOne({ _id: 9301 })

// Respuesta :
// (resultados en la captura de pantalla del documento)

// ---------------------------------------------------------------------
// E3)
// ---------------------------------------------------------------------
// Codigo :
rs.status().members.map(m => m.name + " " + m.stateStr)

db.hello().isWritablePrimary

db.ventas.insertOne(
  { _id: 9501, fecha: new Date(), idCliente: 1, idCiudad: 1, idMetodoPago: 1, valorTotal: 10000, datoDePrueba: true, lineas: [ { idDetalle: 5001, idProducto: 11, sku: "JAL-PEQ", cantidad: 1, valorLinea: 10000, origenValor: "Exacto" } ] },
  { writeConcern: { w: "majority" } }
)

db.getSiblingDB("local").oplog.rs.find({ ns: "liwi_flor_eterna.ventas", "o._id": 9501 })

db.ventas.deleteOne({ _id: 9501 })

// Respuesta :
// En producción tendría 3 nodos (1 primario y 2 secundarios). Con 3 nodos, "majority" son 2: una escritura
// confirmada sigue existiendo aunque un nodo se caiga, y los 2 restantes pueden elegir un nuevo primario
// (con solo 2 nodos, si uno cae, no hay mayoría y no se puede elegir).
// La replicación no evita la pérdida por errores humanos: si alguien borra ventas, gastos o un cierre
// financiero por error (un deleteMany mal hecho), el borrado se copia a todos los nodos. Solo un respaldo
// permite volver a un momento anterior y recuperar esos datos.

// ---------------------------------------------------------------------
// E4)
// ---------------------------------------------------------------------
// Colección de eventos: ventas. Evalúo 3 candidatas de shard key:
//
// 1. { fecha: 1 }
//    Cardinalidad: alta (muchas fechas). Frecuencia: buena. Monotonía: MALA, la fecha solo crece, así que todas
//    las ventas nuevas van al último fragmento (un solo servidor recibe todas las escrituras).
//    Consultas dirigidas: buenas para rangos de fechas, pero no filtran por ciudad.
// 2. { idCliente: 1 }
//    Cardinalidad: MALA, hay solo 7 clientes. Frecuencia: MALA, el cliente 1 tiene 87 de 96 ventas
//    (casi todo en un solo fragmento que no se puede dividir). Monotonía: buena.
//    Consultas dirigidas: solo sirve a consultas por cliente, que no son las más frecuentes.
// 3. { idCiudad: 1, fecha: 1 }
//    Cardinalidad: alta combinando ciudad y fecha. Frecuencia: aceptable, Bogotá concentra más ventas
//    pero se puede dividir por fecha dentro de la ciudad. Monotonía: aceptable, la fecha crece, pero dentro
//    de cada una de las 3 ciudades, así que las escrituras se reparten en hasta 3 puntos.
//    Consultas dirigidas: BUENAS, la consulta más frecuente (ventas de una ciudad en un rango de fechas)
//    va a un solo fragmento.
//
// Elijo { idCiudad: 1, fecha: 1 }, porque es la que mejor sirve a mi patrón de lectura más frecuente.
//
// Volumen: mi negocio hace unas 96 ventas al mes (unos 3 al día) y cada venta pesa menos de 1 KB, así que
// necesitaría sharding solo si los datos llegaran a cientos de GB o a cerca de 1 TB, o si el índice más
// usado dejara de caber en la memoria RAM del servidor. Eso son cientos de millones de ventas: hoy no lo necesito.
//
// Zonas: no las usaría. Todos los usuarios están en Colombia y no hay una exigencia legal de ubicar los datos;
// además, una zona por ciudad dejaría casi todo (Bogotá) en una sola zona y desequilibraría el reparto.
