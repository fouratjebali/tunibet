const express = require("express");
const pool = require("../db");
const router = express.Router();
const multer = require("multer");
const path = require("path");

async function getCarImages(carId) {
  const imagesResult = await pool.query(
    'SELECT image_url FROM carimages WHERE car_id = $1 ORDER BY uploaded_at DESC',
    [carId]
  );
  return imagesResult.rows.map(row => row.image_url);
}

async function formatCarWithImages(car) {
  const baseUrl = "http://10.0.2.2:5000"; 
  const images = await getCarImages(car.id);

  return {
    ...car,
    images: images.map(image => image.startsWith("https") ? image : `${baseUrl}${image}`), // Handle both absolute and relative URLs
    image_url: images.length > 0
      ? (images[0].startsWith("https") ? images[0] : `${baseUrl}${images[0]}`) // Handle the first image
      : null,
  };
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, "../uploads")); // Save files in the 'uploads' folder
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname)); // Generate a unique filename
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Limit file size to 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = ["image/jpeg", "image/png", "image/jpg"];
    const fileExtension = path.extname(file.originalname).toLowerCase();
    console.log(`File MIME type: ${file.mimetype}`);
    console.log(`File extension: ${fileExtension}`);
    if (
      (allowedTypes.includes(file.mimetype) || file.mimetype === "application/octet-stream") &&
      [".jpg", ".jpeg", ".png"].includes(fileExtension)
    ) {
      cb(null, true);
    } else {
      console.error(`Unsupported file type: ${file.mimetype}`);
      cb(new Error("Only JPEG, PNG, and JPG files are allowed"));
    }
  },
});

router.get('/', async (req, res) => {
  try {
    const result = await pool.query("SELECT car_id as id, make, model, year, price, mileage, fuel_type, transmission, horsepower, body_type, color, condition, description, location, is_sold FROM Cars ORDER BY price DESC;");
    
    const carsWithImages = await Promise.all(
      result.rows.map(car => formatCarWithImages(car))
    );
    
    res.json(carsWithImages);
  } catch (error) {
    console.error('Error fetching cars:', error);
    res.status(500).json({ error: "Failed to fetch cars" });
  }
});

router.get('/recommended', async (req, res) => {
  try {
    const result = await pool.query("SELECT car_id as id, make, model, year, price, mileage, fuel_type, transmission, horsepower, body_type, color, condition, description, location, is_sold FROM Cars WHERE is_sold = FALSE ORDER BY year DESC, price DESC LIMIT 10;");
    
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
    const result = await pool.query("SELECT car_id as id, make, model, year, price, mileage, fuel_type, transmission, horsepower, body_type, color, condition, description, location, is_sold FROM Cars WHERE (make ILIKE $1 OR model ILIKE $1 OR body_type ILIKE $1 OR fuel_type ILIKE $1 OR CAST(year AS TEXT) LIKE $1) AND is_sold = FALSE ORDER BY price DESC;", [`%${query}%`]);
    
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
    const result = await pool.query("SELECT car_id as id, make, model, year, price, mileage, fuel_type, transmission, horsepower, body_type, color, condition, description, location, is_sold FROM Cars WHERE car_id = $1;", [id]);
    
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
    let query = "SELECT car_id as id, make, model, year, price, mileage, fuel_type, transmission, horsepower, body_type, color, condition, description, location, is_sold FROM Cars WHERE is_sold = FALSE;";
    
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
    
    query += ' ORDER BY price DESC';
    
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


router.post("/", upload.array("images", 10), async (req, res) => {
  const {
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
    dealer_id,
  } = req.body;

  const files = req.files;

  if (!make || !model || !year || !price || !dealer_id) {
    return res.status(400).json({ error: "Required fields are missing" });
  }

  try {
    const carResult = await pool.query(
      `INSERT INTO Cars 
        (make, model, year, price, mileage, fuel_type, transmission, horsepower, body_type, color, condition, description, location, dealer_id, is_sold) 
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, FALSE) 
        RETURNING car_id`,
      [
        make,
        model,
        year,
        price,
        mileage || null,
        fuel_type || null,
        transmission || null,
        horsepower || null,
        body_type || null,
        color || null,
        condition || null,
        description || null,
        location || null,
        dealer_id,
      ]
    );

    const carId = carResult.rows[0].car_id;

    if (files && files.length > 0) {
      const imageInsertPromises = files.map((file) =>
        pool.query(
          "INSERT INTO carimages (car_id, image_url) VALUES ($1, $2)",
          [carId, `/uploads/${file.filename}`]
        )
      );
      await Promise.all(imageInsertPromises);
    }

    res.status(200).json({ message: "Car posted successfully", carId });
  } catch (error) {
    console.error("Error posting car:", error);
    res.status(500).json({ error: "Failed to post car" });
  }
});

module.exports = router;