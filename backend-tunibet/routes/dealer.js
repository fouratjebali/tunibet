const express = require("express");
const pool = require("../db");
const router = express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const path = require('path');
require("dotenv").config();

const JWT_SECRET = process.env.JWT_SECRET || "yourSuperSecretKey";

// Configure multer storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/");
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage });

// Register a new dealer
router.post("/register", async (req, res) => {
  const { dealerName, email, password, phoneNumber } = req.body;

  // Validate input
  if (!dealerName || !email || !password || !phoneNumber) {
    return res.status(400).json({ error: "All fields are required" });
  }

  try {
    // Check if dealer already exists
    const existingDealer = await pool.query(
      "SELECT * FROM dealers WHERE email = $1 OR phone_number = $2",
      [email, phoneNumber]
    );

    if (existingDealer.rows.length > 0) {
      return res.status(400).json({ error: "Email or phone number already exists" });
    }

    // Reset sequence if table is empty (only for development/testing)
    const empty = await pool.query("SELECT * FROM dealers;");
    if (empty.rows.length === 0) {
      await pool.query("ALTER SEQUENCE dealers_id_seq RESTART WITH 1;");
    }

    // Hash password and create new dealer
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    
    const newDealer = await pool.query(
      "INSERT INTO dealers (dealer_name, email, password, phone_number) VALUES ($1, $2, $3, $4) RETURNING *",
      [dealerName, email, hashedPassword, phoneNumber]
    );

    res.status(201).json({ 
      message: "Dealer created successfully", 
      dealer: newDealer.rows[0] 
    });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ error: "Server error during registration" });
  }
});

// Dealer login
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Email and password are required" });
  }

  try {
    const dealer = await pool.query("SELECT * FROM dealers WHERE email = $1", [email]);

    if (dealer.rows.length === 0) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const validPassword = await bcrypt.compare(password, dealer.rows[0].password);

    if (!validPassword) {
      return res.status(401).json({ message: "Invalid password" });
    }

    const token = jwt.sign(
      { 
        id: dealer.rows[0].dealer_id, 
        email: dealer.rows[0].email 
      },
      JWT_SECRET,
      { expiresIn: "1h" }
    );

    res.status(200).json({ 
      message: "Login successful", 
      token, 
      dealer: dealer.rows[0] 
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

// Get dealer profile
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  
  try {
    const result = await pool.query("SELECT u.dealer_id, u.email, u.dealer_name, u.phone_number, ui.image_url FROM dealers u LEFT JOIN dealerimage ui ON u.dealer_id = ui.dealer_id WHERE u.dealer_id = $1;", [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Dealer not found' });
    }
    
    const dealerData = result.rows[0];
    const baseUrl = 'http://10.0.2.2:5000'
    const profileImage = dealerData.image_url
      ? `${baseUrl}${dealerData.image_url}` 
      : `${baseUrl}/uploads/default-profile.jpg`;
    res.json({
      id: dealerData.dealer_id,
      email: dealerData.email,
      dealerName: dealerData.dealer_name,
      phoneNumber: dealerData.phone_number,
      profileImage: profileImage,
    });
  } catch (error) {
    console.error('Error fetching dealer profile:', error);
    res.status(500).json({ error: 'Failed to fetch dealer profile' });
  }
});

// Update dealer profile
router.put('/:id', upload.single('profileImage'), async (req, res) => {
  const { id } = req.params;
  const { dealerName, email, password, phoneNumber } = req.body;
  const profileImage = req.file ? `/uploads/${req.file.filename}` : null;

  try {
    let updateQuery = 'UPDATE dealers SET dealer_name = $1, email = $2, phone_number = $3';
    const queryParams = [dealerName, email, phoneNumber];
    
    // Only update password if provided
    if (password) {
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
      updateQuery += `, password = $${queryParams.length + 1}`;
      queryParams.push(hashedPassword);
    }

    updateQuery += ` WHERE dealer_id = $${queryParams.length + 1} RETURNING *`;
    queryParams.push(id);

    const result = await pool.query(updateQuery, queryParams);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Dealer not found' });
    }

    // Handle profile image update
    if (profileImage) {
      // Check if image record exists
      const imageCheck = await pool.query(
        'SELECT * FROM dealerimage WHERE dealer_id = $1',
        [id]
      );

      if (imageCheck.rows.length > 0) {
        // Update existing image
        await pool.query(
          'UPDATE dealerimage SET image_url = $1 WHERE dealer_id = $2',
          [profileImage, id]
        );
      } else {
        // Insert new image record
        await pool.query(
          'INSERT INTO dealerimage (dealer_id, image_url) VALUES ($1, $2)',
          [id, profileImage]
        );
      }
    }

    res.status(200).json({
      message: 'Profile updated successfully',
      dealer: result.rows[0],
    });
  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({ error: 'Failed to update dealer profile' });
  }
});

module.exports = router;