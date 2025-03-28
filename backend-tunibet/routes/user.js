const express = require("express");
const pool = require("../db");
const router = express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
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

module.exports = router;
