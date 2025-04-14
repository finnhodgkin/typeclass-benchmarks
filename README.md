# PureScript Schema Type-Level Class Benchmarks

This project demonstrates type-level programming in PureScript and includes tools to benchmark the performance of large schemas.

## Overview

The codebase implements a type-level schema validation system using PureScript's advanced type system features. The key features include:

- Type-level schema validation
- Symbol-to-type mapping using type classes
- Deep record structure validation
- Nested record compatibility checks
- Benchmark tools for testing performance with large schemas

## Project Structure

- `src/MinimalAPI.purs` - Core type-level validation logic
- `src/TestSchema.purs` - Schema definition examples
- `src/SchemaGenerator.purs` - Generator for large schema files
- `src/TestLargeSchema.purs` - Test module for benchmarking

## Setup

1. Install dependencies:

```
spago install
```

## Running the Schema Generator

To generate schema files of different sizes:

```
node generate-schema.js
```

This will:
- Generate schema files with different numbers of types (10 to 10,000)
- Save them to the `generated/` directory
- Report the file size and generation time for each

## Running the Benchmarks

To benchmark compilation time for different schema sizes:

```
node benchmark.js
```

This will:
- Compile each generated schema
- Measure compilation time and memory usage
- Generate a summary and CSV report of the results

## Custom Schema Generation

You can modify the `generate-schema.js` script to change the sizes of schemas generated. The configuration is at the top of the file:

```javascript
const SIZES = [10, 100, 500, 1000, 2500, 5000, 10000];
```

## Benchmarking Individual Schemas

To test a specific schema size:

1. Copy the schema file from `generated/` to `src/LargeSchema.purs`
2. Run:

```
spago build --main TestLargeSchema
```

## Understanding the Results

The benchmark results will show:
- How compilation time scales with schema size
- Memory usage during compilation
- Where the compiler starts to struggle

This can help identify opportunities for optimization in your type-level code.

## Implementation Details

The core of this system is the `inSchema` function in `MinimalAPI.purs`, which validates that a record matches a schema at the type level. The type class `SymbolToType` is used to resolve type relationships through symbol references, allowing circular references in the schema.

The benchmark generator creates complex, interconnected schema types with a controlled amount of randomness to simulate real-world usage.