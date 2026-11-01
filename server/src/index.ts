import express from "express";
import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./config/swagger";
import authRoute from "./routes/auth/auth.route";

const app = express();
const PORT = 5000;

app.use(express.json());

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use("/api/auth", authRoute);

app.get("/", (req, res) => {
  res.send("Hello! This is Crave Developer:)");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
