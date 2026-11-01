import {
  mysqlTable,
  mysqlEnum,
  int,
  varchar,
  text,
  timestamp,
  decimal,
  date,
  boolean,
} from "drizzle-orm/mysql-core";

// Available food entry categories
export const FOOD_CATEGORIES = ["Food", "Drink"] as const;

// Available user roles
export const USER_ROLES = ["user", "admin"] as const;

// USERS TABLE
export const usersTable = mysqlTable("users", {
  id: int("id").autoincrement().primaryKey(),
  name: varchar("name", { length: 100 }).notNull(),
  email: varchar("email", { length: 100 }).notNull().unique(),
  password: varchar("password", { length: 255 }).notNull(),
  role: mysqlEnum("role", USER_ROLES).notNull().default("user"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow(),
});

// FOOD ENTRIES TABLE
export const foodEntriesTable = mysqlTable("food_entries", {
  id: int("id").autoincrement().primaryKey(),
  userId: int("user_id")
    .notNull()
    .references(() => usersTable.id, {
      onDelete: "cascade",
    }),
  menuName: varchar("menu_name", { length: 150 }).notNull(),
  placeName: varchar("place_name", { length: 150 }),
  category: mysqlEnum("category", FOOD_CATEGORIES).notNull(),
  price: decimal("price", {
    precision: 12,
    scale: 2,
  }).notNull(),
  dateTried: date("date_tried", {
    mode: "string",
  }).notNull(),
  rating: int("rating").notNull(),
  photoUrl: varchar("photo_url", { length: 500 }).notNull(),
  isPublic: boolean("is_public").notNull().default(false),
  notes: text("notes"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow(),
});
