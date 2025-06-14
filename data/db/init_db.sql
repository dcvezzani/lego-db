-- Initialize database tables for LEGO database
-- Created tables will store information about LEGO sets, parts, colors, and inventories

-- Colors table
CREATE TABLE colors (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    rgb CHAR(6),
    is_trans BOOLEAN NOT NULL,
    num_parts INTEGER,
    num_sets INTEGER,
    y1 INTEGER,  -- First year of appearance
    y2 INTEGER   -- Last year of appearance
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_colors_name ON colors(name);
CREATE INDEX idx_colors_rgb ON colors(rgb);

-- Copy data from CSV
COPY colors(id, name, rgb, is_trans, num_parts, num_sets, y1, y2)
FROM '/tmp/lego-db/colors.csv'
WITH (FORMAT csv, HEADER true);

-- Part Categories table
CREATE TABLE part_categories (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create index for category name
CREATE INDEX idx_part_categories_name ON part_categories(name);

-- Copy data from CSV
COPY part_categories(id, name)
FROM '/tmp/lego-db/part_categories.csv'
WITH (FORMAT csv, HEADER true);

-- Sets table
CREATE TABLE sets (
    set_num VARCHAR(20) PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    year INTEGER,
    theme_id INTEGER,
    num_parts INTEGER,
    img_url TEXT
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_sets_name ON sets(name);
CREATE INDEX idx_sets_year ON sets(year);
CREATE INDEX idx_sets_theme_id ON sets(theme_id);

-- Copy data from CSV
COPY sets(set_num, name, year, theme_id, num_parts, img_url)
FROM '/tmp/lego-db/sets.csv'
WITH (FORMAT csv, HEADER true);

-- Inventories table
CREATE TABLE inventories (
    id INTEGER PRIMARY KEY,
    version INTEGER NOT NULL,
    set_num VARCHAR(20) NOT NULL REFERENCES sets(set_num)
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_inventories_set_num ON inventories(set_num);

-- Copy data from CSV
COPY inventories(id, version, set_num)
FROM '/tmp/lego-db/inventories.csv'
WITH (FORMAT csv, HEADER true);

-- Parts table
CREATE TABLE parts (
    part_num VARCHAR(20) PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    part_cat_id INTEGER REFERENCES part_categories(id),
    part_material VARCHAR(50)
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_parts_name ON parts(name);
CREATE INDEX idx_parts_category ON parts(part_cat_id);

-- Copy data from CSV
COPY parts(part_num, name, part_cat_id, part_material)
FROM '/tmp/lego-db/parts.csv'
WITH (FORMAT csv, HEADER true);

-- Inventory Parts table
CREATE TABLE inventory_parts (
    inventory_id INTEGER REFERENCES inventories(id),
    part_num VARCHAR(20) REFERENCES parts(part_num),
    color_id INTEGER REFERENCES colors(id),
    quantity INTEGER NOT NULL,
    is_spare BOOLEAN NOT NULL,
    img_url TEXT,
    PRIMARY KEY (inventory_id, part_num, color_id)
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_inventory_parts_part ON inventory_parts(part_num);
CREATE INDEX idx_inventory_parts_color ON inventory_parts(color_id);

-- Copy data from CSV
COPY inventory_parts(inventory_id, part_num, color_id, quantity, is_spare, img_url)
FROM '/tmp/lego-db/inventory_parts.csv'
WITH (FORMAT csv, HEADER true);

-- Part Relationships table
CREATE TABLE part_relationships (
    rel_type VARCHAR(1) NOT NULL,
    child_part_num VARCHAR(20) REFERENCES parts(part_num),
    parent_part_num VARCHAR(20) REFERENCES parts(part_num),
    PRIMARY KEY (child_part_num, parent_part_num)
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_part_relationships_parent ON part_relationships(parent_part_num);
CREATE INDEX idx_part_relationships_child ON part_relationships(child_part_num);

-- Copy data from CSV
COPY part_relationships(rel_type, child_part_num, parent_part_num)
FROM '/tmp/lego-db/part_relationships.csv'
WITH (FORMAT csv, HEADER true);

-- Minifigs table
CREATE TABLE minifigs (
    fig_num VARCHAR(20) PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    num_parts INTEGER,
    img_url TEXT
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_minifigs_name ON minifigs(name);

-- Copy data from CSV
COPY minifigs(fig_num, name, num_parts, img_url)
FROM '/tmp/lego-db/minifigs.csv'
WITH (FORMAT csv, HEADER true);

-- Inventory Minifigs table
CREATE TABLE inventory_minifigs (
    inventory_id INTEGER REFERENCES inventories(id),
    fig_num VARCHAR(20) REFERENCES minifigs(fig_num),
    quantity INTEGER NOT NULL,
    PRIMARY KEY (inventory_id, fig_num)
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_inventory_minifigs_fig ON inventory_minifigs(fig_num);

-- Copy data from CSV
COPY inventory_minifigs(inventory_id, fig_num, quantity)
FROM '/tmp/lego-db/inventory_minifigs.csv'
WITH (FORMAT csv, HEADER true);

-- Inventory Sets table
CREATE TABLE inventory_sets (
    inventory_id INTEGER REFERENCES inventories(id),
    set_num VARCHAR(20) REFERENCES sets(set_num),
    quantity INTEGER NOT NULL,
    PRIMARY KEY (inventory_id, set_num)
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_inventory_sets_set ON inventory_sets(set_num);

-- Copy data from CSV
COPY inventory_sets(inventory_id, set_num, quantity)
FROM '/tmp/lego-db/inventory_sets.csv'
WITH (FORMAT csv, HEADER true);

-- Elements table
CREATE TABLE elements (
    element_id VARCHAR(20) PRIMARY KEY,
    part_num VARCHAR(20) REFERENCES parts(part_num),
    color_id INTEGER REFERENCES colors(id),
    design_id VARCHAR(20)
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_elements_part ON elements(part_num);
CREATE INDEX idx_elements_color ON elements(color_id);

-- Copy data from CSV
COPY elements(element_id, part_num, color_id, design_id)
FROM '/tmp/lego-db/elements.csv'
WITH (FORMAT csv, HEADER true); 