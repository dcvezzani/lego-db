const fs = require('fs').promises;
const path = require('path');
const glob = require('glob');
const { Pool } = require('pg');

// Configure PostgreSQL connection
const pool = new Pool({
  user: process.env.POSTGRES_USER || 'mylegos_admin',
  host: process.env.POSTGRES_HOST || 'localhost',
  database: process.env.POSTGRES_DB || 'mylegos2',
  password: process.env.POSTGRES_PASSWORD,
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
});

async function getPartListFiles() {
  return new Promise((resolve, reject) => {
    glob('data/user/partlists-*.json', (err, files) => {
      if (err) reject(err);
      else resolve(files);
    });
  });
}

async function syncUserParts() {
  const client = await pool.connect();
  try {
    // Get all partlist files
    const files = await getPartListFiles();
    console.log(`Found ${files.length} parts list files to process`);

    await client.query('BEGIN');

    // First, get all existing parts for cleanup later
    const existingParts = await client.query(
      'SELECT id, list_id, part_num, color_id FROM user_parts'
    );
    const existingPartsMap = new Map(
      existingParts.rows.map(row => [`${row.list_id}-${row.part_num}-${row.color_id}`, row.id])
    );

    // Track which parts we process to determine what to delete later
    const processedParts = new Set();
    let totalPartsProcessed = 0;

    // Process each file
    for (const file of files) {
      const content = await fs.readFile(file, 'utf8');
      const data = JSON.parse(content);

      // Extract list ID from filename (partlists-123.json -> 123)
      const listId = parseInt(file.match(/partlists-(\d+)\.json/)[1]);
      console.log(`Processing list ${listId} with ${data.results.length} parts`);

      // Process each part in the results
      for (const item of data.results) {
        const key = `${item.list_id}-${item.part.part_num}-${item.color?.id || null}`;
        processedParts.add(key);

        if (existingPartsMap.has(key)) {
          // Update existing part
          await client.query(
            `UPDATE user_parts 
             SET quantity = $1,
                 part_name = $2,
                 part_cat_id = $3,
                 part_url = $4,
                 part_img_url = $5,
                 color_name = $6,
                 color_rgb = $7,
                 color_is_trans = $8
             WHERE id = $9`,
            [
              item.quantity,
              item.part.name,
              item.part.part_cat_id,
              item.part.part_url,
              item.part.part_img_url,
              item.color?.name,
              item.color?.rgb,
              item.color?.is_trans,
              existingPartsMap.get(key),
            ]
          );
        } else {
          // Insert new part
          await client.query(
            `INSERT INTO user_parts (
               list_id, quantity, part_num, part_name, part_cat_id,
               part_url, part_img_url, color_id, color_name,
               color_rgb, color_is_trans
             ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
            [
              item.list_id,
              item.quantity,
              item.part.part_num,
              item.part.name,
              item.part.part_cat_id,
              item.part.part_url,
              item.part.part_img_url,
              item.color?.id,
              item.color?.name,
              item.color?.rgb,
              item.color?.is_trans,
            ]
          );
        }
        totalPartsProcessed++;
      }
    }

    // Delete parts that no longer exist in any file
    const partsToDelete = Array.from(existingPartsMap.entries())
      .filter(([key]) => !processedParts.has(key))
      .map(([, id]) => id);

    if (partsToDelete.length > 0) {
      console.log(`Deleting ${partsToDelete.length} parts that no longer exist`);
      await client.query('DELETE FROM user_parts WHERE id = ANY($1)', [partsToDelete]);
    }

    await client.query('COMMIT');
    console.log(
      `Successfully synchronized user parts. Processed ${totalPartsProcessed} parts total.`
    );
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error synchronizing user parts:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

// Export for use as a module
module.exports = { syncUserParts };

// Allow running directly from command line
if (require.main === module) {
  syncUserParts().catch(console.error);
}
