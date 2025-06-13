#!/usr/bin/env node

// Script to deploy SQL functions to Supabase
// Requires: Node.js and 'pg' package

// How to use:
// 1. Install dependencies: npm install pg dotenv
// 2. Set up a .env file with DATABASE_URL in the format:
//    postgres://postgres:[password]@[host]:[port]/postgres
// 3. Run: node deploy_functions.js

require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Get the database URL from environment variables
const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  console.error('Error: DATABASE_URL not provided in environment variables');
  console.error('Please create a .env file with DATABASE_URL=postgres://...');
  process.exit(1);
}

// Path to SQL file
const sqlFilePath = path.join(__dirname, 'simplified_drawer_settings_fix.sql');

// Function to deploy SQL
async function deploySql() {
  const client = new Client({
    connectionString: databaseUrl,
  });

  try {
    console.log('Reading SQL file...');
    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
    
    console.log('Connecting to Supabase...');
    await client.connect();
    
    console.log('Executing SQL script...');
    await client.query(sqlContent);
    
    console.log('Verifying deployed functions...');
    const { rows } = await client.query(`
      SELECT routine_name, routine_type
      FROM information_schema.routines
      WHERE routine_schema = 'public' AND 
            (routine_name LIKE '%drawer_settings%')
      ORDER BY routine_name;
    `);
    
    console.log('\nDeployed Functions:');
    rows.forEach(row => {
      console.log(`- ${row.routine_name} (${row.routine_type})`);
    });
    
    console.log('\nSQL functions deployed successfully!');
    
  } catch (error) {
    console.error('Error deploying SQL:', error);
  } finally {
    await client.end();
  }
}

// Execute the deployment
deploySql().catch(console.error);
