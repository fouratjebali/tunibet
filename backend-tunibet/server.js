const express = require("express");
const cors = require("cors");

const app = express();

app.use(express.json());
app.use(cors());


const userRoutes = require("./routes/user");
app.use("/api/users", userRoutes);
console.log("User routes loaded");


const PORT = 5000;
app.listen(PORT, () => {
    console.log("Server running on http://localhost:${PORT}");
});
