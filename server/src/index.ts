import express from "express";
import cors from "cors";
import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./config/swagger";
import authRoute from "./routes/auth/auth.route";
import entriesRoute from "./routes/entries/entries.route";
import usersRoute from "./routes/users/users.route";

const app = express();
const PORT = 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Swagger
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// API Routes
app.use("/api/auth", authRoute);
app.use("/api/entries", entriesRoute);
app.use("/api/users", usersRoute);

app.get("/", (req, res) => {
  res.send("Hello! This is Crave Developer:)");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
