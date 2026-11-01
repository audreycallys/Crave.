import { defineConfig } from "drizzle-kit";
import dotenv from "dotenv";

dotenv.config();

export default defineConfig({
  schema: "./src/config/schema.ts",
  dialect: "mysql",
  dbCredentials: {
    host: process.env.DB_HOST!,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_USER!,
    database: process.env.DB_NAME!,
  },
});

// import { defineConfig } from "drizzle-kit";
// import dotenv from "dotenv";
// import path from "node:path";

// dotenv.config({
//   path: path.resolve(process.cwd(), ".env"),
// });

// export default defineConfig({
//   schema: "./src/config/schema.ts",
//   dialect: "mysql",
//   dbCredentials: {
//     host: process.env.DB_HOST || "127.0.0.1",
//     port: Number(process.env.DB_PORT) || 3306,
//     user: process.env.DB_USER || "root",
//     password: process.env.DB_PASSWORD || "",
//     database: process.env.DB_NAME || "crave_db",
//   },
// });
