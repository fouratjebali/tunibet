const express = require("express");
const cors = require("cors");
const jwt = require("jsonwebtoken");
const userRegistre = require("./routes/user");
const userLogin = require("./routes/user");
const dealerRegistre = require("./routes/dealer");
const dealerLogin = require("./routes/dealer");
const cars = require("./routes/car");

const app = express();

app.use(express.json());
app.use(cors());





app.use("/api/users", userRegistre);
app.use("/api/users", userLogin);
app.use("/api/dealers", dealerRegistre);
app.use("/api/dealers", dealerLogin);
app.use("/api/cars",cars);
app.get("/", (req, res) => {
    res.send("Welcome to the API");
});


const PORT = 5000;
app.listen(PORT, '0.0.0.0',() => {
    console.log(`Server running on http://localhost:${PORT}`);
});
