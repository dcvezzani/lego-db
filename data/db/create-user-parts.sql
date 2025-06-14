-- Create table for user parts
CREATE TABLE user_parts (
    id SERIAL PRIMARY KEY,
    list_id INTEGER NOT NULL REFERENCES user_parts_lists(id),
    quantity INTEGER NOT NULL DEFAULT 0,
    part_num VARCHAR(20) NOT NULL REFERENCES parts(part_num),
    part_name VARCHAR(256) NOT NULL,
    part_cat_id INTEGER REFERENCES part_categories(id),
    part_url TEXT,
    part_img_url TEXT,
    color_id INTEGER REFERENCES colors(id),
    color_name VARCHAR(50),
    color_rgb CHAR(6),
    color_is_trans BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for frequently accessed columns
CREATE INDEX idx_user_parts_list_id ON user_parts(list_id);
CREATE INDEX idx_user_parts_part_num ON user_parts(part_num);
CREATE INDEX idx_user_parts_color_id ON user_parts(color_id);

-- Create function to update timestamp
CREATE OR REPLACE FUNCTION update_user_parts_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update timestamp
CREATE TRIGGER update_user_parts_updated_at
    BEFORE UPDATE ON user_parts
    FOR EACH ROW
    EXECUTE FUNCTION update_user_parts_updated_at_column(); 