const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const path = require("path");
const userRegistre = require("./routes/user");
const userLogin = require("./routes/user");
const dealerRegistre = require("./routes/dealer");
const dealerLogin = require("./routes/dealer");
const cars = require("./routes/car");
const uploadProfile = require("./routes/uploadProfile");
const uploadDealerProfile = require("./routes/uploadDealerProfile");
const editUser = require("./routes/user");
const editDealer = require("./routes/dealer");
const bet = require("./routes/bet");
const dealercars = require("./routes/dealercars");
const notification = require("./routes/notification");
const pool = require("./db");
require("dotenv").config();

const app = express();
app.use(helmet());
app.use(morgan("combined"));
app.use(cors({
  origin: '*', // Allow all origins
}));


app.use(express.json());
app.use(express.urlencoded({ extended: true, limit: "10kb" }));

app.use("/uploads", express.static(path.join(__dirname, "uploads")));

const apiRouter = express.Router();
app.use("/api", apiRouter);

apiRouter.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});




app.use("/api/users", userRegistre);
app.use("/api/users", userLogin);
app.use("/api/dealers", dealerRegistre);
app.use("/api/dealers", dealerLogin);
app.use("/api/cars", cars);
app.use("/uploads", express.static("uploads"));
app.use("/api/users", uploadProfile);
app.use("/api/dealers", uploadDealerProfile);
app.use("/api/users", editUser);
app.use("/api/dealers", editDealer);
app.use("/api/bets", bet);
app.use("/api/dealercars", dealercars);
app.use("/api/notifications", notification);


app.get("/", (req, res) => {
    res.send("test api");
});


app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: "Internal Server Error",
    message: process.env.NODE_ENV === "development" ? err.message : undefined
  });
});
  
  // 404 handler
  app.use((req, res) => {
    res.status(404).json({ error: "Endpoint not found" });
  });
  
  // Server setup

  
const PORT = 5000;
app.listen(PORT, "0.0.0.0",() => {
    console.log(`Server running on http://localhost:${PORT}`);
});
  
  process.on("unhandledRejection", (err) => {
    console.error("Unhandled rejection:", err);
    process.exit(1);
  });
