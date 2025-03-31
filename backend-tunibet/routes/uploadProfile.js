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



module.exports = router;
