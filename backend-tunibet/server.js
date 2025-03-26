const express = require("express");
const cors = require("cors");
const userRegistre = require("./routes/user");
const userLogin = require("./routes/user");

const app = express();

app.use(express.json());
app.use(cors());



app.use("/api/users", userRegistre);
app.use("/api/users", userLogin);

app.get("/", (req, res) => {
    res.send("Welcome to the API");
});


const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
