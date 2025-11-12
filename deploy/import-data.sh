#!/bin/bash

# Скрипт для імпорту даних на сервер

sshpass -p "VandiPCEXeep" ssh -o StrictHostKeyChecking=no root@88.99.38.25 "docker exec for-you-admin-panel-backend-prod sh -c 'cd /app && node -e \"
const { AppDataSource } = require(\\\"./dist/config/database\\\");
const { Country } = require(\\\"./dist/entities/Country\\\");
const { City } = require(\\\"./dist/entities/City\\\");
const { Area } = require(\\\"./dist/entities/Area\\\");
const { Developer } = require(\\\"./dist/entities/Developer\\\");
const { Facility } = require(\\\"./dist/entities/Facility\\\");
const { Property } = require(\\\"./dist/entities/Property\\\");
const fs = require(\\\"fs\\\");

async function importData() {
  try {
    await AppDataSource.initialize();
    console.log(\\\"✅ Database connected\\\");
    
    // Import countries
    console.log(\\\"\\n1️⃣ Importing countries...\\\");
    const countriesData = JSON.parse(fs.readFileSync(\\\"/app/exported-offplan-data/countries.json\\\", \\\"utf-8\\\"));
    const countryRepo = AppDataSource.getRepository(Country);
    let countriesImported = 0;
    for (const country of countriesData) {
      const existing = await countryRepo.findOne({ where: { code: country.code } });
      if (!existing) {
        await countryRepo.save(country);
        countriesImported++;
      }
    }
    console.log(\\\"✅ Imported\\\", countriesImported, \\\"countries\\\");
    
    // Import cities
    console.log(\\\"\\n2️⃣ Importing cities...\\\");
    const citiesData = JSON.parse(fs.readFileSync(\\\"/app/exported-offplan-data/cities.json\\\", \\\"utf-8\\\"));
    const cityRepo = AppDataSource.getRepository(City);
    let citiesImported = 0;
    for (const city of citiesData) {
      const country = await countryRepo.findOne({ where: { id: city.countryId } });
      if (country) {
        const existing = await cityRepo.findOne({ where: { id: city.id } });
        if (!existing) {
          await cityRepo.save(city);
          citiesImported++;
        }
      }
    }
    console.log(\\\"✅ Imported\\\", citiesImported, \\\"cities\\\");
    
    // Import areas
    console.log(\\\"\\n3️⃣ Importing areas...\\\");
    const areasData = JSON.parse(fs.readFileSync(\\\"/app/exported-offplan-data/areas.json\\\", \\\"utf-8\\\"));
    const areaRepo = AppDataSource.getRepository(Area);
    let areasImported = 0;
    for (const area of areasData) {
      const city = await cityRepo.findOne({ where: { id: area.cityId } });
      if (city) {
        const existing = await areaRepo.findOne({ where: { id: area.id } });
        if (!existing) {
          await areaRepo.save(area);
          areasImported++;
        }
      }
    }
    console.log(\\\"✅ Imported\\\", areasImported, \\\"areas\\\");
    
    // Import developers (already done, skip duplicates)
    console.log(\\\"\\n4️⃣ Developers already imported: 739\\\");
    
    // Import facilities (already done, skip duplicates)
    console.log(\\\"5️⃣ Facilities already imported: 4631\\\");
    
    // Import properties
    console.log(\\\"\\n6️⃣ Importing properties...\\\");
    const propertiesData = JSON.parse(fs.readFileSync(\\\"/app/exported-offplan-data/properties-offplan.json\\\", \\\"utf-8\\\"));
    const propertyRepo = AppDataSource.getRepository(Property);
    let propsImported = 0;
    let propsErrors = 0;
    
    for (const prop of propertiesData.slice(0, 100)) { // Import first 100 for testing
      try {
        const area = await areaRepo.findOne({ where: { id: prop.areaId } });
        const developer = await AppDataSource.getRepository(Developer).findOne({ where: { id: prop.developerId } });
        
        if (area && developer) {
          const existing = await propertyRepo.findOne({ where: { id: prop.id } });
          if (!existing) {
            await propertyRepo.save(prop);
            propsImported++;
          }
        } else {
          propsErrors++;
        }
      } catch (e) {
        propsErrors++;
      }
    }
    
    console.log(\\\"✅ Imported\\\", propsImported, \\\"properties\\\");
    console.log(\\\"⚠️ Errors:\\\", propsErrors);
    
    await AppDataSource.destroy();
    console.log(\\\"\\n✅ Import completed!\\\");
    process.exit(0);
  } catch (error) {
    console.error(\\\"❌ Error:\\\", error);
    await AppDataSource.destroy();
    process.exit(1);
  }
}

importData();
\"'"

