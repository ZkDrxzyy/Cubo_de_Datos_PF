DROP TABLE IF EXISTS fact_ventas CASCADE;
DROP TABLE IF EXISTS dim_producto CASCADE;
DROP TABLE IF EXISTS dim_pais CASCADE;


CREATE TABLE dim_producto (
    id SERIAL PRIMARY KEY,
    categoria VARCHAR(50),
    nombre VARCHAR(50)
);

CREATE TABLE dim_pais (
    id SERIAL PRIMARY KEY,
    region VARCHAR(50), 
    pais VARCHAR(50)
);

CREATE TABLE fact_ventas (
    id SERIAL PRIMARY KEY,
    producto_id INT REFERENCES dim_producto(id),
    pais_id INT REFERENCES dim_pais(id),
    cantidad INT,
    total_dinero DECIMAL(10,2),
    fecha DATE DEFAULT CURRENT_DATE
);

--  POBLAR DIMENSIONES (CATÁLOGOS)

INSERT INTO dim_producto (categoria, nombre) VALUES 
('Electronica', 'Laptop'), 
('Electronica', 'Mouse'), 
('Electronica', 'Tablet'),
('Muebles', 'Silla'),
('Hogar', 'Lampara'),
('Deportes', 'Balon Futbol'),
('Deportes', 'Raqueta Tenis'),
('Ropa', 'Jeans'),
('Ropa', 'Chamarra'),
('Juguetes', 'Lego Set');

INSERT INTO dim_pais (region, pais) VALUES 
('America', 'Mexico'), 
('America', 'USA'),
('America', 'Brasil'),
('America', 'Argentina'),
('Europa', 'España'),
('Europa', 'Francia'),
('Europa', 'Alemania'),
('Asia', 'Japon');

-- CARGA DE VENTAS (ALEATORIA)

-- PASO A: La Garantía (Cross Join)
-- Asegura que haya al menos 1 venta por cada país y producto
INSERT INTO fact_ventas (producto_id, pais_id, cantidad, total_dinero, fecha)
SELECT 
    p.id, 
    c.id, 
    floor(random() * 5 + 1)::int,
    (floor(random() * 50 + 10))::decimal(10,2),
    CURRENT_DATE - (floor(random() * 30)::int)
FROM dim_producto p
CROSS JOIN dim_pais c;

-- PASO B: El Volumen Masivo (50,000 Registros)
-- ESTRATEGIA MATEMÁTICA: Usamos random() numérico directo.
-- Al no hacer subconsultas (SELECT id FROM...), evitamos que el optimizador guarde el resultado en caché.
-- Asumimos IDs secuenciales (1..N) ya que acabamos de crear las tablas.
INSERT INTO fact_ventas (producto_id, pais_id, cantidad, total_dinero, fecha)
WITH conteos AS (
    SELECT 
        (SELECT COUNT(*) FROM dim_producto) as max_prod,
        (SELECT COUNT(*) FROM dim_pais) as max_pais
)
SELECT 
    -- Genera un ID matemático entre 1 y el total de productos
    (floor(random() * c.max_prod) + 1)::int,
    
    -- Genera un ID matemático entre 1 y el total de países
    (floor(random() * c.max_pais) + 1)::int,
    
    -- Cantidad Aleatoria (1 a 20 unidades)
    floor(random() * 20 + 1)::int,
    
    -- Total Dinero (Precio variable simulado)
    (floor(random() * 20 + 1)::int * (random() * 200 + 20))::decimal(10,2),
    
    -- Fecha Aleatoria (últimos 365 días)
    CURRENT_DATE - (floor(random() * 365)::int)
FROM generate_series(1, 50000), conteos c;

-- VERIFICACIÓN FINAL
SELECT COUNT(*) as total_ventas FROM fact_ventas;

-- Para comprobar la distribución:
-- SELECT p.pais, COUNT(*) FROM fact_ventas v JOIN dim_pais p ON v.pais_id = p.id GROUP BY p.pais;