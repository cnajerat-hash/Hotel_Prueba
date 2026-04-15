CREATE TYPE rol AS ENUM (
	'Huesped',
	'Recepcionista',
	'Administrador'
);
CREATE TYPE estado_reserva AS ENUM (
	'Pendiente',
	'Confirmada',
	'Cancelada',
	'Completada',
	'No_show'
);
CREATE TYPE tipo_habitacion AS ENUM (
	'Individual',
	'Doble',
	'Suite',
	'Familiar'
);
CREATE TYPE estado_habitacion AS ENUM (
	'Libre',
	'Reservada',
	'Ocupada',
	'Mantenimiento',
	'Limpieza'
);
CREATE TYPE tipo_reporte AS ENUM (
	'Ocupación diaria',
	'Ocupación semanal',
	'Ingresos periodo',
	'Lista huespedes'
);
CREATE TYPE tipo_identificacion AS ENUM (
	'CC',
	'CE',
	'Pasaporte',
	'Otro'
);
CREATE TYPE metodo_pago AS ENUM (
	'Efectivo',
	'Tarjeta crédito',
	'Tarjeta débito',
	'Transferencia',
	'Otro'
);
CREATE TYPE estado_pago AS ENUM (
	'Pendiente',
	'Pagado',
	'Reembolsado',
	'Cancelado'
);

CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    tipo_identificacion tipo_identificacion NOT NULL,
    numero_identificacion VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    rol_usuario rol NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    UNIQUE(tipo_identificacion, numero_identificacion)
);

CREATE TABLE habitaciones (
    id_habitacion SERIAL PRIMARY KEY,
    numero INT UNIQUE NOT NULL,
    tipo tipo_habitacion NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad > 0),
    piso INT NOT NULL,
    vista VARCHAR(50),
    precio_noche DECIMAL(10,2) NOT NULL CHECK (precio_noche >= 0),
    estado estado_habitacion NOT NULL DEFAULT 'Libre'
);

CREATE TABLE reservas (
    id_reserva SERIAL PRIMARY KEY,
    fecha_reserva TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    num_huespedes INT NOT NULL CHECK (num_huespedes > 0),
    estado estado_reserva NOT NULL DEFAULT 'Pendiente',
    check_in TIMESTAMP,
    check_out TIMESTAMP,
    costo_total DECIMAL(10,2),
    penalizacion DECIMAL(10,2) DEFAULT 0,
    id_usuario INT NOT NULL REFERENCES usuarios(id_usuario),
    id_habitacion INT NOT NULL REFERENCES habitaciones(id_habitacion),
    observaciones TEXT,
    CONSTRAINT fechas_correctas CHECK (fecha_inicio < fecha_fin),
    CONSTRAINT check_fechas_check CHECK (check_in IS NULL OR check_in >= fecha_inicio),
    CONSTRAINT check_out_after_in CHECK (check_out IS NULL OR check_out > check_in)
);

CREATE TABLE facturas (
    id_factura SERIAL PRIMARY KEY,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    impuestos DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    metodo_pago metodo_pago,
    estado_pago estado_pago DEFAULT 'Pendiente',
    id_reserva INT NOT NULL REFERENCES reservas(id_reserva) UNIQUE
);

CREATE TABLE conceptos_facturas (
    id_concepto SERIAL PRIMARY KEY,
    id_factura INT NOT NULL REFERENCES facturas(id_factura) ON DELETE CASCADE,
    descripcion TEXT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
    importe DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED
);

CREATE TABLE reportes (
    id_reporte SERIAL PRIMARY KEY,
    tipo tipo_reporte NOT NULL,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    periodo_inicio DATE NOT NULL,
    periodo_fin DATE NOT NULL,
    datos JSONB,
    id_usuario INT REFERENCES usuarios(id_usuario),
    CONSTRAINT periodo_valido CHECK (periodo_inicio <= periodo_fin)
);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_rol ON usuarios(rol_usuario);
CREATE INDEX idx_reservas_fechas ON reservas(fecha_inicio, fecha_fin);
CREATE INDEX idx_reservas_estado ON reservas(estado);
CREATE INDEX idx_reservas_usuario ON reservas(id_usuario);
CREATE INDEX idx_reservas_habitacion ON reservas(id_habitacion);
CREATE INDEX idx_facturas_reserva ON facturas(id_reserva);
CREATE INDEX idx_conceptos_factura ON conceptos_facturas(id_factura);
CREATE INDEX idx_reportes_fechas ON reportes(periodo_inicio, periodo_fin);
