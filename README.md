# Práctica 4 - Modelo relacional
## Script
Cabe destacar la creación de la base de datos para posteriormente conectarse a ella con \c viveros. Se puede crear de otra forma con:
`CREATE DATABASE viveros;` para ya después conectarse a ella y ejecutar el script con todos los siguientes comandos.


## Estructura del modelo relacional
### `vivero`
* **Clave Primaria (PK):** `id_vivero`
* **Atributos:** `nombre`, `latitud`, `longitud`
- Se añade restricción de latitud y longitud entre rangos específicos

### `zona`
Es una **entidad débil** dependiente de `vivero`.
* **Clave Primaria (PK):** `(id_vivero, id_zona)`
* **Clave Foránea (FK):** `id_vivero` hace referencia a `vivero` con borrado en cascada (`ON DELETE CASCADE`).
* **Atributos:** `nombre`, `latitud`, `longitud`
- Mismas restricciones de latitud y longitud

### `empleado`
* **Clave Primaria (PK):** `id_empleado`
* **Atributos:** `nombre`, `apellidos`, `telefono`

### `historico_puesto`
Representante de una relación entre la zona y el empleado 

* **Clave Primaria (PK):** `id_historico`
* **Claves Foráneas (FK):**
  * `id_empleado` referencia a `empleado`
  * `(id_vivero, id_zona)` referencia a la clave primaria compuesta de `zona`
* **Atributos:** `puesto`, `fecha_inicio`, `fecha_fin`, `productividad`
- Restricción de productividad no menor a 0
- Restricción de fecha de finalización mayor a la de inicio

### `cliente`
* **Clave Primaria (PK):** `id_cliente`
* **Atributos:** `nombre`

### `cliente_plus`
Representa una especialización de cliente.
* **Clave Primaria y Foránea (PK/FK):** `id_cliente` referencia a `cliente(id_cliente)`
* **Atributos específicos:** `fecha_ingreso`, `bonificacion_acumulada`
- Restricción de bonificación no menor a 0

### `producto`
* **Clave Primaria (PK):** `id_producto`
* **Atributos:** `nombre`, `tipo`, `precio`
- Restricción de precio no menor a 0

### `stock_zona`
Relación M:N que indica la cantidad disponible de cada producto en una zona específica de un vivero.

* **Clave Primaria (PK):** Compuesta por `(id_vivero, id_zona, id_producto)`
* **Claves Foráneas (FK):**
  * `(id_vivero, id_zona)` referencia a `zona`
  * `id_producto`  referencia a `producto`
* **Atributo:** `stock`
- Restricción de stock no menor a 0

### `pedido`

* **Clave Primaria (PK):** `num_pedido`
* **Claves Foráneas (FK):**
  * `id_cliente`  referencia al cliente comprador (`ON DELETE RESTRICT`)
  * `id_empleado`  referencia al empleado que procesa el pedido (`ON DELETE RESTRICT`)
* **Atributos:** `fecha`, `importe_total` (atributo derivado/calculado)
- Restricción de importe total no menor a 0

### `detalle_pedido`
Líneas o productos individuales incluidos en cada pedido (Relación M:N entre `pedido` y `producto`).

* **Clave Primaria (PK):** Compuesta por `(num_pedido, id_producto)`
* **Claves Foráneas (FK):**
  * `num_pedido` referencia a `pedido` (`ON DELETE CASCADE`)
  * `id_producto` referencia a `producto` (`ON DELETE RESTRICT`)
* **Atributo:** `cantidad`
- Restricción de cantidad no mayor a 0
