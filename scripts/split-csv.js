const fs = require('fs');
const readline = require('readline');
const path = require('path');

async function splitCsvFile() {
  const inputFile = path.join(__dirname, '..', 'data', 'db', 'inventory_parts.csv');
  const outputFile1 = path.join(__dirname, '..', 'data', 'db', 'inventory_parts_1.csv');
  const outputFile2 = path.join(__dirname, '..', 'data', 'db', 'inventory_parts_2.csv');

  // Create read stream and interface
  const fileStream = fs.createReadStream(inputFile);
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity,
  });

  // Create write streams
  const writeStream1 = fs.createWriteStream(outputFile1);
  const writeStream2 = fs.createWriteStream(outputFile2);

  let lineCount = 0;
  let header = '';
  let totalLines = 0;

  // First pass: count total lines
  for await (const line of rl) {
    totalLines++;
  }

  // Reset file stream for second pass
  fileStream.destroy();
  const fileStream2 = fs.createReadStream(inputFile);
  const rl2 = readline.createInterface({
    input: fileStream2,
    crlfDelay: Infinity,
  });

  const halfPoint = Math.floor(totalLines / 2);
  console.log(`Total lines: ${totalLines}, splitting at line: ${halfPoint}`);

  // Second pass: split the file
  for await (const line of rl2) {
    if (lineCount === 0) {
      // Save header and write to both files
      header = line;
      writeStream1.write(header + '\n');
      writeStream2.write(header + '\n');
    } else if (lineCount <= halfPoint) {
      writeStream1.write(line + '\n');
    } else {
      writeStream2.write(line + '\n');
    }
    lineCount++;

    // Log progress every 100,000 lines
    if (lineCount % 100000 === 0) {
      console.log(`Processed ${lineCount} lines...`);
    }
  }

  // Close write streams
  writeStream1.end();
  writeStream2.end();

  console.log('Split complete!');
  console.log(`Part 1: ${outputFile1}`);
  console.log(`Part 2: ${outputFile2}`);
}

// Run the split
splitCsvFile().catch(console.error);
