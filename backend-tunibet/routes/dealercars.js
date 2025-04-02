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
  const images = await getCarImages(car.car_id); 
  return {
    ...car,
    images: images,
    image_url: images.length > 0 ? images[0] : null 
  };
}

router.get('/:id', async (req, res) => {
  const { id } = req.params; 
  console.log('Dealer ID received:', id);

  if (!id || isNaN(id)) {
    return res.status(400).json({ error: 'Valid dealer_id is required' });
  }

  try {
    const result = await pool.query(
      `
      SELECT 
        cars.car_id, 
        cars.make, 
        cars.model, 
        cars.price, 
        cars.is_sold
      FROM cars
      WHERE cars.dealer_id = $1
      `,
      [id] 
    );

    const carsWithImages = await Promise.all(
      result.rows.map(car => formatCarWithImages(car))
    );

    res.json(carsWithImages);
  } catch (error) {
    console.error('Error fetching cars:', error);
    res.status(500).json({ error: 'Failed to fetch cars' });
  }
});

module.exports = router;