const fs = require('fs').promises;
const path = require('path');
const { Pool } = require('pg');

// Configure PostgreSQL connection
const pool = new Pool({
  user: process.env.POSTGRES_USER || 'mylegos_admin',
  host: process.env.POSTGRES_HOST || 'localhost',
  database: process.env.POSTGRES_DB || 'mylegos2',
  password: process.env.POSTGRES_PASSWORD,
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
});

async function syncPartsLists() {
  try {
    // Read the JSON file
    const jsonPath = path.join(__dirname, '..', 'data', 'user', 'partlists.json');
    const jsonContent = await fs.readFile(jsonPath, 'utf8');
    const partsListsData = JSON.parse(jsonContent);

    // Get existing records from database
    const existingRecords = await pool.query('SELECT id FROM user_parts_lists');
    const existingIds = new Set(existingRecords.rows.map(row => row.id));

    // Begin transaction
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Process each parts list
      for (const list of partsListsData.results) {
        if (existingIds.has(list.id)) {
          // Update existing record
          await client.query(
            `UPDATE user_parts_lists 
             SET name = $1, is_buildable = $2, num_parts = $3
             WHERE id = $4`,
            [list.name, list.is_buildable, list.num_parts, list.id]
          );
        } else {
          // Insert new record
          await client.query(
            `INSERT INTO user_parts_lists (id, name, is_buildable, num_parts)
             VALUES ($1, $2, $3, $4)`,
            [list.id, list.name, list.is_buildable, list.num_parts]
          );
        }
      }

      // Delete records that no longer exist in JSON
      const currentIds = partsListsData.results.map(list => list.id);
      await client.query(`DELETE FROM user_parts_lists WHERE id = ANY($1)`, [
        Array.from(existingIds).filter(id => !currentIds.includes(id)),
      ]);

      await client.query('COMMIT');
      console.log('Successfully synchronized parts lists');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Error synchronizing parts lists:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

// Export for use as a module
module.exports = { syncPartsLists };

// Allow running directly from command line
if (require.main === module) {
  syncPartsLists().catch(console.error);
}
