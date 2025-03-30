const express = require("express");
const multer = require("multer");
const path = require("path");
const pool = require("../db"); 
const router = express.Router();
const fs = require('fs');
const uploadDir = './uploads';


const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/"); 
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname)); 
  },
});

const upload = multer({ storage });

router.post("/upload-profile", upload.single("image"), async (req, res) => {
  try {
    const { id } = req.body; 
    if (!req.file) return res.status(400).json({ error: "No file uploaded" });

    const imageUrl = `/uploads/${req.file.filename}`; 

    const result = await pool.query(
      "INSERT INTO userimage (id, image_url) VALUES ($1, $2) RETURNING *",
      [id, imageUrl]
    );

    res.status(201).json({ message: "Image uploaded", image: result.rows[0] });
  } catch (error) {
    console.error("Upload error:", error);
    res.status(500).json({ error: "Server error" });
  }
});

router.put('/users/:id', upload.single('profileImage'), async (req, res) => {
  const { id } = req.params;
  const { fullName, email, password, phoneNumber } = req.body;
  const profileImage = req.file ? `/uploads/${req.file.filename}` : null;

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
