-- Query 1: Group parts by part number, showing total quantity and which lists they appear in
-- This query is useful for seeing how many of each part you have total and where they are used
SELECT 
    p.part_num,
    p.part_name,
    p.part_cat_id,
    p.color_id,
    p.color_name,
    SUM(p.quantity) as total_quantity,
    json_agg(
        json_build_object(
            'list_id', p.list_id,
            'quantity', p.quantity
        )
    ) as list_quantities
FROM user_parts p
GROUP BY 
    p.part_num,
    p.part_name,
    p.part_cat_id,
    p.color_id,
    p.color_name
ORDER BY total_quantity DESC;

-- Example output:
/*
 part_num | part_name | part_cat_id | color_id | color_name | total_quantity | list_quantities
----------+-----------+-------------+----------+------------+----------------+----------------
 3001     | Brick 2x4 |         47  |       1  | White      |           150  | [{"list_id": 793706, "quantity": 100}, {"list_id": 802516, "quantity": 50}]
 3003     | Brick 2x2 |         47  |       0  | Black      |           120  | [{"list_id": 793706, "quantity": 70}, {"list_id": 799199, "quantity": 50}]
*/

-- Note: The json_agg function creates an array of JSON objects, making it easy to see:
-- 1. Which lists contain each part
-- 2. How many of that part are in each list
-- 3. The total quantity across all lists 