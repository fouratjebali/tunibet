const express = require("express");
const router = express.Router();

router.post("/register", async (req, res) => {
    const { fullName, email, password, phoneNumber } = req.body;

    if (!fullName || !email || !password || !phoneNumber) {
        return res.status(400).json({ error: "All fields are required" });
    }

    try {
        const newUser = await pool.query(
            "INSERT INTO users (full_name, email, password, phone_number) VALUES ($1, $2, $3, $4) RETURNING *",
            [fullName, email, password, phoneNumber]
        );

        res.status(201).json({ message: "User created successfully", user: newUser.rows[0] });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Server error" });
    }
    console.log(req.body);
});

module.exports = router;
