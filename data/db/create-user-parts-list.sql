-- Create table for user parts lists
CREATE TABLE user_parts_lists (
    id INTEGER PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    is_buildable BOOLEAN NOT NULL DEFAULT false,
    num_parts INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for frequently accessed columns
CREATE INDEX idx_user_parts_lists_name ON user_parts_lists(name);

-- Create function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update timestamp
CREATE TRIGGER update_user_parts_lists_updated_at
    BEFORE UPDATE ON user_parts_lists
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column(); 