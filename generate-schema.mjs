#!/usr/bin/env node

/**
 * Schema Generator Runner
 *
 * This script runs the PureScript schema generator at different scales
 * to create schemas of various sizes for performance testing.
 */

import { main } from './output/SchemaGenerator/index.js';

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';


// Configuration
const SIZES = [10, 100, 500, 1000, 2500, 5000];
const OUTPUT_DIR = 'generated';

// Ensure output directory exists
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR);
}

// Build the generator
console.log('Building schema generator...');

// Function to run the generator with a specific size
function generateSchema(size) {
  console.log(`\nGenerating schema with ${size} types...`);

  // Run the generator
  const startTime = Date.now();
  main(size)();
  const endTime = Date.now();

  // Calculate time taken and file size
  const generatedFile = path.join('src', 'LargeSchema.purs');
  const stats = fs.statSync(generatedFile);
  const fileSizeMB = (stats.size / (1024 * 1024)).toFixed(2);
  const timeTakenSec = ((endTime - startTime) / 1000).toFixed(2);

  // Copy the generated file to output directory with size in filename
  const destFile = path.join(OUTPUT_DIR, `schema_${size}_types.purs`);
  fs.copyFileSync(generatedFile, destFile);

  console.log(`✓ Generated schema with ${size} types`);
  console.log(`  - File size: ${fileSizeMB} MB`);
  console.log(`  - Generation time: ${timeTakenSec} seconds`);

  return {
    size,
    fileSizeMB: parseFloat(fileSizeMB),
    timeTakenSec: parseFloat(timeTakenSec)
  };
}

// Run the generator with each size and collect metrics
console.log('\n=== Schema Generation Performance Tests ===\n');
const results = [];

for (const size of SIZES) {
  try {
    const result = generateSchema(size);
    results.push(result);
  } catch (err) {
    console.error(`Error generating schema with ${size} types:`, err.message);
  }
}

// Output a summary table
console.log('\n=== Generation Results Summary ===');
console.log('Size (types) | File Size (MB) | Generation Time (s)');
console.log('-------------|----------------|-------------------');
results.forEach(({ size, fileSizeMB, timeTakenSec }) => {
  console.log(`${size.toString().padEnd(12)} | ${fileSizeMB.toString().padEnd(14)} | ${timeTakenSec}`);
});

console.log('\nDone! Generated schemas are in the "generated" directory.');