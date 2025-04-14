#!/usr/bin/env node

/**
 * Schema Compilation Benchmark
 *
 * This script measures the compilation time for schemas of different sizes.
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Configuration
const OUTPUT_DIR = 'generated';
const RESULTS_FILE = 'benchmark_results.csv';

// Ensure output directory exists
if (!fs.existsSync(OUTPUT_DIR)) {
  console.log('Error: Please run generate-schema.js first to create the schemas.');
  process.exit(1);
}

// Get the list of available schema files
const schemaFiles = fs.readdirSync(OUTPUT_DIR)
  .filter(file => file.startsWith('schema_') && file.endsWith('.purs'))
  .sort((a, b) => {
    const sizeA = parseInt(a.match(/schema_(\d+)_types/)[1]);
    const sizeB = parseInt(b.match(/schema_(\d+)_types/)[1]);
    return sizeA - sizeB;
  });

if (schemaFiles.length === 0) {
  console.log('Error: No schema files found. Please run generate-schema.js first.');
  process.exit(1);
}

console.log(`Found ${schemaFiles.length} schema files to benchmark.`);

// Prepare results file
const resultsHeader = 'Schema Size,File Size (MB),Compile Time (s),Compile Memory (MB)';
fs.writeFileSync(RESULTS_FILE, resultsHeader + '\n');

// Function to benchmark compilation of a schema
function benchmarkSchema(schemaFile) {
  const match = schemaFile.match(/schema_(\d+)_types/);
  if (!match) return null;

  const schemaSize = match[1];
  console.log(`\nBenchmarking schema with ${schemaSize} types...`);

  // Copy the schema file to src directory
  const sourcePath = path.join(OUTPUT_DIR, schemaFile);
  const destPath = path.join('src', 'LargeSchema.purs');
  fs.copyFileSync(sourcePath, destPath);

  // Get file size
  const stats = fs.statSync(destPath);
  const fileSizeMB = (stats.size / (1024 * 1024)).toFixed(2);

  // Measure compilation time
  try {
    console.log('Compiling...');
    const startTime = Date.now();

    // Using --verbose-errors to capture memory usage from the output
    const result = execSync('spago build', {
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe']
    });

    const endTime = Date.now();
    const compileTimeSec = ((endTime - startTime) / 1000).toFixed(2);

    // Try to extract memory usage (this depends on compiler output format)
    let memoryUsageMB = 'N/A';
    const memoryMatch = result.match(/Memory: (\d+(\.\d+)?)MB/i);
    if (memoryMatch) {
      memoryUsageMB = memoryMatch[1];
    }

    console.log(`✓ Compilation successful in ${compileTimeSec} seconds`);
    console.log(`  - Schema size: ${schemaSize} types`);
    console.log(`  - File size: ${fileSizeMB} MB`);
    if (memoryUsageMB !== 'N/A') {
      console.log(`  - Memory usage: ${memoryUsageMB} MB`);
    }

    // Append results to CSV
    const resultLine = `${schemaSize},${fileSizeMB},${compileTimeSec},${memoryUsageMB}`;
    fs.appendFileSync(RESULTS_FILE, resultLine + '\n');

    return {
      schemaSize: parseInt(schemaSize),
      fileSizeMB: parseFloat(fileSizeMB),
      compileTimeSec: parseFloat(compileTimeSec),
      memoryUsageMB
    };
  } catch (error) {
    console.error(`❌ Compilation failed for schema with ${schemaSize} types`);
    console.error(error.message);

    // Still record the failure in the results
    const resultLine = `${schemaSize},${fileSizeMB},FAILED,FAILED`;
    fs.appendFileSync(RESULTS_FILE, resultLine + '\n');

    return null;
  }
}

// Run benchmarks for all schemas
console.log('\n=== Schema Compilation Benchmarks ===\n');
const results = [];

for (const schemaFile of schemaFiles) {
  const result = benchmarkSchema(schemaFile);
  if (result) {
    results.push(result);
  }
}

// Output summary
console.log('\n=== Benchmark Results Summary ===');
console.log('Schema Size | File Size (MB) | Compile Time (s) | Memory (MB)');
console.log('------------|----------------|------------------|------------');
results.forEach(({ schemaSize, fileSizeMB, compileTimeSec, memoryUsageMB }) => {
  console.log(`${schemaSize.toString().padEnd(11)} | ${fileSizeMB.toString().padEnd(14)} | ${compileTimeSec.toString().padEnd(16)} | ${memoryUsageMB}`);
});

console.log(`\nResults saved to ${RESULTS_FILE}`);
console.log('\nDone! Benchmark completed.');