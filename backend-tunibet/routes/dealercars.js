const express = require("express");
const pool = require("../db");
const router = express.Router();

async function getCarImages(carId) {
  try {
    const imagesResult = await pool.query(
      "SELECT image_url FROM carimages WHERE car_id = $1 ORDER BY uploaded_at DESC",
      [carId]
    );
    return imagesResult.rows.map(row => row.image_url);
  } catch (error) {
    console.error(`Error fetching images for car ${carId}:`, error);
    return []; 
  }
}

async function formatCarWithImages(car) {
  try {
    const images = await getCarImages(car.car_id);
    return {
      ...car,
      images: images,
      image_url: images.length > 0 ? images[0] : null,
      is_sold: car.is_sold || false 
    };
  } catch (error) {
    console.error(`Error formatting car ${car.car_id}:`, error);
    return {
      ...car,
      images: [],
      image_url: null,
      is_sold: car.is_sold || false
    };
  }
}

router.get('/:id', async (req, res) => {
  const { id } = req.params;
  console.log(`Fetching cars for dealer ID: ${id}`);
  try {
    const dealerCheck = await pool.query(
      'SELECT dealer_id FROM dealers WHERE dealer_id = $1',
      [id]
    );

    if (dealerCheck.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Dealer not found',
        details: `No dealer found with ID ${id}`
      });
    }


    const carsResult = await pool.query(
      "SELECT car_id, make, model, year, price, mileage, is_sold FROM cars WHERE dealer_id = $1 and is_sold=FALSE;",
      [id]
    );

    const countResult = await pool.query(
      "SELECT COUNT(*) FROM cars WHERE dealer_id = $1",
      [id]
    );

    const carsWithImages = await Promise.all(
      carsResult.rows.map(car => formatCarWithImages(car))
    );

    res.json({
      data: carsWithImages,
    });
  } catch (error) {
    console.error(`Error fetching cars for dealer ${id}:`, error);
    res.status(500).json({ 
      error: 'Failed to fetch cars',
      details: error.message 
    });
  }
});

module.exports = router;