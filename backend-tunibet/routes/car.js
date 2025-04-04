const express = require("express");
const pool = require("../db");
const router = express.Router();

async function getCarImages(carId) {
  const imagesResult = await pool.query(
    'SELECT image_url FROM carimages WHERE car_id = $1 ORDER BY uploaded_at DESC',
    [carId]
  );
  return imagesResult.rows.map(row => row.image_url);
}

async function formatCarWithImages(car) {
  const images = await getCarImages(car.id);
  return {
    ...car,
    images: images,
    image_url: images.length > 0 ? images[0] : null 
  };
}

router.get('/', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        car_id as id, 
        make, 
        model, 
        year, 
        price, 
        mileage, 
        fuel_type, 
        transmission, 
        horsepower, 
        body_type, 
        color, 
        condition, 
        description, 
        location,
        is_sold
      FROM Cars 
      ORDER BY price DESC
    `);
    
    const carsWithImages = await Promise.all(
      result.rows.map(car => formatCarWithImages(car))
    );
    
    res.json(carsWithImages);
  } catch (error) {
    console.error('Error fetching cars:', error);
    res.status(500).json({ error: 'Failed to fetch cars' });
  }
});

router.get('/recommended', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        car_id as id, 
        make, 
        model, 
        year, 
        price, 
        mileage, 
        fuel_type, 
        transmission, 
        horsepower, 
        body_type, 
        color, 
        condition, 
        description, 
        location,
        is_sold
      FROM Cars 
      WHERE is_sold = FALSE
      ORDER BY year DESC, price DESC
      LIMIT 10
    `);
    
    const carsWithImages = await Promise.all(
      result.rows.map(car => formatCarWithImages(car))
    );
    
    res.json(carsWithImages);
  } catch (error) {
    console.error('Error fetching recommended cars:', error);
    res.status(500).json({ error: 'Failed to fetch recommended cars' });
  }
});

router.get('/search', async (req, res) => {
  const { query } = req.query;
  
  if (!query) {
    return res.status(400).json({ error: 'Search query is required' });
  }
  
  try {
    const result = await pool.query(`
      SELECT 
        car_id as id, 
        make, 
        model, 
        year, 
        price, 
        mileage, 
        fuel_type, 
        transmission, 
        horsepower, 
        body_type, 
        color, 
        condition, 
        description, 
        location,
        is_sold
      FROM Cars 
      WHERE 
        (make ILIKE $1 OR 
        model ILIKE $1 OR
        body_type ILIKE $1 OR
        fuel_type ILIKE $1 OR
        CAST(year AS TEXT) LIKE $1)
        AND is_sold = FALSE
      ORDER BY price DESC
    `, [`%${query}%`]);
    
    const carsWithImages = await Promise.all(
      result.rows.map(car => formatCarWithImages(car))
    );
    
    res.json(carsWithImages);
  } catch (error) {
    console.error('Error searching cars:', error);
    res.status(500).json({ error: 'Failed to search cars' });
  }
});

router.get('/:id', async (req, res) => {
  const { id } = req.params;
  
  try {
    const result = await pool.query(`
      SELECT 
        car_id as id, 
        make, 
        model, 
        year, 
        price, 
        mileage, 
        fuel_type, 
        transmission, 
        horsepower, 
        body_type, 
        color, 
        condition, 
        description, 
        location,
        is_sold
      FROM Cars 
      WHERE car_id = $1
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Car not found' });
    }
    
    const car = result.rows[0];
    const carWithImages = await formatCarWithImages(car);
    
    res.json(carWithImages);
  } catch (error) {
    console.error('Error fetching car by ID:', error);
    res.status(500).json({ error: 'Failed to fetch car' });
  }
});

router.get('/filter', async (req, res) => {
  const { 
    make, 
    model, 
    minYear, 
    maxYear, 
    minPrice, 
    maxPrice, 
    fuelType, 
    transmission, 
    bodyType, 
    condition 
  } = req.query;
  
  try {
    let query = `
      SELECT 
        car_id as id, 
        make, 
        model, 
        year, 
        price, 
        mileage, 
        fuel_type, 
        transmission, 
        horsepower, 
        body_type, 
        color, 
        condition, 
        description, 
        location,
        is_sold
      FROM Cars 
      WHERE is_sold = FALSE
    `;
    
    const params = [];
    let paramIndex = 1;
    
    if (make) {
      query += ` AND make ILIKE $${paramIndex}`;
      params.push(`%${make}%`);
      paramIndex++;
    }
    
    if (model) {
      query += ` AND model ILIKE $${paramIndex}`;
      params.push(`%${model}%`);
      paramIndex++;
    }
    
    if (minYear) {
      query += ` AND year >= $${paramIndex}`;
      params.push(minYear);
      paramIndex++;
    }
    
    if (maxYear) {
      query += ` AND year <= $${paramIndex}`;
      params.push(maxYear);
      paramIndex++;
    }
    
    if (minPrice) {
      query += ` AND price >= $${paramIndex}`;
      params.push(minPrice);
      paramIndex++;
    }
    
    if (maxPrice) {
      query += ` AND price <= $${paramIndex}`;
      params.push(maxPrice);
      paramIndex++;
    }
    
    if (fuelType) {
      query += ` AND fuel_type = $${paramIndex}`;
      params.push(fuelType);
      paramIndex++;
    }
    
    if (transmission) {
      query += ` AND transmission = $${paramIndex}`;
      params.push(transmission);
      paramIndex++;
    }
    
    if (bodyType) {
      query += ` AND body_type = $${paramIndex}`;
      params.push(bodyType);
      paramIndex++;
    }
    
    if (condition) {
      query += ` AND condition = $${paramIndex}`;
      params.push(condition);
      paramIndex++;
    }
    
    query += ` ORDER BY price DESC`;
    
    const result = await pool.query(query, params);
    
    const carsWithImages = await Promise.all(
      result.rows.map(car => formatCarWithImages(car))
    );
    
    res.json(carsWithImages);
  } catch (error) {
    console.error('Error filtering cars:', error);
    res.status(500).json({ error: 'Failed to filter cars' });
  }
});

module.exports = router;