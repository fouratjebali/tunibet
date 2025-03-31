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
    const { fullName, email, password, phoneNumber } = req.body;

    if (!fullName || !email || !password || !phoneNumber) {
        return res.status(400).json({ error: "All fields are required" });
    }
    const trimmedPassword = password.trim();

    const existingUser = await pool.query(
        "SELECT * FROM users WHERE email = $1 OR phone_number = $2",
        [email, phoneNumber]
    );

    if (existingUser.rows.length > 0) {
        return res.status(400).json({ error: "Email or phone number already exists" });
    }

    const empty = await pool.query("SELECT * FROM USERS;");
    if (empty.rows.length === 0){
        const reset_sequence = await pool.query("ALTER SEQUENCE users_id_seq RESTART WITH 1;");
    }

    try {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(trimmedPassword, salt);
        const newUser = await pool.query(
            "INSERT INTO users (full_name, email, password, phone_number) VALUES ($1, $2, $3, $4) RETURNING *",
            [fullName, email, hashedPassword, phoneNumber]
        );

        res.status(201).json({ message: "User created successfully", user: newUser.rows[0] });
    } catch (error) {
        console.error("Registration Error:", error);
        res.status(500).json({ error: "Server error" });
    }
});

router.post("/login", async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: "Email and password are required" });
        }
        const trimmedPassword = password.trim();
        const user = await pool.query("SELECT * FROM users WHERE email = $1", [email]);

        if (user.rows.length === 0) {
            return res.status(401).json({ message: "Invalid email or password" });
        }

        const validPassword = await bcrypt.compare(trimmedPassword, user.rows[0].password);
        if (!validPassword) {
            return res.status(401).json({ message: "Invalid password" });
        }

        const token = jwt.sign(
            { id: user.rows[0].id, email: user.rows[0].email },
            JWT_SECRET,
            { expiresIn: "1h" }
        );

        res.status(200).json({
            message: "Login successful",
            token,
            user: { id: user.rows[0].id, fullName: user.rows[0].full_name, email: user.rows[0].email },
        });
    } catch (error) {
        console.error("Login Error:", error);
        res.status(500).json({ message: "Internal server error", error: error.message });
    }
});

router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query(`
        SELECT 
          u.id,
          u.email,
          u.full_name,
          ui.image_url
        FROM 
          users u
        LEFT JOIN 
          userimage ui ON u.id = ui.id
        WHERE 
          u.id = $1
      `, [id]);
      
      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }
      
      const userData = result.rows[0];
      
      res.json({
        id: userData.user_id,
        email: userData.email,
        fullName: userData.full_name,
        profileImage: userData.image_url ? `http://10.0.2.2:5000${userData.image_url}` : null
      });
    } catch (error) {
      console.error('Error fetching user profile:', error);
      res.status(500).json({ error: 'Failed to fetch user profile' });
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
        `UPDATE users SET full_name = $1, email = $2, password = $3, phone_number = $4 WHERE id = $5 RETURNING *`,
        [fullName, email, password, phoneNumber, id]
      );
  
      // If the user has updated their profile image
      if (profileImage) {
        await pool.query(
          `UPDATE userimage SET image_url = $1 WHERE id = $2`,
          [profileImage, id]
        );
      }
  
      if (result.rows.length > 0) {
        return res.status(200).json({
          message: 'Profile updated successfully',
          user: result.rows[0],
        });
      } else {
        return res.status(404).json({ error: 'User not found' });
      }
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'Failed to update user profile' });
    }
  });

module.exports = router;
