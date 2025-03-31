const express = require("express");
const pool = require("../db");
const router = express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const path = require('path');
require("dotenv").config();
const JWT_SECRET = process.env.JWT_SECRET || "yourSuperSecretKey";

router.post("/register", async (req, res) => {
    const { dealerName, email, password, phoneNumber } = req.body;
    

    if (!dealerName || !email || !password || !phoneNumber) {
        return res.status(400).json({ error: "All fields are required" });
    }

    const existingDealer = await pool.query(
        "SELECT * FROM dealers WHERE email = $1 OR phone_number = $2",
        [email, phoneNumber]
    );

    if (existingDealer.rows.length > 0) {
        return res.status(400).json({ error: "Email or phone number already exists" });
    }
    const empty = await pool.query("SELECT * FROM DEALERS;");
    if (empty.rows.length === 0){
        const reset_sequence = await pool.query("ALTER SEQUENCE dealers_id_seq RESTART WITH 1;");
    }

    try {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);
        const newDealer = await pool.query(
            "INSERT INTO dealers (dealer_name, email, password, phone_number) VALUES ($1, $2, $3, $4) RETURNING *",
            [dealerName, email, hashedPassword, phoneNumber]
        );
    

        res.status(201).json({ message: "Dealer created successfully", dealer: newDealer.rows[0] });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Server error" });
    }
    console.log(req.body);
});


router.post("/login", async (req, res) => {
    try {
        const { email, password } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ message: "Email and password are required" });
        }

        const dealer = await pool.query("SELECT * FROM dealers WHERE email = $1", [email]);

        if (dealer.rows.length === 0) {
            return res.status(401).json({ message: "Invalid email or password" });
        }

        const validPassword = await bcrypt.compare(password, dealer.rows[0].password);

        if (!validPassword) {
            return res.status(401).json({ message: "Invalid password" });
        }

        const token = jwt.sign(
            { id: dealer.rows[0].dealer_id, email: dealer.rows[0].email },
            JWT_SECRET,
            { expiresIn: "1h" }
        );

        res.status(200).json({ message: "Login successful", token, dealer: dealer.rows[0] });
    } catch (error) {
        res.status(500).json({ message: "Internal server error", error: error.message });
    }
});

router.get('/:id', async (req, res) => {
    const { id } = req.params;
    
    try {
      const result = await pool.query(`
        SELECT 
          u.dealer_id,
          u.email,
          u.dealer_name,
          ui.image_url
        FROM 
          dealers u
        LEFT JOIN 
          dealerimage ui ON u.dealer_id = ui.dealer_id
        WHERE 
          u.dealer_id = $1
      `, [id]);
      
      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Dealer not found' });
      }
      
      const userData = result.rows[0];
      
      res.json({
        id: userData.dealer_id,
        email: userData.email,
        fullName: userData.dealer_name,
        profileImage: userData.image_url || null
      });
    } catch (error) {
      console.error('Error fetching dealer profile:', error);
      res.status(500).json({ error: 'Failed to fetch dealer profile' });
    }
  });

  const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, "uploads/"); 
    },
    filename: function (req, file, cb) {
      cb(null, Date.now() + path.extname(file.originalname)); 
    },
  });
  
  const upload = multer({ storage });

  router.put('/:id', upload.single('profileImage'), async (req, res) => {
    const { id } = req.params;
    const { fullName, email, password, phoneNumber } = req.body;
    const profileImage = req.file ? `/uploads/${req.file.filename}` : null;
    console.log(id);
    try {
      const result = await pool.query(
        `UPDATE dealers SET dealer_name = $1, email = $2, password = $3, phone_number = $4 WHERE dealer_id = $5 RETURNING *`,
        [fullName, email, password, phoneNumber, id]
      );
  
      // If the user has updated their profile image
      if (profileImage) {
        await pool.query(
          `UPDATE dealerimage SET image_url = $1 WHERE dealer_id = $2`,
          [profileImage, id]
        );
      }
  
      if (result.rows.length > 0) {
        return res.status(200).json({
          message: 'Profile updated successfully',
          user: result.rows[0],
        });
      } else {
        return res.status(404).json({ error: 'Dealer not found' });
      }
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'Failed to update Dealer profile' });
    }
  });

module.exports = router;