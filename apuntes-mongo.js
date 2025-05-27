.insertOne -> insertar un documento a la colección
.insertMany -> inserta varios documentos a la colección
.find -> buscar documentos
.countDocument ->  cuenta cuántos documentos coinciden.
.updateOne -> actualiza un documento
.updateMany -> actualiza varios documentos
.deleteMany -> elimina todos los que coincidan
.aggregate -> agrupar{
En SQL, para agrupar y hacer cálculos, usas:
SELECT gender, AVG(age) FROM people GROUP BY gender;
En MongoDB sería:
db.people.aggregate([
  { $group: { _id: "$gender", averageAge: { $avg: "$age" } } }
])
}

//Operadores clave
//Operadores para consultas (find, findOne)
$eq -> igual a ({ edad: { $eq: 25 } })
$ne -> distinto de ({ edad: { $ne: 25 } } )
$gt -> superior “>” ({ edad: { $gt: 25 } }) 
$gte -> igual o superior “=>”({ edad: { $gte: 25 } }) 
$lt -> menor “<”({ edad: { $lt: 25 } }) 
$lte -> igual o menor “=<”({ edad: { $lte: 25 } }) 
$in -> en un array ({ edad: { $in: [20, 25, 30] } }) 
$nin -> no está en array ({ edad: { $nin: [20, 25] } } )
$regex -> Expresiones regulares ({ nombre: { $regex: /Ana/ } })
$exist -> El campo existe ({ telefono: { $exists: true } })
$type -> Tipo de dato ({ edad: { $type: "number" } })
$or -> Alguna de las condiciones es cierta ({ $or: [{ edad: 25 }, { edad: 30 }] })
$and -> Las dos condiciones son ciertas ({ $and: [...] }) 
$not -> Negación ({ edad: { $not: { $gt: 25 } } })

//Operadores para actualizaciones (updateOne, updateMany)
$set -> Añadir o modificar campos ({ $set: { edad: 30 } })
$unset -> Eliminar campos ({ $unset: { telefono: "" } })
$inc -> Incrementa ({ $inc: { edad: 1 } })
$mul -> Multiplica({ $mul: { salario: 1.1 } })
$rename -> renombrar campo ({ $rename: { nombre: "nombreCompleto" } })
$push - Añadir al final de un array ({ $push: { tags: "nuevo" } })
$addToSet -> Añadir al array solo si no existe ({ $addToSet: { tags: "nuevo" } })
$pull -> Eliminar elementos específicos de un array ({ $pull: { tags: "viejo" } })
$pop -> Eliminar primer/último elemento de un array ({ $pop: { tags: 1 } })
$pullAll -> Eliminar varios ({ $pullAll: { tags: ["a", "b"] } })

//Operadores de agregación (aggregate)
$match -> Filtra documentos como el WHERE ({ $match: { gender: "female" } })
$group -> Agrupar por algún criterio como el group by ({ $group: { _id: "$gender", total: { $sum: 1 } } })
$sum -> Sumar ({ $group: { _id: null, totalBalance: { $sum: "$balance" } } })
$avg -> hacer promedio de valores (media) ({ $group: { _id: "$gender", averageAge: { $avg: "$age" } } })
$min/$max -> mínimo y máximo ({ $group: { _id: null, minAge: { $min: "$age" }, maxAge: { $max: "$age" } } })
$push -> mete valores en array ({ $group: { _id: "$gender", names: { $push: "$name" } } })
$addToSet -> mete valores únicos en array ({ $group: { _id: "$gender", uniqueCompanies: { $addToSet: "$company" } } } )
$first / $last → toma primer o último valor ({ $group: { _id: "$gender", firstPerson: { $first: "$name" }, lastPerson: { $last: "$name" } } })
$project -> selecciona o calcula campos (como SELECT) ({ $project: { name: 1, email: 1, fullName: { $concat: ["$name", " <", "$email", ">"] } } })
$sort -> ordena resultados ({ $sort: { age: -1 } })
$limit -> limita resultados ({ $limit: 5 })
$size-> tamaño actual de un array
$unwind -> Descomponer arrays en documentos individuales ({ $unwind: "$tags" })
$count -> cuenta documentos ({ $count: "totalPeople" })
