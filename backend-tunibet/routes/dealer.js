const express = require("express");
const pool = require("../db");
const router = express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
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

        // Check if user exists
        const dealer = await pool.query("SELECT * FROM dealers WHERE email = $1", [email]);

        if (dealer.rows.length === 0) {
            return res.status(401).json({ message: "Invalid email or password" });
        }

        // Verify password
        const validPassword = await bcrypt.compare(password, dealer.rows[0].password);

        if (!validPassword) {
            return res.status(401).json({ message: "Invalid password" });
        }

        // Generate JWT token
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



module.exports = router;